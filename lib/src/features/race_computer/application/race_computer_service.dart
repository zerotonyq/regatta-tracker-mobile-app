import 'dart:convert';

import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

import '../../judge/domain/judge_action_entity.dart';
import '../../tracking/domain/derived_metric_entity.dart';
import '../../tracking/domain/tracking_point_entity.dart';
import '../../tracking/domain/tracking_session_entity.dart';
import '../domain/course_entity.dart';
import '../domain/layline_hint_entity.dart';
import '../domain/race_state_entity.dart';
import '../domain/start_procedure_entity.dart';
import '../domain/wind_estimate_entity.dart';
import 'geo_math.dart';
import 'mark_distance_calculator.dart';
import 'start_line_calculator.dart';
import 'wind_estimator.dart';

class RaceComputerService {
  const RaceComputerService({
    StartLineCalculator startLineCalculator = const StartLineCalculator(),
    MarkDistanceCalculator markDistanceCalculator =
        const MarkDistanceCalculator(),
    WindEstimator windEstimator = const WindEstimator(),
    GeoMath geoMath = const GeoMath(),
  }) : _startLineCalculator = startLineCalculator,
       _markDistanceCalculator = markDistanceCalculator,
       _windEstimator = windEstimator,
       _geoMath = geoMath;

  final StartLineCalculator _startLineCalculator;
  final MarkDistanceCalculator _markDistanceCalculator;
  final WindEstimator _windEstimator;
  final GeoMath _geoMath;

  RaceStateEntity evaluate({
    required int raceId,
    required TrackingPointEntity? currentPoint,
    required TrackingPointEntity? previousPoint,
    required CourseEntity? course,
    required List<DerivedMetricEntity> latestMetrics,
    required List<JudgeActionEntity> judgeActions,
    required DateTime nowUtc,
    required TrackingSessionState trackingState,
  }) {
    final startProcedure = _evaluateStartProcedure(
      judgeActions: judgeActions,
      nowUtc: nowUtc,
    );

    if (currentPoint == null) {
      return RaceStateEntity(
        phase: 'awaiting_gps',
        updatedAtUtc: nowUtc,
        statusMessage: 'Ожидаются GPS-данные для расчета состояния гонки.',
        recommendedTrackingProfile: _recommendedProfile(
          trackingState: trackingState,
          startProcedure: startProcedure,
        ),
        startProcedure: startProcedure,
        confidence: 0,
      );
    }

    if (course == null) {
      return RaceStateEntity(
        phase: startProcedure?.isActive == true
            ? 'prestart_countdown'
            : 'awaiting_course',
        updatedAtUtc: nowUtc,
        statusMessage:
            startProcedure?.statusMessage ??
            'Опорный курс еще не настроен. Постройте его, чтобы получить подсказки по геометрии дистанции.',
        recommendedTrackingProfile: _recommendedProfile(
          trackingState: trackingState,
          startProcedure: startProcedure,
        ),
        startProcedure: startProcedure,
        confidence: 0.2,
      );
    }

    final metricMap = _windEstimator.latestMetricMap(latestMetrics);
    final windEstimate = _windEstimator.estimate(latestMetrics: metricMap);
    final startLine = _startLineCalculator.calculate(
      line: course.startLine,
      currentPoint: currentPoint,
      previousPoint: previousPoint,
      windDirectionDegrees: windEstimate?.directionDegrees,
    );
    final nextMark = course.nextMark == null
        ? null
        : _markDistanceCalculator.calculate(
            mark: course.nextMark!,
            currentPoint: currentPoint,
          );
    final laylineHint = _buildLaylineHint(
      nextMarkBearingDegrees: nextMark?.bearingDegrees,
      windEstimate: windEstimate,
    );
    final confidence = _computeConfidence(
      windEstimate: windEstimate,
      latestMetrics: metricMap,
    );
    final crossedLine = startLine.crossedLine;
    final phase = _resolvePhase(
      startProcedure: startProcedure,
      crossedLine: crossedLine,
    );
    final recommendedTrackingProfile = _recommendedProfile(
      trackingState: trackingState,
      startProcedure: startProcedure,
      crossedLine: crossedLine,
      distanceToLineMeters: startLine.distanceToLineMeters,
      distanceToMarkMeters: nextMark?.distanceMeters,
    );
    final statusMessage = _buildStatusMessage(
      startProcedure: startProcedure,
      crossedLine: crossedLine,
    );

    return RaceStateEntity(
      phase: phase,
      updatedAtUtc: nowUtc,
      statusMessage: statusMessage,
      recommendedTrackingProfile: recommendedTrackingProfile,
      course: course,
      startLine: startLine,
      startProcedure: startProcedure,
      nextMark: nextMark,
      windEstimate: windEstimate,
      laylineHint: laylineHint,
      confidence: confidence,
    );
  }

