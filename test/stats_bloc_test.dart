import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fastable/bloc/stats/stats_bloc.dart';
import 'package:fastable/bloc/stats/stats_event.dart';
import 'package:fastable/bloc/stats/stats_state.dart';
import 'package:fastable/models/fasting_record.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/services/achievement_service.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

void main() {
  late MockHistoryRepository mockHistoryRepository;
  late StatsBloc statsBloc;
  late StreamController<List<FastingRecord>> recordsController;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() {
    mockHistoryRepository = MockHistoryRepository();
    recordsController = StreamController<List<FastingRecord>>.broadcast();

    when(
      () => mockHistoryRepository.getRecordsStream(),
    ).thenAnswer((_) => recordsController.stream);
    when(() => mockHistoryRepository.currentRecords).thenReturn(const []);
    when(() => mockHistoryRepository.calculateStreak()).thenReturn(0);
    when(() => mockHistoryRepository.calculateLongestStreak()).thenReturn(0);

    statsBloc = StatsBloc(mockHistoryRepository, AchievementService());
  });

  tearDown(() async {
    await recordsController.close();
    await statsBloc.close();
  });

  blocTest<StatsBloc, StatsState>(
    'StatsUpdated resets metrics and achievements when history is empty',
    build: () => statsBloc,
    seed: () => const StatsState(
      status: StatsStatus.success,
      totalFasts: 12,
      totalHours: 144,
      currentStreak: 5,
      longestStreak: 7,
      averageDuration: 12,
      successRate: 80,
      weeklyChartData: [5, 4, 3, 2, 1, 0, 0],
      maxChartValue: 30,
    ),
    act: (bloc) => bloc.add(const StatsUpdated()),
    expect: () => [
      const StatsState(
        status: StatsStatus.success,
        weeklyChartData: [0, 0, 0, 0, 0, 0, 0],
        maxChartValue: 24.0,
        unlockedAchievements: [],
      ),
    ],
  );

  blocTest<StatsBloc, StatsState>(
    'StatsUpdated computes achievements from fasting history',
    build: () => statsBloc,
    setUp: () {
      final now = DateTime.now();
      final records = List<FastingRecord>.generate(
        10,
        (index) => FastingRecord(
          startTime: now.subtract(Duration(days: 9 - index, hours: 16)),
          endTime: now.subtract(Duration(days: 9 - index)),
          duration: const Duration(hours: 16),
        ),
      );

      when(() => mockHistoryRepository.currentRecords).thenReturn(records);
      when(() => mockHistoryRepository.calculateStreak()).thenReturn(10);
      when(() => mockHistoryRepository.calculateLongestStreak()).thenReturn(10);
    },
    act: (bloc) => bloc.add(const StatsUpdated()),
    expect: () => [
      isA<StatsState>()
          .having((state) => state.status, 'status', StatsStatus.success)
          .having((state) => state.totalFasts, 'totalFasts', 10)
          .having((state) => state.currentStreak, 'currentStreak', 10)
          .having((state) => state.longestStreak, 'longestStreak', 10)
          .having(
            (state) => state.unlockedAchievements.length,
            'achievement count',
            5,
          ),
    ],
  );
}
