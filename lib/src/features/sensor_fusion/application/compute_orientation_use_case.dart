import '../algorithms/complementary_filter.dart';
import '../domain/fusion_session_state.dart';
import '../domain/imu_sensor_event_entity.dart';

class ComputeOrientationUseCase {
  const ComputeOrientationUseCase(this._complementaryFilter);

  final ComplementaryFilter _complementaryFilter;

  FilterChunkResult execute({
    required FusionSessionState initialState,
    required List<ImuSensorEventEntity> events,
    required DateTime timestampUtc,
    double? gpsCourseOverGroundDegrees,
    bool calibrationMissing = false,
    bool magneticInstability = false,
    bool staleData = false,
  }) {
    return _complementaryFilter.processChunk(
      initialState: initialState,
      events: events,
      timestampUtc: timestampUtc,
      gpsCourseOverGroundDegrees: gpsCourseOverGroundDegrees,
      calibrationMissing: calibrationMissing,
      magneticInstability: magneticInstability,
      staleData: staleData,
    );
  }
}
