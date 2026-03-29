import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_event.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/services/pro_service.dart';

class MockProService extends Mock implements ProService {}

class MockPackage extends Mock implements Package {}

void main() {
  late MockProService mockProService;
  late ProBloc proBloc;

  setUpAll(() {
    registerFallbackValue(MockPackage());
  });

  setUp(() {
    mockProService = MockProService();
    proBloc = ProBloc(mockProService);
  });

  tearDown(() {
    proBloc.close();
  });

  test('initial state is correct', () {
    expect(proBloc.state, const ProState());
  });

  blocTest<ProBloc, ProState>(
    'CheckProStatus emits pro active state when subscription is active',
    build: () {
      when(() => mockProService.checkProStatus()).thenAnswer((_) async => true);
      return proBloc;
    },
    act: (bloc) => bloc.add(CheckProStatus()),
    expect: () => [
      isA<ProState>()
          .having((s) => s.isPro, 'isPro', true)
          .having((s) => s.status, 'status', ProStatus.proActive),
    ],
  );

  blocTest<ProBloc, ProState>(
    'LoadOfferings emits packages on success',
    build: () {
      when(
        () => mockProService.fetchOfferings(),
      ).thenAnswer((_) async => [MockPackage()]);
      return proBloc;
    },
    act: (bloc) => bloc.add(LoadOfferings()),
    expect: () => [
      isA<ProState>().having((s) => s.status, 'status', ProStatus.loading),
      isA<ProState>()
          .having((s) => s.status, 'status', ProStatus.success)
          .having((s) => s.packages.length, 'packages length', 1),
    ],
  );

  blocTest<ProBloc, ProState>(
    'PurchasePackageEvent emits pro active state on successful purchase',
    build: () {
      when(
        () => mockProService.purchasePackage(any()),
      ).thenAnswer((_) async => true);
      return proBloc;
    },
    act: (bloc) => bloc.add(PurchasePackageEvent(MockPackage())),
    expect: () => [
      isA<ProState>().having((s) => s.status, 'status', ProStatus.loading),
      isA<ProState>()
          .having((s) => s.status, 'status', ProStatus.proActive)
          .having((s) => s.isPro, 'isPro', true),
    ],
  );
}
