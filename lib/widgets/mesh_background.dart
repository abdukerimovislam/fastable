import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/bloc/fasting/fasting_bloc.dart';
import 'package:fastable/bloc/fasting/fasting_state.dart';

class MeshBackground extends StatefulWidget {
  final bool isFasting; // Оставлено для обратной совместимости, если нет BLoC
  final Widget child;

  const MeshBackground({
    super.key,
    required this.isFasting,
    required this.child,
  });

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Очень медленное движение
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 АПГРЕЙД: Читаем стейт из BLoC для умных цветов
    FastingState? fastingState;
    try {
      fastingState = context.watch<FastingBloc>().state;
    } catch (_) {
      // Игнорируем, если виджет используется вне провайдера
    }

    Color primaryBlob;
    Color secondaryBlob;
    Color tertiaryBlob;

    if (fastingState != null) {
      final phase = fastingState.phase;
      final isCircadian = fastingState.planIndex == FastingState.circadianPlanIndex;

      if (phase == FastingPhase.eating) {
        primaryBlob = const Color(0xFF52E7C4); // Mint
        secondaryBlob = const Color(0xFF2D9CDB); // Blue
        tertiaryBlob = const Color(0xFF7AB6FF); // Light Blue
      } else if (isCircadian && phase == FastingPhase.fasting) {
        primaryBlob = const Color(0xFF6A5ACD); // Slate Blue (Ночь)
        secondaryBlob = const Color(0xFFFF00FF); // Magenta
        tertiaryBlob = const Color(0xFFFF8C00); // Dark Orange (Закат)
      } else if (phase == FastingPhase.fasting) {
        primaryBlob = const Color(0xFFFF8A3D); // Orange
        secondaryBlob = const Color(0xFFB53A2D); // Red
        tertiaryBlob = const Color(0xFFFFD36E); // Yellow
      } else {
        // Stopped
        primaryBlob = const Color(0xFF4169E1); // Royal Blue
        secondaryBlob = const Color(0xFF483D8B); // Dark Slate Blue
        tertiaryBlob = const Color(0xFF1E90FF); // Dodger Blue
      }
    } else {
      // Фолбек на старую логику
      primaryBlob = widget.isFasting ? const Color(0xFFFF8A3D) : const Color(0xFF52E7C4);
      secondaryBlob = widget.isFasting ? const Color(0xFFB53A2D) : const Color(0xFF2D9CDB);
      tertiaryBlob = widget.isFasting ? const Color(0xFFFFD36E) : const Color(0xFF7AB6FF);
    }

    return Stack(
      children: [
        // Базовый темный фон
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1017), Color(0xFF090B11), Color(0xFF040507)],
            ),
          ),
        ),

        // Фоновое свечение (завернуто в AnimatedContainer для плавного перетекания)
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.75, -0.9),
                radius: 1.3,
                colors: [
                  tertiaryBlob.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Анимация плавания сфер
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                Positioned(
                  top: -120 + (_controller.value * 52),
                  left: -100 + (_controller.value * 28),
                  child: _buildBlob(primaryBlob, size: 320),
                ),
                Positioned(
                  bottom: -130 + (_controller.value * 48),
                  right: -70 + (_controller.value * 36),
                  child: _buildBlob(secondaryBlob, size: 340),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.24,
                  left: -80,
                  right: -80,
                  child: Opacity(
                    opacity: 0.24,
                    child: _buildBlob(tertiaryBlob, size: 380),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.18,
                  left: MediaQuery.of(context).size.width * 0.55,
                  child: Opacity(
                    opacity: 0.18,
                    child: _buildBlob(Colors.white, size: 180),
                  ),
                ),
              ],
            );
          },
        ),

        // Жесткий блюр, смешивающий всё в мягкий градиент
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 72, sigmaY: 72),
          child: Container(color: Colors.transparent),
        ),

        // Верхний затемняющий слой для глубины
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.02),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Контент экрана
        widget.child,
      ],
    );
  }

  // 🔥 АПГРЕЙД: AnimatedContainer плавно меняет цвет за 2 секунды при смене стейта
  Widget _buildBlob(Color color, {double size = 300}) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOutSine,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.4), // Полупрозрачность
      ),
    );
  }
}