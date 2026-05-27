import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/features/race_computer/application/create_reference_course_use_case.dart';
import 'package:vkr_regatta/src/features/race_computer/application/evaluate_race_state_use_case.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/course_entity.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/race_computer_repository.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/race_state_entity.dart';
import 'package:vkr_regatta/src/features/race_computer/presentation/race_computer_controller.dart';
import 'package:vkr_regatta/src/presentation/judge/course_editor_page.dart';

void main() {
  testWidgets('CourseEditorPage validates empty course before save', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FakeRaceComputerRepository();
    final controller = RaceComputerController(
      evaluateRaceStateUseCase: EvaluateRaceStateUseCase(repository),
      createReferenceCourseUseCase: CreateReferenceCourseUseCase(repository),
      raceComputerRepository: repository,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CourseEditorPage(
          raceId: 701,
          controller: controller,
          enableMapTiles: false,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сохранить и опубликовать курс'));
    await tester.pump();

    expect(find.text('Укажите обе точки стартовой линии.'), findsOneWidget);
    expect(repository.savedCourses, isEmpty);
  });
}

class _FakeRaceComputerRepository implements RaceComputerRepository {
  final List<CourseEntity> savedCourses = <CourseEntity>[];

  @override
  Future<void> createReferenceCourse({
    required int sessionId,
    required int raceId,
  }) async {}

  @override
  Future<CourseEntity?> loadCourse({required int raceId}) async => null;

  @override
  Future<RaceStateEntity> loadCurrentState({
    required int sessionId,
    required int raceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveCourse(
    CourseEntity course, {
    bool publishRemote = false,
  }) async {
    savedCourses.add(course);
  }

  @override
  Future<CourseEntity?> syncCourseFromRemote({required int raceId}) async =>
      null;
}
