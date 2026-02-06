import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:fastable/injection.dart';
import 'package:fastable/bloc/coach/coach_bloc.dart';
import 'package:fastable/bloc/pro/pro_bloc.dart';
import 'package:fastable/bloc/pro/pro_state.dart';
import 'package:fastable/widgets/glass_card.dart';
import 'package:fastable/screens/pro_screen.dart';
import 'package:fastable/l10n/app_localizations.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  // ✨ КРАСИВАЯ АНИМАЦИЯ ПЕРЕХОДА
  // Вызывать так: Navigator.push(context, CoachScreen.route());
  static Route route() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const CoachScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1); // Чуть-чуть сдвигаем снизу
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProBloc, ProState>(
      builder: (context, proState) {
        if (!proState.isPro) {
          return _buildPaywall(context, l10n);
        }

        return BlocProvider(
          create: (_) => getIt<CoachBloc>()..add(InitCoach(l10n.aiGreeting)),
          child: const _CoachView(),
        );
      },
    );
  }

  Widget _buildPaywall(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Добавляем AppBar даже в Paywall, чтобы можно было вернуться назад
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 60, color: Colors.purpleAccent),
                const SizedBox(height: 16),
                Text(
                  l10n.aiCoachTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.aiCoachDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProScreen()));
                  },
                  child: Text(l10n.btnUnlockPro, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
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

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    context.read<CoachBloc>().add(SendCoachMessage(_controller.text));
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // --- КАСТОМНАЯ ШАПКА (HEADER) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // 🔙 Кнопка НАЗАД
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ЗАГОЛОВОК
                  Expanded(
                    child: Text(
                      l10n.aiCoachTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ИКОНКА СПРАВА (Для баланса или декора)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 20),
                  ),
                ],
              ),
            ),

            // --- СПИСОК СООБЩЕНИЙ ---
            Expanded(
              child: BlocConsumer<CoachBloc, CoachState>(
                listener: (context, state) {
                  Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                },
                builder: (context, state) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
                        );
                      }
                      return _buildMessageBubble(state.messages[index]);
                    },
                  );
                },
              ),
            ),

            // --- ПОЛЕ ВВОДА ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), // Чуть меньше отступ снизу
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l10n.aiChatHint,
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.purpleAccent),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.purpleAccent.withOpacity(0.1),
                      shape: const CircleBorder(),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(CoachMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: isUser
            ? Text(msg.text, style: const TextStyle(color: Colors.white))
            : MarkdownBody(
          data: msg.text,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: Colors.white),
            strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            listBullet: const TextStyle(color: Colors.purpleAccent),
          ),
        ),
      ),
    );
  }
}