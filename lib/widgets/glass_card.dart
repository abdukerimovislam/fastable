import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/ui/app_layout.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';

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

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

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

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppLayout.cardRadius(context);
    final isInteractive = widget.onTap != null || widget.onLongPress != null;
    final highlightAlpha = (widget.opacity + 0.08).clamp(0.08, 0.2).toDouble();
    final midAlpha = (widget.opacity + 0.03).clamp(0.05, 0.16).toDouble();
    final baseAlpha = (widget.opacity * 0.75).clamp(0.03, 0.1).toDouble();

    // 🔥 АРХИТЕКТУРА СТЕКЛА
    final isReduced = context.watch<SettingsBloc>().state.reducedAnimations;

    Widget coreContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding:
          widget.padding ??
          EdgeInsets.all(AppLayout.cardPadding(context)),
      // Если анимации упрощены, делаем фон более непрозрачным (чтобы компенсировать отсутствие блюра)
      decoration: BoxDecoration(
        color: widget.color ?? (isReduced ? const Color(0xFF1E1E1E).withValues(alpha: 0.9) : null),
        gradient: (widget.color == null && !isReduced)
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: highlightAlpha),
                  Colors.white.withValues(alpha: midAlpha),
                  Colors.white.withValues(alpha: baseAlpha),
                ],
              )
            : null,
        borderRadius: radius,
        border:
            widget.border ??
            Border.all(
              color: _isPressed && isInteractive 
                ? const Color(0xFF00F0FF).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.14),
              width: _isPressed && isInteractive ? 1.5 : 1.0,
            ),
      ),
      child: widget.child,
    );

    Widget glassContent = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isReduced ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 42,
            spreadRadius: -14,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: -8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: isReduced
            ? coreContainer
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 16,
                  sigmaY: 16,
                  tileMode: TileMode.clamp,
                ),
                child: coreContainer,
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
      child: ScaleTransition(scale: _scaleAnimation, child: glassContent),
    );
  }
}
