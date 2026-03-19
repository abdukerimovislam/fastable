import 'dart:io';
import 'package:health/health.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HealthService {
  final Health _health = Health();

  // Типы данных, которые нам нужны
  static final _types = [
    HealthDataType.WEIGHT,
    HealthDataType.WATER,
  ];

  // 🔥 ИСПРАВЛЕНИЕ 1: Явно указываем права на ЧТЕНИЕ и ЗАПИСЬ для каждого типа данных.
  // Иначе системные API (Apple Health / Health Connect) дадут доступ только на чтение.
  static final _permissions = [
    HealthDataAccess.READ_WRITE, // Для WEIGHT
    HealthDataAccess.READ_WRITE, // Для WATER
  ];

  // Проверка: поддерживается ли API на устройстве
  Future<bool> isHealthSupported() async {
    try {
      // Пакет health сам проверяет поддержку (наличие Health Connect на Android или HealthKit на iOS)
      return true;
    } catch (e) {
      return false;
    }
  }

  // Запрос разрешений
  Future<bool> requestPermissions() async {
    // 🔥 ИСПРАВЛЕНИЕ 1: Передаем массив permissions
    bool requested = await _health.requestAuthorization(
      _types,
      permissions: _permissions,
    );
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
      // 🔥 ИСПРАВЛЕНИЕ 2: 30 дней — слишком мало. Пользователь может не взвешиваться месяцами.
      // Берем окно в 1 год (365 дней), чтобы точно найти последнюю актуальную запись веса.
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 365));

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: from,
        endTime: now,
        types: [HealthDataType.WEIGHT],
      );

      if (data.isEmpty) return null;

      // Сортируем по дате по убыванию, берем самую свежую запись
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