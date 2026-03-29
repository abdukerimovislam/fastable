import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_event.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/services/haptic_service.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/services/live_activity_services.dart';
import 'package:fastable/services/circadian_service.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/l10n/app_localizations.dart';

// --- MOCKS ---
class MockNotificationService extends Mock implements NotificationService {}

class MockHapticService extends Mock implements HapticService {}

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockLiveActivityService extends Mock implements LiveActivityService {}

class MockCircadianService extends Mock implements CircadianService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late FastingBloc fastingBloc;
  late MockNotificationService mockNotificationService;
  late MockHapticService mockHapticService;
  late MockHistoryRepository mockHistoryRepository;
  late MockLiveActivityService mockLiveActivityService;
  late MockCircadianService mockCircadianService;

  // Регистрируем Fallback значения один раз перед всеми тестами
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(Duration.zero);
    registerFallbackValue(DateTime.now());
    registerFallbackValue(MockAppLocalizations());
    // Регистрируем заглушку для FastingRecord
    registerFallbackValue(
      FastingRecord(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        duration: Duration.zero,
        mood: FastingMood.great,
      ),
    );
  });

  setUp(() {
    // 1. Инициализируем моки
    mockNotificationService = MockNotificationService();
    mockHapticService = MockHapticService();
    mockHistoryRepository = MockHistoryRepository();
    mockLiveActivityService = MockLiveActivityService();
    mockCircadianService = MockCircadianService();

    // 2. Имитируем SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // 3. Настраиваем заглушки (Stubs)
    when(() => mockHapticService.mediumImpact()).thenAnswer((_) async {});
    when(() => mockHapticService.success()).thenAnswer((_) async {});

    // ВНИМАНИЕ: Исправленный синтаксис для named arguments
    when(
      () => mockNotificationService.scheduleFastingNotifications(
        startTime: any(named: 'startTime'),
        duration: any(named: 'duration'),
        l10n: any(named: 'l10n'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockNotificationService.scheduleEatingNotifications(
        startTime: any(named: 'startTime'),
        duration: any(named: 'duration'),
        l10n: any(named: 'l10n'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockNotificationService.cancelAllFastingNotifications(),
    ).thenAnswer((_) async {});
    when(
      () => mockLiveActivityService.startFastingActivity(
        startTime: any(named: 'startTime'),
        goalDuration: any(named: 'goalDuration'),
        phaseName: any(named: 'phaseName'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockLiveActivityService.stopActivity()).thenAnswer((_) async {});
    when(
      () => mockCircadianService.getAccurateSunTimes(
        referenceTime: any(named: 'referenceTime'),
      ),
    ).thenAnswer((_) async => null);

    // Тут any() работает, так как мы зарегистрировали Fallback для FastingRecord
    when(() => mockHistoryRepository.addRecord(any())).thenAnswer((_) async {});

    // 4. Инициализируем Блок (В КОНЦЕ!)
    fastingBloc = FastingBloc(
      mockNotificationService,
      mockHapticService,
      mockHistoryRepository,
      mockLiveActivityService,
      mockCircadianService,
    );
  });

  tearDown(() {
    fastingBloc.close();
  });

  group('FastingBloc Logic Tests', () {
    test('copyWith clears startTime when explicitly set to null', () {
      final state = FastingState(
        phase: FastingPhase.fasting,
        startTime: DateTime(2025),
      );

      final cleared = state.copyWith(startTime: null);

      expect(cleared.startTime, isNull);
    });

    test('initial state is correct', () {
      expect(fastingBloc.state.phase, FastingPhase.stopped);
      expect(fastingBloc.state.elapsed, Duration.zero);
    });

    blocTest<FastingBloc, FastingState>(
      'StartFasting event changes phase to .fasting',
      build: () => fastingBloc,
      act: (bloc) => bloc.add(StartFasting(startTime: DateTime.now())),
      expect: () => [
        isA<FastingState>()
            .having((s) => s.phase, 'phase', FastingPhase.fasting)
            .having((s) => s.startTime, 'startTime', isNotNull),
      ],
    );

    blocTest<FastingBloc, FastingState>(
      'StartFasting uses saved app locale for notification scheduling',
      build: () => fastingBloc,
      act: (bloc) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('locale_code', 'ru');
        bloc.add(StartFasting(startTime: DateTime.now()));
      },
      expect: () => [
        isA<FastingState>().having(
          (s) => s.phase,
          'phase',
          FastingPhase.fasting,
        ),
      ],
      verify: (_) {
        final capturedL10n =
            verify(
                  () => mockNotificationService.scheduleFastingNotifications(
                    startTime: any(named: 'startTime'),
                    duration: any(named: 'duration'),
                    l10n: captureAny(named: 'l10n'),
                  ),
                ).captured.single
                as AppLocalizations;

        expect(capturedL10n.localeName, 'ru');
      },
    );

    blocTest<FastingBloc, FastingState>(
      'TickTimer event updates elapsed time',
      build: () => fastingBloc,
      seed: () => const FastingState(
        phase: FastingPhase.fasting,
        goalDuration: Duration(hours: 16),
      ),
      act: (bloc) => bloc.add(const TickTimer(Duration(hours: 1))),
      expect: () => [
        isA<FastingState>()
            .having((s) => s.elapsed, 'elapsed', const Duration(hours: 1))
            .having((s) => s.isGoalReached, 'isGoalReached', false),
      ],
    );

    blocTest<FastingBloc, FastingState>(
      'TickTimer sets isGoalReached to true when time is up',
      build: () => fastingBloc,
      seed: () => const FastingState(
        phase: FastingPhase.fasting,
        goalDuration: Duration(hours: 16),
      ),
      act: (bloc) => bloc.add(const TickTimer(Duration(hours: 16, minutes: 1))),
      expect: () => [
        isA<FastingState>().having(
          (s) => s.isGoalReached,
          'isGoalReached',
          true,
        ),
      ],
    );

    // ТЕСТ 5: Завершение (исправленный)
    final startTime = DateTime.now().subtract(const Duration(hours: 16));
    final endTime = DateTime.now();

    blocTest<FastingBloc, FastingState>(
      'EndFasting saves record and switches to eating phase',
      build: () => fastingBloc,
      seed: () => FastingState(
        phase: FastingPhase.fasting,
        startTime: startTime,
        planIndex: 0,
      ),
      act: (bloc) =>
          bloc.add(EndFasting(endTime: endTime, mood: FastingMood.great)),
      expect: () => [
        isA<FastingState>().having(
          (s) => s.phase,
          'phase',
          FastingPhase.eating,
        ),
      ],
      verify: (_) {
        // Проверяем, что метод был вызван с любым аргументом
        verify(() => mockHistoryRepository.addRecord(any())).called(1);
      },
    );

    blocTest<FastingBloc, FastingState>(
      'EndFasting normalizes saved symptom ids and stores localized note',
      build: () => fastingBloc,
      seed: () => FastingState(
        phase: FastingPhase.fasting,
        startTime: startTime,
        planIndex: 0,
      ),
      act: (bloc) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('current_fast_symptoms', [
          'Energy',
          'headache',
          'Energy',
        ]);
        bloc.add(EndFasting(endTime: endTime, mood: FastingMood.good));
      },
      expect: () => [
        isA<FastingState>().having(
          (s) => s.phase,
          'phase',
          FastingPhase.eating,
        ),
      ],
      verify: (_) {
        final record =
            verify(
                  () => mockHistoryRepository.addRecord(captureAny()),
                ).captured.last
                as FastingRecord;
        expect(record.note, 'Symptoms: Energy, Headache');
      },
    );

    blocTest<FastingBloc, FastingState>(
      'ResetFasting clears start time and returns bloc to stopped state',
      build: () => fastingBloc,
      seed: () => FastingState(
        phase: FastingPhase.eating,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        elapsed: const Duration(hours: 1),
        planIndex: 1,
      ),
      act: (bloc) => bloc.add(ResetFasting()),
      expect: () => [
        isA<FastingState>()
            .having((s) => s.phase, 'phase', FastingPhase.stopped)
            .having((s) => s.startTime, 'startTime', isNull)
            .having((s) => s.elapsed, 'elapsed', Duration.zero)
            .having(
              (s) => s.goalDuration,
              'goalDuration',
              const Duration(hours: 18),
            ),
      ],
      verify: (_) {
        verify(
          () => mockNotificationService.cancelAllFastingNotifications(),
        ).called(1);
      },
    );

    blocTest<FastingBloc, FastingState>(
      'EndFasting ignores an end time that is earlier than the start time',
      build: () => fastingBloc,
      seed: () => FastingState(
        phase: FastingPhase.fasting,
        startTime: startTime,
        planIndex: 0,
      ),
      act: (bloc) => bloc.add(
        EndFasting(
          endTime: startTime.subtract(const Duration(minutes: 1)),
          mood: FastingMood.bad,
        ),
      ),
      expect: () => <FastingState>[],
      verify: (_) {
        verifyNever(() => mockHistoryRepository.addRecord(any()));
        verifyNever(
          () => mockNotificationService.scheduleEatingNotifications(
            startTime: any(named: 'startTime'),
            duration: any(named: 'duration'),
            l10n: any(named: 'l10n'),
          ),
        );
      },
    );

    blocTest<FastingBloc, FastingState>(
      'StartCircadianFast keeps circadian plan and enters fasting phase',
      build: () => fastingBloc,
      act: (bloc) =>
          bloc.add(const StartCircadianFast(Duration(hours: 12, minutes: 30))),
      expect: () => [
        isA<FastingState>()
            .having(
              (s) => s.planIndex,
              'planIndex',
              FastingState.circadianPlanIndex,
            )
            .having(
              (s) => s.goalDuration,
              'goalDuration',
              const Duration(hours: 12, minutes: 30),
            ),
        isA<FastingState>()
            .having((s) => s.phase, 'phase', FastingPhase.fasting)
            .having(
              (s) => s.planIndex,
              'planIndex',
              FastingState.circadianPlanIndex,
            )
            .having(
              (s) => s.goalDuration,
              'goalDuration',
              const Duration(hours: 12, minutes: 30),
            ),
      ],
    );

    blocTest<FastingBloc, FastingState>(
      'StartFasting refreshes circadian duration from solar times',
      build: () {
        when(
          () => mockCircadianService.getAccurateSunTimes(
            referenceTime: any(named: 'referenceTime'),
          ),
        ).thenAnswer((invocation) async {
          final reference =
              invocation.namedArguments[#referenceTime] as DateTime;
          return {
            'sunrise': reference.add(const Duration(hours: 10)),
            'sunset': reference.subtract(const Duration(hours: 2)),
          };
        });
        return fastingBloc;
      },
      seed: () => const FastingState(
        phase: FastingPhase.stopped,
        planIndex: FastingState.circadianPlanIndex,
        goalDuration: Duration(hours: 14),
      ),
      act: (bloc) =>
          bloc.add(StartFasting(startTime: DateTime(2025, 1, 2, 21))),
      expect: () => [
        isA<FastingState>()
            .having((s) => s.phase, 'phase', FastingPhase.fasting)
            .having(
              (s) => s.goalDuration,
              'goalDuration',
              const Duration(hours: 10),
            )
            .having(
              (s) => s.planIndex,
              'planIndex',
              FastingState.circadianPlanIndex,
            ),
      ],
    );
  });
}
