import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProService {
  // ⚠️ ВАЖНО: Вставьте сюда ваш реальный ключ RevenueCat для iOS
  // Ключ для Android не нужен, так как там нет подписок.
  final String _apiKeyIOS = 'appl_YOUR_IOS_KEY';

  bool _isInitialized = false;

  /// Инициализация сервиса покупок
  Future<void> init() async {
    // Если это Android, мы просто выходим. RevenueCat не нужен.
    if (Platform.isAndroid) return;

    if (_isInitialized) return;

    // Настройка логов для отладки (можно убрать в релизе или поставить LogLevel.error)
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyIOS);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      _isInitialized = true;
    }
  }

  /// Проверка статуса подписки
  Future<bool> checkProStatus() async {
    if (Platform.isAndroid) return false; // На Андроиде всегда "Не PRO"

    try {
      if (!_isInitialized) await init();
      final customerInfo = await Purchases.getCustomerInfo();
      // Проверяем наличие активного права доступа 'pro'
      return customerInfo.entitlements.all['pro']?.isActive ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Получение доступных тарифов
  Future<List<Package>> fetchOfferings() async {
    if (Platform.isAndroid) return []; // Нет тарифов

    try {
      if (!_isInitialized) await init();
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } on PlatformException catch (_) {
      return [];
    }
  }

  /// Покупка пакета (Исправлена ошибка с PurchaseResult)
  Future<bool> purchasePackage(Package package) async {
    if (Platform.isAndroid) return false;

    try {
      // 1. Совершаем покупку
      // Используем dynamic, чтобы обработать и CustomerInfo, и PurchaseResult
      final dynamic result = await Purchases.purchasePackage(package);

      // 2. Извлекаем CustomerInfo
      CustomerInfo customerInfo;
      try {
        // Если вернулся PurchaseResult (как в ошибке), берем из него customerInfo
        customerInfo = result.customerInfo;
      } catch (_) {
        // Если вернулся сразу CustomerInfo (в других версиях), используем его
        customerInfo = result;
      }

      // 3. Проверяем подписку
      return customerInfo.entitlements.all['pro']?.isActive ?? false;
    } on PlatformException catch (e) {
      // Ошибка покупки или отмена пользователем
      print("Purchase Error: $e");
      return false;
    }
  }

  /// Восстановление покупок
  Future<bool> restorePurchases() async {
    if (Platform.isAndroid) return false;

    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all['pro']?.isActive ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }
}