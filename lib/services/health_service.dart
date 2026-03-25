import 'dart:io';
import 'package:health/health.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HealthService {
  final Health _health = Health();

  // 🔥 УБРАЛИ SLEEP_IN_BED, оставили только поддерживаемые Health Connect типы
  static final _types = [
    HealthDataType.WEIGHT,
    HealthDataType.WATER,
    HealthDataType.SLEEP_ASLEEP,      // Сон
    HealthDataType.MENSTRUATION_FLOW, // Цикл
  ];

  static final _permissions = [
    HealthDataAccess.READ_WRITE, // WEIGHT
    HealthDataAccess.READ_WRITE, // WATER
    HealthDataAccess.READ,       // SLEEP_ASLEEP
    HealthDataAccess.READ,       // MENSTRUATION_FLOW
  ];

  Future<bool> isHealthSupported() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      bool requested = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      return requested;
    } catch (e) {
      print("HealthService: Auth Error: $e");
      return false;
    }
  }

  // --- ВЕС ---
  Future<bool> writeWeight(double weightKg) async {
    try {
      return await _health.writeHealthData(
        value: weightKg,
        type: HealthDataType.WEIGHT,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    } catch (e) {
      print("HealthService: Error writing weight: $e");
      return false;
    }
  }

  Future<double?> getLatestWeight() async {
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 365));

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: from,
        endTime: now,
        types: [HealthDataType.WEIGHT],
      );

      if (data.isEmpty) return null;
      data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final val = data.first.value as NumericHealthValue;
      return val.numericValue.toDouble();
    } catch (e) {
      print("HealthService: Error reading weight: $e");
      return null;
    }
  }

  // --- ВОДА ---
  Future<bool> writeWater(double liters) async {
    try {
      return await _health.writeHealthData(
        value: liters,
        type: HealthDataType.WATER,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    } catch (e) {
      print("HealthService: Error writing water: $e");
      return false;
    }
  }

  Future<double> getTodayWater() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.WATER],
      );

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

  // --- СОН ---
  Future<Duration> getLastNightSleep() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final from = DateTime(yesterday.year, yesterday.month, yesterday.day, 12, 0);

      // Запрашиваем ТОЛЬКО SLEEP_ASLEEP
      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: from,
        endTime: now,
        types: [HealthDataType.SLEEP_ASLEEP],
      );

      if (data.isEmpty) return Duration.zero;

      int totalMinutes = 0;
      for (var point in data) {
        final diff = point.dateTo.difference(point.dateFrom);
        totalMinutes += diff.inMinutes;
      }

      if (totalMinutes > 840) totalMinutes = 840;

      return Duration(minutes: totalMinutes);
    } catch (e) {
      print("HealthService: Error reading sleep: $e");
      return Duration.zero;
    }
  }

  // --- ЖЕНСКИЙ ЦИКЛ ---
  Future<int?> getDaysSinceLastMenstruation() async {
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 45));

      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: from,
        endTime: now,
        types: [HealthDataType.MENSTRUATION_FLOW],
      );

      if (data.isEmpty) return null;

      data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final lastPeriodDate = data.first.dateTo;

      return now.difference(lastPeriodDate).inDays;
    } catch (e) {
      print("HealthService: Error reading menstruation: $e");
      return null;
    }
  }
}