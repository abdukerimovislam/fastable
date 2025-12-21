import 'package:geolocator/geolocator.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';

enum CircadianPhase {
  sunrise,    // Пробуждение, кортизол растет
  day,        // Пик активности
  sunset,     // Закат, начало подготовки ко сну
  evening,    // Выработка мелатонина (нужно прекратить есть)
  night       // Глубокий сон, гормон роста
}

class CircadianData {
  final DateTime sunrise;
  final DateTime sunset;
  final CircadianPhase currentPhase;
  final String advice;
  final String phaseName;

  CircadianData({
    required this.sunrise,
    required this.sunset,
    required this.currentPhase,
    required this.advice,
    required this.phaseName,
  });
}

class CircadianService {
  // Синглтон
  static final CircadianService _instance = CircadianService._internal();
  factory CircadianService() => _instance;
  CircadianService._internal();

  // Кэшируем позицию, чтобы не дергать GPS постоянно
  Position? _lastPosition;

  // Главный метод: Получить данные
  // Главный метод: Получить данные
  Future<CircadianData?> getCircadianData() async {
    try {
      final position = await _determinePosition();
      if (position == null) return null;

      final now = DateTime.now();

      // Считаем солнце
      final solarResults = getSunriseSunset(
        position.latitude,
        position.longitude,
        now.timeZoneOffset, // <-- ТУТ БЫЛА ОШИБКА. Теперь мы берем реальный оффсет.
        now,
      );

      final sunrise = solarResults.sunrise;
      final sunset = solarResults.sunset;

      // Определяем фазу
      final phase = _calculatePhase(now, sunrise, sunset);

      return CircadianData(
        sunrise: sunrise,
        sunset: sunset,
        currentPhase: phase,
        phaseName: _getPhaseName(phase),
        advice: _getAdvice(phase),
      );
    } catch (e) {
      print("Circadian Error: $e");
      return null;
    }
  }
  CircadianPhase _calculatePhase(DateTime now, DateTime sunrise, DateTime sunset) {
    // Усложненная логика фаз
    if (now.isAfter(sunrise.subtract(const Duration(minutes: 30))) &&
        now.isBefore(sunrise.add(const Duration(hours: 2)))) {
      return CircadianPhase.sunrise;
    }
    if (now.isAfter(sunrise) && now.isBefore(sunset.subtract(const Duration(hours: 2)))) {
      return CircadianPhase.day;
    }
    if (now.isAfter(sunset.subtract(const Duration(hours: 2))) &&
        now.isBefore(sunset.add(const Duration(minutes: 30)))) {
      return CircadianPhase.sunset;
    }
    if (now.isAfter(sunset) && now.isBefore(sunset.add(const Duration(hours: 4)))) {
      return CircadianPhase.evening;
    }
    return CircadianPhase.night;
  }

  String _getPhaseName(CircadianPhase phase) {
    switch (phase) {
      case CircadianPhase.sunrise: return "Sunrise Awakening";
      case CircadianPhase.day: return "Peak Metabolism";
      case CircadianPhase.sunset: return "Sunset Wind-down";
      case CircadianPhase.evening: return "Melatonin Rising";
      case CircadianPhase.night: return "Deep Repair";
    }
  }

  String _getAdvice(CircadianPhase phase) {
    switch (phase) {
      case CircadianPhase.sunrise:
        return "Get sunlight in your eyes to reset your clock. Drink water.";
      case CircadianPhase.day:
        return "Best time for biggest meal. Digestion is strongest.";
      case CircadianPhase.sunset:
        return "Sun is setting. Last chance to eat before melatonin spikes.";
      case CircadianPhase.evening:
        return "Stop eating. Food now will disrupt sleep and fat burn.";
      case CircadianPhase.night:
        return "Body is repairing. Ideally, you are fasting now.";
    }
  }

  // Получение локации (стандартный код для geolocator)
  Future<Position?> _determinePosition() async {
    if (_lastPosition != null) return _lastPosition;

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

    _lastPosition = await Geolocator.getCurrentPosition();
    return _lastPosition;
  }
}