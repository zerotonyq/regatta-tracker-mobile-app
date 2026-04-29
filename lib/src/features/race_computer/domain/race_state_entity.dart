import 'course_entity.dart';
import 'layline_hint_entity.dart';
import 'mark_snapshot_entity.dart';
import 'start_procedure_entity.dart';
import 'start_line_snapshot_entity.dart';
import 'wind_estimate_entity.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

class RaceStateEntity {
  const RaceStateEntity({
    required this.phase,
    required this.updatedAtUtc,
    required this.statusMessage,
    required this.recommendedTrackingProfile,
    this.course,
    this.startLine,
    this.startProcedure,
    this.nextMark,
    this.windEstimate,
    this.laylineHint,
    this.confidence = 0,
  });

  final String phase;
  final DateTime updatedAtUtc;
  final String statusMessage;
  final TrackingProfile recommendedTrackingProfile;
  final CourseEntity? course;
  final StartLineSnapshotEntity? startLine;
  final StartProcedureEntity? startProcedure;
  final MarkSnapshotEntity? nextMark;
  final WindEstimateEntity? windEstimate;
  final LaylineHintEntity? laylineHint;
  final double confidence;
}
