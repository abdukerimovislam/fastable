import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin; // 🔥 ДОБАВЛЕНО: margin для удобной верстки
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double opacity;
  final Color? color;
  final BoxBorder? border;
  final BorderRadius? borderRadius; // 🔥 ДОБАВЛЕНО: возможность менять радиус

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.opacity = 0.08,
    this.color,
    this.border,
    this.borderRadius,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Плавная и мягкая анимация в стиле Apple
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Пружинящее сжатие до 97%
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(24);
    final isInteractive = widget.onTap != null || widget.onLongPress != null;

    // 🔥 АРХИТЕКТУРА СТЕКЛА
    Widget glassContent = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      // 1. ТЕНЬ СНАРУЖИ (Shadow)
      // Мы вынесли её ДО ClipRRect, чтобы тень реально падала на фон, а не обрезалась
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          // 2. УСИЛЕННЫЙ БЛЮР
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.color,
              // 3. ГРАДИЕНТНЫЙ БЛИК (Свет падает сверху-слева)
              gradient: widget.color == null
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(widget.opacity + 0.04), // Чуть светлее край
                  Colors.white.withOpacity(widget.opacity),
                ],
              )
                  : null,
              borderRadius: radius,
              // 4. ТОНКАЯ РАМКА (Эффект преломления на гранях стекла)
              border: widget.border ?? Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.0,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    // Если карточка не кликабельна — просто отдаем стекло
    if (!isInteractive) return glassContent;

    // Если кликабельна — оборачиваем в пружинящую анимацию
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: () {
        _controller.reverse();
        widget.onLongPress?.call();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: glassContent,
      ),
    );
  }
}