import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/course_entity.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/geo_point_entity.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/mark_entity.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/start_line_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_point_entity.dart';
import 'package:vkr_regatta/src/presentation/maps/regatta_map_view.dart';

void main() {
  testWidgets('RegattaMapView displays empty state without map anchors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 400,
          height: 300,
          child: RegattaMapView(trackPoints: [], enableTiles: false),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('regatta-map-empty')), findsOneWidget);
  });

  testWidgets('RegattaMapView displays track, current position and course', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 400,
          height: 300,
          child: RegattaMapView(
            enableTiles: false,
            trackPoints: [
              TrackingPointEntity(
                sessionId: 1,
                timestampUtc: DateTime.utc(2026, 5, 26, 12),
                latitude: 60,
                longitude: 30,
              ),
              TrackingPointEntity(
                sessionId: 1,
                timestampUtc: DateTime.utc(2026, 5, 26, 12, 0, 1),
                latitude: 60.001,
                longitude: 30.001,
              ),
            ],
            course: _course(),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('regatta-map-track-layer')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('regatta-map-course-layer')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('regatta-map-current-marker')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('regatta-map-mark-windward')),
      findsOneWidget,
    );
  });
}

CourseEntity _course() {
  return CourseEntity(
    raceId: 701,
    name: 'Test course',
    startLine: const StartLineEntity(
      committeeBoat: GeoPointEntity(latitude: 60, longitude: 30),
      pinEnd: GeoPointEntity(latitude: 60, longitude: 30.001),
    ),
    marks: const [
      MarkEntity(
        id: 'windward',
        name: 'Windward',
        position: GeoPointEntity(latitude: 60.002, longitude: 30.001),
        order: 1,
        roundingSide: MarkRoundingSide.port,
      ),
    ],
    finishLine: const StartLineEntity(
      committeeBoat: GeoPointEntity(latitude: 60.003, longitude: 30.0),
      pinEnd: GeoPointEntity(latitude: 60.003, longitude: 30.001),
    ),
    updatedAtUtc: DateTime.utc(2026, 5, 26, 12),
  );
}
