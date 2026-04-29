import 'dart:convert';

import 'judge_action_entity.dart';

class JudgeStartSequenceState {
  const JudgeStartSequenceState({
    required this.hasFiveMinuteProcedure,
    required this.hasOneMinuteProcedure,
    required this.hasWarningSignal,
    required this.hasPreparatorySignal,
    required this.hasStartSignal,
  });

  final bool hasFiveMinuteProcedure;
  final bool hasOneMinuteProcedure;
  final bool hasWarningSignal;
  final bool hasPreparatorySignal;
  final bool hasStartSignal;

  bool get hasConfiguredProcedure =>
      hasFiveMinuteProcedure || hasOneMinuteProcedure;

  bool get canScheduleFiveMinute =>
      !hasConfiguredProcedure &&
      !hasWarningSignal &&
      !hasPreparatorySignal &&
      !hasStartSignal;

  bool get canScheduleOneMinute => canScheduleFiveMinute;

  bool get canSendWarning =>
      hasFiveMinuteProcedure &&
      !hasWarningSignal &&
      !hasPreparatorySignal &&
      !hasStartSignal;

  bool get canSendPreparatory =>
      hasFiveMinuteProcedure &&
      hasWarningSignal &&
      !hasPreparatorySignal &&
      !hasStartSignal;

  bool get canSendStart =>
      !hasStartSignal &&
      ((hasOneMinuteProcedure && !hasWarningSignal && !hasPreparatorySignal) ||
          (hasFiveMinuteProcedure &&
              hasWarningSignal &&
              hasPreparatorySignal));

  bool get canStartRace => hasStartSignal;

  static const empty = JudgeStartSequenceState(
    hasFiveMinuteProcedure: false,
    hasOneMinuteProcedure: false,
    hasWarningSignal: false,
    hasPreparatorySignal: false,
    hasStartSignal: false,
  );

  factory JudgeStartSequenceState.fromActions({
    required int raceId,
    required List<JudgeActionEntity> actions,
  }) {
    bool hasFiveMinuteProcedure = false;
    bool hasOneMinuteProcedure = false;
    bool hasWarningSignal = false;
    bool hasPreparatorySignal = false;
    bool hasStartSignal = false;

    final orderedActions = actions
        .where((action) => action.raceId == raceId)
        .toList(growable: false)
      ..sort((left, right) => left.createdAtUtc.compareTo(right.createdAtUtc));

    for (final action in orderedActions) {
      if (action.eventType == 'start_procedure_configured') {
        final payload = _decodePayload(action.payloadJson);
        final durationSeconds = (payload['durationSeconds'] as num?)?.toInt();
        if (durationSeconds == 300) {
          hasFiveMinuteProcedure = true;
          hasOneMinuteProcedure = false;
          hasWarningSignal = false;
          hasPreparatorySignal = false;
          hasStartSignal = false;
        } else if (durationSeconds == 60) {
          hasFiveMinuteProcedure = false;
          hasOneMinuteProcedure = true;
          hasWarningSignal = false;
          hasPreparatorySignal = false;
          hasStartSignal = false;
        }
        continue;
      }

      if (action.eventType != 'start_procedure_signal') {
        continue;
      }

      final payload = _decodePayload(action.payloadJson);
      final signalType = payload['signalType'] as String?;
      switch (signalType) {
        case 'warning':
          hasWarningSignal = true;
        case 'preparatory':
          hasPreparatorySignal = true;
        case 'start':
          hasStartSignal = true;
      }
    }

    return JudgeStartSequenceState(
      hasFiveMinuteProcedure: hasFiveMinuteProcedure,
      hasOneMinuteProcedure: hasOneMinuteProcedure,
      hasWarningSignal: hasWarningSignal,
      hasPreparatorySignal: hasPreparatorySignal,
      hasStartSignal: hasStartSignal,
    );
  }

  static Map<String, Object?> _decodePayload(String? payloadJson) {
    if (payloadJson == null || payloadJson.isEmpty) {
      return const <String, Object?>{};
    }
    try {
      return Map<String, Object?>.from(jsonDecode(payloadJson) as Map);
    } catch (_) {
      return const <String, Object?>{};
    }
  }
}
