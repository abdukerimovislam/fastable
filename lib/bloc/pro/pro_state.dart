import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum ProStatus { initial, loading, success, failure, proActive }

class ProState extends Equatable {
  final ProStatus status;
  final bool isPro;
  final List<Package> packages;
  final String? errorMessage;

  const ProState({
    this.status = ProStatus.initial,
    this.isPro = false,
    this.packages = const [],
    this.errorMessage,
  });

  ProState copyWith({
    ProStatus? status,
    bool? isPro,
    List<Package>? packages,
    String? errorMessage,
  }) {
    return ProState(
      status: status ?? this.status,
      isPro: isPro ?? this.isPro,
      packages: packages ?? this.packages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isPro, packages, errorMessage];
}