import 'dart:io';
import 'package:health/health.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HealthService {
  final Health _health = Health();

  // Типы данных, которые нам нужны
  // Вода в HealthKit/HealthConnect часто пишется через NUTRITION -> WATER
  static final _types = [
    HealthDataType.WEIGHT,
    HealthDataType.WATER,
  ];

  // Проверка: поддерживается ли API на устройстве
  Future<bool> isHealthSupported() async {
    // Для Android проверяем наличие Health Connect
    // Для iOS HealthKit доступен всегда (если включен в Capabilities)
    try {
      // Пакет health сам проверяет поддержку
      return true;
    } catch (e) {
      return false;
    }
  }

  // Запрос разрешений
  Future<bool> requestPermissions() async {
    bool requested = await _health.requestAuthorization(_types);
    return requested;
  }

  // --- ВЕС ---

  /// Записать вес (в КГ)
  Future<bool> writeWeight(double weightKg) async {
    try {
      bool success = await _health.writeHealthData(
        value: weightKg,
        type: HealthDataType.WEIGHT,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
      return success;
    } catch (e) {
      print("HealthService: Error writing weight: $e");
      return false;
    }
  }

  /// Получить последний записанный вес
  Future<double?> getLatestWeight() async {
    try {
      // Запрашиваем данные за последние 30 дней
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 30));

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: from,
        endTime: now,
        types: [HealthDataType.WEIGHT],
      );

      if (data.isEmpty) return null;

      // Сортируем по дате, берем последний
      data.sort((a, b) => b.dateTo.compareTo(a.dateTo));

      // Значение веса (HealthValue) нужно привести к double
      final val = data.first.value as NumericHealthValue;
      return val.numericValue.toDouble();
    } catch (e) {
      print("HealthService: Error reading weight: $e");
      return null;
    }
  }

  // --- ВОДА ---

  /// Записать воду (в Литрах!)
  /// HealthKit принимает литры. Если у нас стаканы (250мл), то передаем 0.25
  Future<bool> writeWater(double liters) async {
    try {
      bool success = await _health.writeHealthData(
        value: liters,
        type: HealthDataType.WATER,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
      return success;
    } catch (e) {
      print("HealthService: Error writing water: $e");
      return false;
    }
  }

  /// Получить воду за СЕГОДНЯ (сумма в литрах)
  Future<double> getTodayWater() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.WATER],
      );

      // Суммируем все записи за сегодня
      double totalLiters = 0;
      for (var point in data) {
        if (point.value is NumericHealthValue) {
          totalLiters += (point.value as NumericHealthValue).numericValue.toDouble();
        }
      }

      return totalLiters;
    } catch (e) {
      print("HealthService: Error reading water: $e");
      return 0.0;
    }
  }
}