import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/core/network/api_exception.dart';
import 'package:vkr_regatta/src/features/api/models/api_models.dart';
import 'package:vkr_regatta/src/features/judge/application/judge_race_flow_service.dart';
import 'package:vkr_regatta/src/features/judge/domain/judge_action_entity.dart';
import 'package:vkr_regatta/src/features/judge/domain/judge_flow_failure.dart';
import 'package:vkr_regatta/src/features/judge/domain/judge_local_repository.dart';
import 'package:vkr_regatta/src/features/judge/domain/judge_race_context_entity.dart';
import 'package:vkr_regatta/src/features/judge/domain/judge_race_repository.dart';
import 'package:vkr_regatta/src/features/judge/domain/judge_race_status.dart';

void main() {
  group('JudgeRaceFlowService', () {
    test(
      'createRace validates minimum unique participants before backend',
      () async {
        final repository = _FakeJudgeRaceRepository();
        final localRepository = _FakeJudgeLocalRepository();
        final service = JudgeRaceFlowService(
          judgeRaceRepository: repository,
          judgeLocalRepository: localRepository,
        );

        await expectLater(
          service.createRace(
            participantIds: const [101, 101, 202],
            judgeIds: const [7, 101],
          ),
          throwsA(
            isA<JudgeFlowFailure>().having(
              (error) => error.message,
              'message',
              contains('At least 3 unique participant ids are required.'),
            ),
          ),
        );
        expect(repository.createCalls, isEmpty);
        expect(localRepository.actions, isEmpty);
      },
    );

    test('createRace rejects overlapping participant and judge ids', () async {
      final repository = _FakeJudgeRaceRepository();
      final localRepository = _FakeJudgeLocalRepository();
      final service = JudgeRaceFlowService(
        judgeRaceRepository: repository,
        judgeLocalRepository: localRepository,
      );

      await expectLater(
        service.createRace(
          participantIds: const [101, 102, 103],
          judgeIds: const [7, 101],
        ),
        throwsA(
          isA<JudgeFlowFailure>().having(
            (error) => error.message,
            'message',
            contains('must not overlap'),
          ),
        ),
      );
      expect(repository.createCalls, isEmpty);
    });

    test('createRace stores local context and race_created action', () async {
      final repository = _FakeJudgeRaceRepository(createdRaceId: 3210);
      final localRepository = _FakeJudgeLocalRepository();
      final service = JudgeRaceFlowService(
        judgeRaceRepository: repository,
        judgeLocalRepository: localRepository,
      );

      final result = await service.createRace(
        participantIds: const [101, 102, 103],
        judgeIds: const [1, 2],
      );

      expect(result.value, 3210);
      expect(result.context.lastRaceId, 3210);
      expect(result.context.status, JudgeRaceStatus.created);
      expect(localRepository.context.lastRaceId, 3210);
      expect(localRepository.context.status, JudgeRaceStatus.created);
      expect(localRepository.actions.single.eventType, 'race_created');
    });

    test('restoreContext returns persisted local snapshot', () async {
      final localRepository = _FakeJudgeLocalRepository(
        initialContext: JudgeRaceContextEntity(
          lastRaceId: 99,
          status: JudgeRaceStatus.started,
          lastJudgeActionAtUtc: DateTime.utc(2026, 4, 29, 12, 0, 0),
        ),
        initialActions: <JudgeActionEntity>[
          JudgeActionEntity(
            eventId: 'a-1',
            raceId: 99,
            eventType: 'race_started',
            payloadJson: '{"backendMessage":"ok"}',
            createdAtUtc: DateTime.utc(2026, 4, 29, 12, 0, 0),
            syncStatus: 'pending',
          ),
        ],
      );
      final service = JudgeRaceFlowService(
        judgeRaceRepository: _FakeJudgeRaceRepository(),
        judgeLocalRepository: localRepository,
      );

      final restoredContext = await service.restoreContext();
      final restoredActions = await service.loadRecentActions();

      expect(restoredContext.lastRaceId, 99);
      expect(restoredContext.status, JudgeRaceStatus.started);
      expect(restoredActions, hasLength(1));
      expect(restoredActions.single.eventType, 'race_started');
    });

    test(
      'startRace blocks duplicate local start attempts for same race',
      () async {
        final repository = _FakeJudgeRaceRepository();
        final localRepository = _FakeJudgeLocalRepository(
          initialContext: const JudgeRaceContextEntity(
            lastRaceId: 77,
            status: JudgeRaceStatus.started,
          ),
        );
        final service = JudgeRaceFlowService(
          judgeRaceRepository: repository,
          judgeLocalRepository: localRepository,
        );

        await expectLater(
          service.startRace(raceId: 77),
          throwsA(
            isA<JudgeFlowFailure>().having(
              (error) => error.message,
              'message',
              contains('already been started locally'),
            ),
          ),
        );
        expect(repository.startCalls, isEmpty);
      },
    );

    test(
      'startRace logs start_requested and race_started on success',
      () async {
        final repository = _FakeJudgeRaceRepository(
          startMessage: 'Race 77 started',
        );
        final localRepository = _FakeJudgeLocalRepository(
          initialContext: const JudgeRaceContextEntity(
            lastRaceId: 77,
            status: JudgeRaceStatus.created,
          ),
        );
        final service = JudgeRaceFlowService(
          judgeRaceRepository: repository,
          judgeLocalRepository: localRepository,
        );

        final result = await service.startRace(raceId: 77);

        expect(result.context.status, JudgeRaceStatus.started);
        expect(localRepository.context.status, JudgeRaceStatus.started);
        expect(
          localRepository.actions.map((action) => action.eventType),
          <String>['start_requested', 'race_started'],
        );
      },
    );

    test(
      'endRace blocks duplicate local finish attempts for same race',
      () async {
        final repository = _FakeJudgeRaceRepository();
        final localRepository = _FakeJudgeLocalRepository(
          initialContext: const JudgeRaceContextEntity(
            lastRaceId: 88,
            status: JudgeRaceStatus.finished,
          ),
        );
        final service = JudgeRaceFlowService(
          judgeRaceRepository: repository,
          judgeLocalRepository: localRepository,
        );

        await expectLater(
          service.endRace(raceId: 88),
          throwsA(
            isA<JudgeFlowFailure>().having(
              (error) => error.message,
              'message',
              contains('already been finished locally'),
            ),
          ),
        );
        expect(repository.endCalls, isEmpty);
      },
    );

    test('maps 401 and 403 backend failures to friendly messages', () async {
      final service401 = JudgeRaceFlowService(
        judgeRaceRepository: _FakeJudgeRaceRepository(
          startError: ApiException(statusCode: 401, message: 'auth expired'),
        ),
        judgeLocalRepository: _FakeJudgeLocalRepository(),
      );
      final service403 = JudgeRaceFlowService(
        judgeRaceRepository: _FakeJudgeRaceRepository(
          endError: ApiException(statusCode: 403, message: 'forbidden'),
        ),
        judgeLocalRepository: _FakeJudgeLocalRepository(),
      );

      await expectLater(
        service401.startRace(raceId: 1),
        throwsA(
          isA<JudgeFlowFailure>().having(
            (error) => error.message,
            'message',
            'Judge session expired. Please sign in again.',
          ),
        ),
      );
      await expectLater(
        service403.endRace(raceId: 1),
        throwsA(
          isA<JudgeFlowFailure>().having(
            (error) => error.message,
            'message',
            'You do not have permission to perform this judge action.',
          ),
        ),
      );
    });

    test('maps 409 backend failures to race state guidance', () async {
      final service = JudgeRaceFlowService(
        judgeRaceRepository: _FakeJudgeRaceRepository(
          startError: ApiException(statusCode: 409, message: 'already active'),
        ),
        judgeLocalRepository: _FakeJudgeLocalRepository(),
      );

      await expectLater(
        service.startRace(raceId: 5),
        throwsA(
          isA<JudgeFlowFailure>().having(
            (error) => error.message,
            'message',
            'This race is already in the requested state on the backend.',
          ),
        ),
      );
    });

    test('scheduleStartProcedure stores local countdown configuration', () async {
      final localRepository = _FakeJudgeLocalRepository(
        initialContext: const JudgeRaceContextEntity(
          lastRaceId: 55,
          status: JudgeRaceStatus.created,
        ),
      );
      final service = JudgeRaceFlowService(
        judgeRaceRepository: _FakeJudgeRaceRepository(),
        judgeLocalRepository: localRepository,
      );

      final result = await service.scheduleStartProcedure(
        raceId: 55,
        duration: const Duration(minutes: 5),
      );

      expect(result.context.lastRaceId, 55);
      expect(localRepository.actions.last.eventType, 'start_procedure_configured');
      expect(
        localRepository.actions.last.payloadJson,
        contains('"durationSeconds":300'),
      );
    });
  });
}

