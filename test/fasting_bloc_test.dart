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
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/l10n/app_localizations.dart';

// --- MOCKS ---
class MockNotificationService extends Mock implements NotificationService {}
class MockHapticService extends Mock implements HapticService {}
class MockHistoryRepository extends Mock implements HistoryRepository {}
class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late FastingBloc fastingBloc;
  late MockNotificationService mockNotificationService;
  late MockHapticService mockHapticService;
  late MockHistoryRepository mockHistoryRepository;

  // Регистрируем Fallback значения один раз перед всеми тестами
  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue(DateTime.now());
    registerFallbackValue(MockAppLocalizations());
    // Регистрируем заглушку для FastingRecord
    registerFallbackValue(FastingRecord(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        duration: Duration.zero,
        mood: FastingMood.great
    ));
  });

  setUp(() {
    // 1. Инициализируем моки
    mockNotificationService = MockNotificationService();
    mockHapticService = MockHapticService();
    mockHistoryRepository = MockHistoryRepository();

    // 2. Имитируем SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // 3. Настраиваем заглушки (Stubs)
    when(() => mockHapticService.mediumImpact()).thenAnswer((_) async {});
    when(() => mockHapticService.success()).thenAnswer((_) async {});

    // ВНИМАНИЕ: Исправленный синтаксис для named arguments
    when(() => mockNotificationService.scheduleFastingNotifications(
      startTime: any(named: 'startTime'),
      duration: any(named: 'duration'),
      l10n: any(named: 'l10n'),
    )).thenAnswer((_) async {});

    when(() => mockNotificationService.scheduleEatingNotifications(
      startTime: any(named: 'startTime'),
      duration: any(named: 'duration'),
      l10n: any(named: 'l10n'),
    )).thenAnswer((_) async {});

    when(() => mockNotificationService.cancelAllFastingNotifications())
        .thenAnswer((_) async {});

    // Тут any() работает, так как мы зарегистрировали Fallback для FastingRecord
    when(() => mockHistoryRepository.addRecord(any()))
        .thenAnswer((_) async {});

    // 4. Инициализируем Блок (В КОНЦЕ!)
    fastingBloc = FastingBloc(
      mockNotificationService,
      mockHapticService,
      mockHistoryRepository,
    );
  });

  tearDown(() {
    fastingBloc.close();
  });

  group('FastingBloc Logic Tests', () {

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
        isA<FastingState>()
            .having((s) => s.isGoalReached, 'isGoalReached', true),
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
      act: (bloc) => bloc.add(EndFasting(endTime: endTime, mood: FastingMood.great)),
      expect: () => [
        isA<FastingState>()
            .having((s) => s.phase, 'phase', FastingPhase.eating),
      ],
      verify: (_) {
        // Проверяем, что метод был вызван с любым аргументом
        verify(() => mockHistoryRepository.addRecord(any())).called(1);
      },
    );
  });
}