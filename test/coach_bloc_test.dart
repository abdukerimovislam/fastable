import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fastable/bloc/coach/coach_bloc.dart';
import 'package:fastable/services/ai_service.dart';

class MockAiService extends Mock implements AiService {}

void main() {
  late MockAiService mockAiService;
  late CoachBloc coachBloc;

  setUp(() {
    mockAiService = MockAiService();
    when(
      () => mockAiService.startChat(
        weight: any(named: 'weight'),
        height: any(named: 'height'),
        age: any(named: 'age'),
        gender: any(named: 'gender'),
        activity: any(named: 'activity'),
        greeting: any(named: 'greeting'),
        profileContext: any(named: 'profileContext'),
      ),
    ).thenReturn(null);
    when(
      () => mockAiService.sendMessage(any()),
    ).thenAnswer((_) async => 'Hydrate and keep going.');
    coachBloc = CoachBloc(mockAiService);
  });

  tearDown(() async {
    await coachBloc.close();
  });

  test('initial state is correct', () {
    expect(coachBloc.state, const CoachState());
  });

  blocTest<CoachBloc, CoachState>(
    'InitCoach uses event payload instead of reading persisted profile',
    build: () => coachBloc,
    act: (bloc) => bloc.add(
      const InitCoach(
        greeting: 'Welcome back',
        profileContext: 'Goal: consistency',
        weight: 82.5,
        height: 181.0,
        age: 33,
        gender: 'Male',
        activity: 'Active',
      ),
    ),
    expect: () => [
      isA<CoachState>().having(
        (state) => state.messages.first.text,
        'welcome message',
        'Welcome back',
      ),
    ],
    verify: (_) {
      verify(
        () => mockAiService.startChat(
          weight: 82.5,
          height: 181.0,
          age: 33,
          gender: 'Male',
          activity: 'Active',
          greeting: 'Welcome back',
          profileContext: 'Goal: consistency',
        ),
      ).called(1);
    },
  );

  blocTest<CoachBloc, CoachState>(
    'SendCoachMessage falls back to event-provided localized error text',
    build: () {
      when(
        () => mockAiService.sendMessage(any()),
      ).thenThrow(Exception('network'));
      return coachBloc;
    },
    seed: () => CoachState(
      messages: [
        CoachMessage(
          text: 'Welcome back',
          isUser: false,
          timestamp: DateTime(2025, 1, 1),
        ),
      ],
    ),
    act: (bloc) =>
        bloc.add(const SendCoachMessage('Need help', 'Connection error')),
    expect: () => [
      isA<CoachState>()
          .having((state) => state.isLoading, 'isLoading', true)
          .having((state) => state.messages.length, 'message count', 2),
      isA<CoachState>()
          .having((state) => state.isLoading, 'isLoading', false)
          .having(
            (state) => state.messages.last.text,
            'fallback',
            'Connection error',
          ),
    ],
  );
}
