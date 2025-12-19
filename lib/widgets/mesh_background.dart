import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class MeshBackground extends StatefulWidget {
  final bool isFasting;
  final Widget child;

  const MeshBackground({
    super.key,
    required this.isFasting,
    required this.child,
  });

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground> with SingleTickerProviderStateMixin {
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
    // Цвета пятен (Blobs)
    final Color primaryBlob = widget.isFasting
        ? const Color(0xFFFF4500) // Оранжевый (Голод)
        : const Color(0xFF00FA9A); // Мятный (Еда)

    final Color secondaryBlob = widget.isFasting
        ? const Color(0xFF8B0000) // Темно-красный
        : const Color(0xFF00CED1); // Бирюзовый

    return Stack(
      children: [
        // 1. Глубокий черный фон
        Container(color: const Color(0xFF050505)),

        // 2. Анимированные пятна
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                // Пятно 1 (Верхний левый угол)
                Positioned(
                  top: -100 + (_controller.value * 50),
                  left: -100 + (_controller.value * 30),
                  child: _buildBlob(primaryBlob),
                ),
                // Пятно 2 (Нижний правый угол)
                Positioned(
                  bottom: -100 + (_controller.value * 60),
                  right: -50 + (_controller.value * 40),
                  child: _buildBlob(secondaryBlob),
                ),
                // Пятно 3 (Центр, пульсирует)
                Positioned(
                  top: MediaQuery.of(context).size.height / 3,
                  left: -100,
                  right: -100,
                  child: Opacity(
                    opacity: 0.3,
                    child: _buildBlob(Colors.blueAccent, size: 400),
                  ),
                ),
              ],
            );
          },
        ),

        // 3. Размытие поверх пятен (Mesh effect)
        // Это превращает круги в мягкий туман
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),

        // 4. Контент приложения
        widget.child,
      ],
    );
  }

  Widget _buildBlob(Color color, {double size = 300}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4), // Полупрозрачность
      ),
    );
  }
}