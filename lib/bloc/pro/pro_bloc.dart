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

  Future<void> _onCheckStatus(CheckProStatus event, Emitter<ProState> emit) async {
    // Инициализируем сервис при первой проверке
    await _proService.init();
    final isPro = await _proService.checkProStatus();
    emit(state.copyWith(isPro: isPro));
  }

  Future<void> _onLoadOfferings(LoadOfferings event, Emitter<ProState> emit) async {
    emit(state.copyWith(status: ProStatus.loading));
    try {
      final packages = await _proService.fetchOfferings();
      emit(state.copyWith(status: ProStatus.success, packages: packages));
    } catch (e) {
      emit(state.copyWith(status: ProStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onPurchase(PurchasePackageEvent event, Emitter<ProState> emit) async {
    emit(state.copyWith(status: ProStatus.loading));
    try {
      final success = await _proService.purchasePackage(event.package);
      if (success) {
        emit(state.copyWith(status: ProStatus.proActive, isPro: true));
      } else {
        emit(state.copyWith(status: ProStatus.failure, errorMessage: "Purchase cancelled or failed"));
      }
    } catch (e) {
      emit(state.copyWith(status: ProStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onRestore(RestorePurchasesEvent event, Emitter<ProState> emit) async {
    emit(state.copyWith(status: ProStatus.loading));
    try {
      final success = await _proService.restorePurchases();
      if (success) {
        emit(state.copyWith(status: ProStatus.proActive, isPro: true));
      } else {
        emit(state.copyWith(status: ProStatus.failure, errorMessage: "No active subscriptions found"));
      }
    } catch (e) {
      emit(state.copyWith(status: ProStatus.failure, errorMessage: e.toString()));
    }
  }
}