  LaylineHintEntity? _buildLaylineHint({
    required double? nextMarkBearingDegrees,
    required WindEstimateEntity? windEstimate,
  }) {
    if (nextMarkBearingDegrees == null || windEstimate == null) {
      return null;
    }

    final relative = _geoMath.angleDifferenceDegrees(
      windEstimate.directionDegrees,
      nextMarkBearingDegrees,
    );
    final targetTack = relative >= 0 ? 'starboard' : 'port';

    return LaylineHintEntity(
      targetTack: targetTack,
      bearingDegrees: nextMarkBearingDegrees,
      confidence: (windEstimate.confidence * 0.9).clamp(0.1, 0.95),
      explanation:
          'Оценка построена по курсу, крену и косвенной оценке ветра. Используйте ее как подсказку.',
    );
  }

  double _computeConfidence({
    required WindEstimateEntity? windEstimate,
    required Map<String, double> latestMetrics,
  }) {
    double confidence = windEstimate?.confidence ?? 0.45;
    if ((latestMetrics['quality_stale_data'] ?? 0) > 0.5) {
      confidence -= 0.2;
    }
    if ((latestMetrics['quality_insufficient_samples'] ?? 0) > 0.5) {
      confidence -= 0.15;
    }
    return confidence.clamp(0.1, 0.95);
  }

  StartProcedureEntity? _evaluateStartProcedure({
    required List<JudgeActionEntity> judgeActions,
    required DateTime nowUtc,
  }) {
    JudgeActionEntity? configuredAction;
    for (final action in judgeActions) {
      if (action.eventType == 'start_procedure_configured') {
        configuredAction = action;
        break;
      }
    }
    if (configuredAction == null || configuredAction.payloadJson == null) {
      return null;
    }

    final payload =
        jsonDecode(configuredAction.payloadJson!) as Map<String, Object?>;
    final startAtRaw = payload['startAtUtc'] as String?;
    if (startAtRaw == null) {
      return null;
    }
    final durationSeconds =
        (payload['durationSeconds'] as num?)?.toInt() ?? 300;
    final startAtUtc = DateTime.parse(startAtRaw).toUtc();
    final remainingSeconds = startAtUtc.difference(nowUtc).inSeconds;
    final progress = durationSeconds <= 0
        ? 1.0
        : ((durationSeconds - remainingSeconds) / durationSeconds).clamp(
            0.0,
            1.0,
          );
    final lastSignal = judgeActions.firstWhere(
      (action) => action.eventType == 'start_procedure_signal',
      orElse: () => configuredAction!,
    );
    final lastSignalPayload = lastSignal.payloadJson == null
        ? null
        : jsonDecode(lastSignal.payloadJson!) as Map<String, Object?>;
    String? lastSignalType;
    if (lastSignal.eventType == 'start_procedure_signal') {
      lastSignalType = lastSignalPayload?['signalType'] as String?;
    } else {
      lastSignalType = 'configured';
    }
    final phase = _resolveStartProcedurePhase(
      remainingSeconds: remainingSeconds,
      durationSeconds: durationSeconds,
      lastSignalType: lastSignalType,
    );

    return StartProcedureEntity(
      phase: phase,
      configuredAtUtc: configuredAction.createdAtUtc,
      startAtUtc: startAtUtc,
      durationSeconds: durationSeconds,
      remainingSeconds: remainingSeconds > 0 ? remainingSeconds : 0,
      progress: progress,
      statusMessage: _startProcedureStatusMessage(
        phase: phase,
        remainingSeconds: remainingSeconds,
      ),
      lastSignalType: lastSignalType,
      lastSignalAtUtc: lastSignal.createdAtUtc,
      cue: _resolveCue(phase: phase, remainingSeconds: remainingSeconds),
    );
  }

