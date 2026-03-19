import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fastable/bloc/pro/pro_event.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/services/pro_service.dart';

@injectable
class ProBloc extends Bloc<ProEvent, ProState> {
  final ProService _proService;

  ProBloc(this._proService) : super(const ProState()) {
    on<CheckProStatus>(_onCheckStatus);
    on<LoadOfferings>(_onLoadOfferings);
    on<PurchasePackageEvent>(_onPurchase);
    on<RestorePurchasesEvent>(_onRestore);
  }

  /// Проверка статуса при запуске приложения
  Future<void> _onCheckStatus(CheckProStatus event, Emitter<ProState> emit) async {
    // Инициализацию лучше делать в main.dart, но проверка здесь — ок
    final isPro = await _proService.checkProStatus();

    // Обновляем состояние (сохраняя текущие пакеты, если они были)
    emit(state.copyWith(
      isPro: isPro,
      status: isPro ? ProStatus.proActive : ProStatus.initial,
    ));
  }

  /// Загрузка товаров для Paywall
  Future<void> _onLoadOfferings(LoadOfferings event, Emitter<ProState> emit) async {
    emit(state.copyWith(status: ProStatus.loading));
    try {
      final packages = await _proService.fetchOfferings();
      emit(state.copyWith(
          status: ProStatus.success,
          packages: packages
      ));
    } catch (e) {
      emit(state.copyWith(
          status: ProStatus.failure,
          errorMessage: "Failed to load offers: $e" // Можно сделать локализованную ошибку
      ));
    }
  }

  /// Покупка пакета
  Future<void> _onPurchase(PurchasePackageEvent event, Emitter<ProState> emit) async {
    emit(state.copyWith(status: ProStatus.loading));
    try {
      final success = await _proService.purchasePackage(event.package);
      if (success) {
        // 🔥 Важно: ProActive триггерит закрытие экрана в UI
        emit(state.copyWith(
          status: ProStatus.proActive,
          isPro: true,
          errorMessage: null, // Очищаем ошибки
        ));
      } else {
        // Если пользователь отменил покупку, просто возвращаем старый статус (не ошибку)
        // Но если нужно показать ошибку, то Failure
        emit(state.copyWith(
            status: ProStatus.failure,
            errorMessage: "Purchase cancelled or failed"
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          status: ProStatus.failure,
          errorMessage: e.toString()
      ));
    }
  }

  /// Восстановление покупок
  Future<void> _onRestore(RestorePurchasesEvent event, Emitter<ProState> emit) async {
    emit(state.copyWith(status: ProStatus.loading));
    try {
      final success = await _proService.restorePurchases();
      if (success) {
        emit(state.copyWith(
            status: ProStatus.proActive,
            isPro: true,
            errorMessage: null
        ));
      } else {
        emit(state.copyWith(
            status: ProStatus.failure,
            errorMessage: "No active subscriptions found to restore."
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          status: ProStatus.failure,
          errorMessage: e.toString()
      ));
    }
  }
}