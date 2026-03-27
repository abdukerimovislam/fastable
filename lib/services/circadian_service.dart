import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CircadianService {

  /// Получает локальное время заката и рассвета для текущей геопозиции
  Future<SunriseSunsetResult?> getTodaySunTimes() async {
    try {
      final position = await _determinePosition();
      if (position == null) return null;

      final now = DateTime.now();
      // Высчитываем закат и рассвет с учетом часового пояса
      final sunTimes = getSunriseSunset(
        position.latitude,
        position.longitude,
        Duration(hours: now.timeZoneOffset.inHours),
        now,
      );

      return sunTimes;
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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low); // low достаточно для заката
  }
}