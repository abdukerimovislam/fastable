import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastable/bloc/water/water_bloc.dart';
import 'package:fastable/bloc/water/water_event.dart';
import 'package:fastable/bloc/water/water_state.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/services/health_service.dart';

class MockWaterRepository extends Mock implements WaterRepository {}

class MockHealthService extends Mock implements HealthService {}

void main() {
  late MockWaterRepository mockWaterRepository;
  late MockHealthService mockHealthService;
  late WaterBloc waterBloc;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(DateTime(2025, 1, 1));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockWaterRepository = MockWaterRepository();
    mockHealthService = MockHealthService();

    when(() => mockWaterRepository.getHistory()).thenAnswer((_) async => []);
    when(
      () => mockWaterRepository.getWaterForDay(any()),
    ).thenAnswer((_) async => 0);

    waterBloc = WaterBloc(mockWaterRepository, mockHealthService);
  });

  tearDown(() async {
    await waterBloc.close();
  });

  blocTest<WaterBloc, WaterState>(
    'LoadWaterData rebuilds today drinks from saved history when local list is empty',
    build: () => waterBloc,
    setUp: () async {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('water_last_date', today);
      await prefs.setString('today_drinks_json', '[]');
      when(
        () => mockWaterRepository.getWaterForDay(any()),
      ).thenAnswer((_) async => 3);
    },
    act: (bloc) => bloc.add(LoadWaterData()),
    expect: () => [
      isA<WaterState>()
          .having((state) => state.status, 'status', WaterStatus.success)
          .having((state) => state.todayDrinks.length, 'drink count', 3)
          .having((state) => state.totalVolumeMl, 'total volume', 750),
    ],
    verify: (_) async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('today_drinks_json'), isNot('[]'));
      verify(() => mockWaterRepository.getHistory()).called(1);
    },
  );
}
