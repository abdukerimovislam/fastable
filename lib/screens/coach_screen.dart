import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/bloc/coach/coach_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';
import 'package:fastable/bloc/onboarding_profile/onboarding_profile_cubit.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/bloc/weight/weight_bloc.dart';
import 'package:fastable/bloc/weight/weight_state.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/l10n/app_localizations.dart';
import 'package:fastable/utils/onboarding_personalization.dart';
import 'package:fastable/ui/app_layout.dart';
import 'package:fastable/widgets/mesh_background.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  static Route route() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const CoachScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: animation.drive(tween), child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingProfile = context.select<OnboardingProfileCubit, OnboardingProfileState>((cubit) => cubit.state);
    final weightState = context.select<WeightBloc, WeightState>((bloc) => bloc.state);
    final fastingState = context.select<FastingBloc, FastingState>((bloc) => bloc.state);
    final personalization = OnboardingPersonalizationSnapshot.fromState(
      onboardingProfile: onboardingProfile,
      weightState: weightState,
      fastingState: fastingState,
    );
    final greeting = personalization.hasCompletedOnboarding ? personalization.buildCoachGreeting(l10n) : l10n.aiGreeting;
    final profileContext = personalization.hasCompletedOnboarding ? personalization.buildAiContext() : 'No onboarding profile available.';

    return BlocBuilder<ProBloc, ProState>(
      builder: (context, proState) {
        if (!proState.isPro) {
          return _buildPaywall(context, l10n);
        }
        return BlocProvider(
          key: ValueKey('$greeting|$profileContext'),
          create: (_) => getIt<CoachBloc>()
            ..add(
              InitCoach(
                greeting: greeting,
                profileContext: profileContext,
                weight: weightState.currentWeight,
                height: weightState.heightCm,
                age: weightState.age,
                gender: _genderForAi(weightState.gender),
                activity: _activityForAi(weightState.activityLevel),
              ),
            ),
          child: const _CoachView(),
        );
      },
    );
  }

  static String _genderForAi(Gender gender) {
    switch (gender) {
      case Gender.female: return 'Female';
      case Gender.male: return 'Male';
    }
  }

  static String _activityForAi(ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary: return 'Sedentary';
      case ActivityLevel.active: return 'Active';
      case ActivityLevel.moderate: return 'Moderate';
    }
  }

  Widget _buildPaywall(BuildContext context, AppLocalizations l10n) {
    final edgePadding = AppLayout.edgePadding(context);
    final cardPadding = AppLayout.cardPadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshBackground(
        isFasting: false,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: edgePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: GlassCard(
                            padding: EdgeInsets.zero,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GlassCard(
                      padding: EdgeInsets.all(cardPadding + 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.purpleAccent.withValues(alpha: 0.3), Colors.blueAccent.withValues(alpha: 0.2)],
                              ),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, size: 34, color: Colors.white),
                          ),
                          const SizedBox(height: 18),
                          Text(l10n.aiCoachTitle, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                          const SizedBox(height: 10),
                          Text(l10n.aiCoachDesc, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 15, height: 1.4)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.purpleAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
                              },
                              child: Text(l10n.btnUnlockPro),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachView extends StatefulWidget {
  const _CoachView();

  @override
  State<_CoachView> createState() => _CoachViewState();
}

class _CoachViewState extends State<_CoachView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    context.read<CoachBloc>().add(SendCoachMessage(_controller.text, l10n.aiConnectionError));
    _controller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final edgePadding = AppLayout.edgePadding(context);
    final cardPadding = AppLayout.cardPadding(context);

    return MeshBackground(
      isFasting: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 80),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: edgePadding),
                          child: GlassCard(
                            padding: EdgeInsets.zero,
                            child: BlocConsumer<CoachBloc, CoachState>(
                              listener: (context, state) {
                                Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                              },
                              builder: (context, state) {
                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.only(top: 10, bottom: cardPadding),
                                  itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= state.messages.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
                                      );
                                    }
                                    return _buildMessageBubble(context, state.messages[index]);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(edgePadding, 12, edgePadding, 12 + MediaQuery.paddingOf(context).bottom),
                        child: GlassCard(
                          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  style: const TextStyle(color: Colors.white),
                                  minLines: 1,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.send,
                                  decoration: InputDecoration(
                                    hintText: l10n.aiChatHint,
                                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.34)),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.04),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _sendMessage,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFB84DFF), Color(0xFF4A7DFF)]),
                                    boxShadow: [
                                      BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.28), blurRadius: 18, spreadRadius: -4, offset: const Offset(0, 10)),
                                    ],
                                  ),
                                  child: const Icon(Icons.send_rounded, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(edgePadding, 12, edgePadding, 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 48, height: 48,
                            child: GlassCard(
                              padding: EdgeInsets.zero,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassCard(
                              padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                                        colors: [Colors.purpleAccent.withValues(alpha: 0.24), Colors.blueAccent.withValues(alpha: 0.18)],
                                      ),
                                    ),
                                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.aiCoachTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.aiCoachDesc, maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.58), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.purpleAccent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.22)),
                                    ),
                                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.purpleAccent, size: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, CoachMessage msg) {
    final isUser = msg.isUser;
    final bubble = isUser
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3B82F6), Color(0xFF5B8CFF)]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(8)),
              boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.2), blurRadius: 18, spreadRadius: -6, offset: const Offset(0, 10))],
            ),
            child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.35)),
          )
        : GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: BorderRadius.circular(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: MarkdownBody(
                data: msg.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                  strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  listBullet: const TextStyle(color: Colors.purpleAccent),
                ),
              ),
            ),
          );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }
}
