import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CircadianService {

  /// Возвращает точное локальное время СЛЕДУЮЩЕГО рассвета и ПОСЛЕДНЕГО заката
  Future<Map<String, DateTime>?> getAccurateSunTimes() async {
    try {
      final position = await _determinePosition();
      if (position == null) return null;

      final now = DateTime.now();

      // 1. Получаем данные на сегодня строго по UTC (Без двойных сдвигов!)
      final todaySun = getSunriseSunset(
        position.latitude,
        position.longitude,
        const Duration(), // 0 offset, работаем в чистом UTC
        now.toUtc(),
      );

      // Переводим в локальное время силами самого телефона
      DateTime localSunrise = todaySun.sunrise.toLocal();
      DateTime localSunset = todaySun.sunset.toLocal();

      // 2. Если сегодняшний рассвет уже прошел (например, сейчас вечер),
      // нам нужен рассвет на ЗАВТРА!
      if (now.isAfter(localSunrise)) {
        final tomorrowSun = getSunriseSunset(
          position.latitude,
          position.longitude,
          const Duration(),
          now.add(const Duration(days: 1)).toUtc(),
        );
        localSunrise = tomorrowSun.sunrise.toLocal();
      }

      // 3. Закат должен строго предшествовать следующему рассвету.
      // Если это не так, берем вчерашний закат.
      if (localSunset.isAfter(localSunrise)) {
        final yesterdaySun = getSunriseSunset(
          position.latitude,
          position.longitude,
          const Duration(),
          now.subtract(const Duration(days: 1)).toUtc(),
        );
        localSunset = yesterdaySun.sunset.toLocal();
      }

      return {
        'sunrise': localSunrise,
        'sunset': localSunset,
      };
    } catch (e) {
      debugPrint("CircadianService Error: $e");
      return null;
    }
  }

  /// Проверяет права и получает координаты
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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  }
}