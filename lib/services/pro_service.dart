import 'package:fastable/utils/logger.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Для проверки kDebugMode
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProService {
  // Ключ RevenueCat для iOS
  final String _apiKeyIOS = 'appl_GshcBpjCuJljIBYIccfLROgoGMW';

  bool _isInitialized = false;

  /// Инициализация сервиса покупок
  Future<void> init() async {
    // Если это Android, мы просто выходим. RevenueCat пока не нужен.
    if (Platform.isAndroid) return;

    if (_isInitialized) return;

    // Строгая настройка логов для релизной сборки (никакого спама в продакшене)
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    } else {
      await Purchases.setLogLevel(LogLevel.error);
    }

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
    if (Platform.isAndroid) return false;

    try {
      if (!_isInitialized) await init();
      final customerInfo = await Purchases.getCustomerInfo();
      // Проверяем наличие активного права доступа 'pro'
      return customerInfo.entitlements.all['pro']?.isActive ?? false;
    } on PlatformException catch (e) {
      appLog("RevenueCat Check Status Error: ${e.message}");
      return false;
    }
  }

  /// Получение доступных тарифов
  Future<List<Package>> fetchOfferings() async {
    if (Platform.isAndroid) return [];

    try {
      if (!_isInitialized) await init();
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } on PlatformException catch (e) {
      appLog("RevenueCat Fetch Offerings Error: ${e.message}");
      return [];
    }
  }

  /// Покупка пакета
  Future<bool> purchasePackage(Package package) async {
    if (Platform.isAndroid) return false;

    try {
      final PurchaseResult result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      final CustomerInfo customerInfo = result.customerInfo;

      // Проверяем подписку после успешной транзакции
      return customerInfo.entitlements.all['pro']?.isActive ?? false;
    } on PlatformException catch (e) {
      // Изящная обработка отмены пользователем, чтобы не считать это критической ошибкой
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        appLog("User cancelled the purchase");
      } else {
        appLog("Purchase Error: ${e.message}");
      }
      return false;
    }
  }

  /// Восстановление покупок
  Future<bool> restorePurchases() async {
    if (Platform.isAndroid) return false;

    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all['pro']?.isActive ?? false;
    } on PlatformException catch (e) {
      appLog("Restore Purchases Error: ${e.message}");
      return false;
    }
  }
}
