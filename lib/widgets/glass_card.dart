import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.onTap,
    this.opacity = 0.08, // Насколько "мутное" стекло
  });

  @override
  Widget build(BuildContext context) {
    // Скругление должно быть большим (Apple style)
    final borderRadius = BorderRadius.circular(30);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Сильное размытие фона
          child: Container(
            width: width,
            height: height,
            padding: padding ?? const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Полупрозрачная заливка
              color: Colors.white.withOpacity(opacity),
              borderRadius: borderRadius,
              // Тонкая белая рамка (блик на грани стекла)
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.0,
              ),
              // Едва заметная тень для объема
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}