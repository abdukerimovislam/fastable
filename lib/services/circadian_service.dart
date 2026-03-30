import 'package:fastable/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CircadianService {
  Future<Map<String, DateTime>?> getAccurateSunTimes({
    DateTime? referenceTime,
  }) async {
    try {
      final position = await _determinePosition();
      if (position == null) return null;

      final now = referenceTime ?? DateTime.now();

      DateTime sunrise = _resolveSunrise(position, now);
      DateTime sunset = _resolveSunset(position, now);

      // 3. Цель: Следующий Рассвет.
      // Если сегодняшний рассвет уже прошел (сейчас день или вечер), берем завтрашний.
      if (now.isAfter(sunrise)) {
        final tomorrow = now.add(const Duration(days: 1));
        sunrise = _resolveSunrise(position, tomorrow);
      }

      // 4. Начало: Последний Закат.
      // Закат логически должен быть ДО следующего рассвета.
      if (sunset.isAfter(sunrise)) {
        final yesterday = now.subtract(const Duration(days: 1));
        sunset = _resolveSunset(position, yesterday);
      }

      return {'sunrise': sunrise, 'sunset': sunset};
    } catch (e) {
      appLog("CircadianService Error: $e");
      return null;
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
  }

  DateTime _resolveSunrise(Position position, DateTime date) {
    final sun = getSunriseSunset(
      position.latitude,
      position.longitude,
      date.timeZoneOffset,
      date,
    );
    return DateTime(
      date.year,
      date.month,
      date.day,
      sun.sunrise.hour,
      sun.sunrise.minute,
    );
  }

  DateTime _resolveSunset(Position position, DateTime date) {
    final sun = getSunriseSunset(
      position.latitude,
      position.longitude,
      date.timeZoneOffset,
      date,
    );
    return DateTime(
      date.year,
      date.month,
      date.day,
      sun.sunset.hour,
      sun.sunset.minute,
    );
  }
}
