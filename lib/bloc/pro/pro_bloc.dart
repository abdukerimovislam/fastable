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

  Future<void> _onCheckStatus(
    CheckProStatus event,
    Emitter<ProState> emit,
  ) async {
    final isPro = await _proService.checkProStatus();
    emit(
      state.copyWith(
        isPro: isPro,
        status: isPro ? ProStatus.proActive : ProStatus.initial,
      ),
    );
  }

  Future<void> _onLoadOfferings(
    LoadOfferings event,
    Emitter<ProState> emit,
  ) async {
    emit(state.copyWith(status: ProStatus.loading));
    try {
      final packages = await _proService.fetchOfferings();
      emit(state.copyWith(status: ProStatus.success, packages: packages));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProStatus.failure,
          errorMessage: "Failed to load offers: $e",
        ),
      );
    }
  }

  Future<void> _onPurchase(
    PurchasePackageEvent event,
    Emitter<ProState> emit,
  ) async {
    emit(state.copyWith(status: ProStatus.loading));
    try {
      final success = await _proService.purchasePackage(event.package);
      if (success) {
        emit(
          state.copyWith(
            status: ProStatus.proActive,
            isPro: true,
            errorMessage: null,
          ),
        );
      } else {
        // 🔥 ИСПРАВЛЕНИЕ: Молча возвращаемся в статус success (чтобы Пэйвол остался открытым).
        // Не выдаем Failure, если пользователь просто нажал "Отмена".
        emit(state.copyWith(status: ProStatus.success, errorMessage: null));
      }
    } catch (e) {
      emit(
        state.copyWith(status: ProStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onRestore(
    RestorePurchasesEvent event,
    Emitter<ProState> emit,
  ) async {
    emit(state.copyWith(status: ProStatus.loading));
    try {
      final success = await _proService.restorePurchases();
      if (success) {
        emit(
          state.copyWith(
            status: ProStatus.proActive,
            isPro: true,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProStatus.failure,
            errorMessage: "No active subscriptions found to restore.",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: ProStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