class _FakeJudgeRaceRepository implements JudgeRaceRepository {
  _FakeJudgeRaceRepository({
    this.createdRaceId = 2001,
    this.startMessage = 'started',
    this.startError,
    this.endError,
  });

  final int createdRaceId;
  final String startMessage;
  final Object? startError;
  final Object? endError;
  final List<Map<String, List<int>>> createCalls = <Map<String, List<int>>>[];
  final List<int> startCalls = <int>[];
  final List<int> endCalls = <int>[];
  final List<String> publishedEventIds = <String>[];

  @override
  Future<int> createRace({
    required List<int> participantIds,
    required List<int> judgeIds,
  }) async {
    createCalls.add(<String, List<int>>{
      'participantIds': participantIds,
      'judgeIds': judgeIds,
    });
    return createdRaceId;
  }

  @override
  Future<String> endRace({required int raceId}) async {
    if (endError != null) {
      throw endError!;
    }
    endCalls.add(raceId);
    return 'finished';
  }

  @override
  Future<String> startRace({required int raceId}) async {
    if (startError != null) {
      throw startError!;
    }
    startCalls.add(raceId);
    return startMessage;
  }

  @override
  Future<List<RaceSummaryDto>> loadMyRaces() async {
    return const <RaceSummaryDto>[];
  }

