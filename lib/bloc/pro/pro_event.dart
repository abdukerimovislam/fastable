import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class ProEvent extends Equatable {
  const ProEvent();
  @override
  List<Object?> get props => [];
}

/// Проверить статус при старте
class CheckProStatus extends ProEvent {}

/// Загрузить тарифы (когда открыли экран Pro)
class LoadOfferings extends ProEvent {}

/// Купить тариф
class PurchasePackageEvent extends ProEvent {
  final Package package;
  const PurchasePackageEvent(this.package);
}

/// Восстановить покупки
class RestorePurchasesEvent extends ProEvent {}