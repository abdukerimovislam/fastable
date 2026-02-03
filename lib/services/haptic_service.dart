import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Сервис для управления тактильным откликом (вибрацией).
/// Придает приложению ощущение физического взаимодействия (Apple-feel).
@lazySingleton
class HapticService {

  /// Легкий удар (например, при переключении табов или нажатии небольших кнопок)
  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Средний удар (например, при открытии диалога или выборе важной опции)
  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Тяжелый удар (например, при старте/стопе таймера)
  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Успех (мягкая двойная вибрация)
  Future<void> success() async {
    // Используем системный паттерн, если доступен, или эмулируем
    await SystemChannels.platform.invokeMethod<void>('HapticFeedback.vibrate');
  }

  /// Ошибка (резкая вибрация)
  Future<void> error() async {
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.vibrate();
  }

  /// Выбор элемента (например, прокрутка колеса времени)
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }
}