  @override
  Future<RaceDetailDto> loadRaceDetails({required int raceId}) async {
    return RaceDetailDto(
      raceId: raceId,
      status: RaceStatus.notStarted,
      participants: const <UserSummaryDto>[],
      judges: const <UserSummaryDto>[],
    );
  }

  @override
  Future<void> publishRaceEvent({
    required int raceId,
    required String eventId,
    required String eventType,
    required Map<String, Object?> payload,
  }) async {
    publishedEventIds.add(eventId);
  }

  @override
  Future<List<UserSummaryDto>> searchUsers({
    required UserRole role,
    String? query,
  }) async {
    return const <UserSummaryDto>[];
  }
}

class _FakeJudgeLocalRepository implements JudgeLocalRepository {
  _FakeJudgeLocalRepository({
    JudgeRaceContextEntity? initialContext,
    List<JudgeActionEntity>? initialActions,
  }) : context = initialContext ?? JudgeRaceContextEntity.empty,
       actions = List<JudgeActionEntity>.from(
         initialActions ?? const <JudgeActionEntity>[],
       );

  JudgeRaceContextEntity context;
  final List<JudgeActionEntity> actions;

  @override
  Future<void> appendAction(JudgeActionEntity action) async {
    actions.add(action);
  }

  @override
  Future<JudgeRaceContextEntity> loadContext() async => context;

  @override
  Future<List<JudgeActionEntity>> loadRecentActions({int limit = 20}) async {
    return actions.reversed.take(limit).toList(growable: false);
  }

  @override
  Future<void> saveContext(JudgeRaceContextEntity nextContext) async {
    context = nextContext;
  }
}