  String _resolveStartProcedurePhase({
    required int remainingSeconds,
    required int durationSeconds,
    required String? lastSignalType,
  }) {
    if (remainingSeconds <= 0 || lastSignalType == 'start') {
      return 'started';
    }
    if (remainingSeconds <= 60) {
      return 'final_minute';
    }
    if (lastSignalType == 'preparatory' ||
        remainingSeconds <= durationSeconds - 60) {
      return 'preparatory';
    }
    return 'warning';
  }

  StartProcedureCue _resolveCue({
    required String phase,
    required int remainingSeconds,
  }) {
    if (remainingSeconds <= 0) {
      return StartProcedureCue.start;
    }
    if (remainingSeconds == 60) {
      return StartProcedureCue.oneMinute;
    }
    if (phase == 'preparatory' && remainingSeconds >= 61) {
      return StartProcedureCue.preparatory;
    }
    if (phase == 'warning') {
      return StartProcedureCue.warning;
    }
    return StartProcedureCue.none;
  }

  String _startProcedureStatusMessage({
    required String phase,
    required int remainingSeconds,
  }) {
    if (remainingSeconds <= 0) {
      return 'Стартовый сигнал достигнут. Таймер пересек отметку T-0.';
    }
    return 'Стартовая процедура: ${_startProcedurePhaseLabel(phase)}. До старта T-${_formatCountdown(remainingSeconds)}.';
  }

  String _startProcedurePhaseLabel(String phase) {
    return switch (phase) {
      'warning' => 'предупредительный сигнал',
      'preparatory' => 'подготовительный сигнал',
      'final_minute' => 'последняя минута до старта',
      'started' => 'старт дан',
      _ => phase,
    };
  }

  String _buildStatusMessage({
    required StartProcedureEntity? startProcedure,
    required bool crossedLine,
  }) {
    if (startProcedure?.isActive == true) {
      return startProcedure!.statusMessage;
    }
    return crossedLine
        ? 'Стартовая линия пересечена. Подсказки по геометрии дистанции активны.'
        : 'Идет подход к стартовой линии. Подсказки по геометрии дистанции активны.';
  }

  String _resolvePhase({
    required StartProcedureEntity? startProcedure,
    required bool crossedLine,
  }) {
    if (startProcedure?.isActive == true) {
      return 'prestart_countdown';
    }
    return crossedLine ? 'racing' : 'prestart_geometry';
  }

  TrackingProfile _recommendedProfile({
    required TrackingSessionState trackingState,
    StartProcedureEntity? startProcedure,
    bool crossedLine = false,
    double? distanceToLineMeters,
    double? distanceToMarkMeters,
  }) {
    if (trackingState == TrackingSessionState.paused) {
      return TrackingProfile.paused;
    }
    if (startProcedure?.isActive == true) {
      return TrackingProfile.prestartPrecision;
    }
    final isNearLine =
        !crossedLine &&
        distanceToLineMeters != null &&
        distanceToLineMeters <= 120;
    final isNearMark =
        distanceToMarkMeters != null && distanceToMarkMeters <= 150;
    if (isNearLine || isNearMark) {
      return TrackingProfile.markRoundingPrecision;
    }
    return TrackingProfile.raceCruise;
  }

  String _formatCountdown(int remainingSeconds) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final paddedSeconds = seconds.toString().padLeft(2, '0');
    return '$minutes:$paddedSeconds';
  }
}
