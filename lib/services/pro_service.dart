import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ProService {
  final String _apiKeyIOS = 'appl_YOUR_IOS_KEY';
  // Android ключ не нужен, так как там нет подписок

  bool _isInitialized = false;

  Future<void> init() async {
    // Если это Android, мы просто выходим. RevenueCat не нужен.
    if (Platform.isAndroid) return;

    if (_isInitialized) return;
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

  Future<bool> checkProStatus() async {
    if (Platform.isAndroid) return false; // На Андроиде всегда "Не PRO" (чтобы показывать рекламу)

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all['pro']?.isActive ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<List<Package>> fetchOfferings() async {
    if (Platform.isAndroid) return []; // Нет тарифов

    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } on PlatformException catch (_) {
      return [];
    }
  }

  Future<bool> purchasePackage(Package package) async {
    if (Platform.isAndroid) return false;

    try {
      var result = await Purchases.purchasePackage(package);
      dynamic dynamicResult = result;
      CustomerInfo info;
      try {
        info = dynamicResult.customerInfo;
      } catch (e) {
        info = dynamicResult;
      }
      return info.entitlements.all['pro']?.isActive ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

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