import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress; // <--- ДОБАВЛЕНО
  final double opacity;
  final Color? color;
  final BoxBorder? border;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.onTap,
    this.onLongPress, // <--- ДОБАВЛЕНО
    this.opacity = 0.08,
    this.color,
    this.border,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03, // Сжатие на 3%
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);
    // Карточка интерактивна, если есть onTap ИЛИ onLongPress
    final isInteractive = widget.onTap != null || widget.onLongPress != null;

    Widget content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.color ?? Colors.white.withOpacity(widget.opacity),
            borderRadius: borderRadius,
            border: widget.border ?? Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (!isInteractive) return content;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(), // Нажали - сжалась
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      // Обработка долгого нажатия
      onLongPress: () {
        _controller.reverse(); // Возвращаем размер
        widget.onLongPress?.call();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - _controller.value,
            child: child,
          );
        },
        child: content,
      ),
    );
  }
}