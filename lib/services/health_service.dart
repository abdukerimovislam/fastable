import 'dart:io';
import 'package:health/health.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HealthService {
  // Используем библиотеку health
  final Health _health = Health();

  // Типы данных, которые мы хотим читать/писать
  final List<HealthDataType> _types = [
    HealthDataType.WEIGHT,
    HealthDataType.WATER,
    // HealthDataType.STEPS, // Можно добавить шаги в будущем
  ];

  // Проверка и запрос прав доступа
  Future<bool> requestPermissions() async {
    try {
      // Проверяем, поддерживается ли API
      // ВНИМАНИЕ: На iOS симуляторе HealthKit недоступен, будет false
      bool? hasPermissions = await _health.hasPermissions(_types);

      if (hasPermissions == false) {
        // Запрашиваем права
        bool requested = await _health.requestAuthorization(_types);
        return requested;
      }
      return true;
    } catch (e) {
      print("HealthService Error: $e");
      return false;
    }
  }

  // Получение текущего веса из Apple Health / Google Fit
  Future<double?> fetchWeight() async {
    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 30)); // Ищем за последний месяц

      // Получаем список записей веса
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: [HealthDataType.WEIGHT],
      );

      // Очищаем дубликаты
      healthData = _health.removeDuplicates(healthData);

      if (healthData.isNotEmpty) {
        // Берем самую свежую запись
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));

        // Значение веса (в кг)
        // Библиотека health возвращает NumericHealthValue
        var value = healthData.first.value;
        if (value is NumericHealthValue) {
          // Иногда возвращает double, иногда num
          return value.numericValue.toDouble();
        }
      }
    } catch (e) {
      print("Error fetching weight: $e");
    }
    return null;
  }

  // Сохранение веса в Apple Health
  Future<bool> saveWeight(double weight) async {
    try {
      final now = DateTime.now();
      return await _health.writeHealthData(
        value: weight,
        type: HealthDataType.WEIGHT,
        startTime: now,
        endTime: now,
      );
    } catch (e) {
      print("Error saving weight: $e");
      return false;
    }
  }

  // Сохранение воды (в литрах)
  Future<bool> saveWater(double liters) async {
    try {
      final now = DateTime.now();
      return await _health.writeHealthData(
        value: liters,
        type: HealthDataType.WATER,
        startTime: now,
        endTime: now,
      );
    } catch (e) {
      print("Error saving water: $e");
      return false;
    }
  }
}