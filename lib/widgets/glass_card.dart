import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fastable/ui/app_layout.dart';
import 'package:fastable/bloc/settings/settings_bloc.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double opacity;
  final Color? color;
  final BoxBorder? border;
  final BorderRadius? borderRadius;

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
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
    if (widget.onTap != null) {
      HapticFeedback.selectionClick();
    }
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

    final isReduced = context.watch<SettingsBloc>().state.reducedAnimations;

    Widget coreContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: widget.padding ?? EdgeInsets.all(AppLayout.cardPadding(context)),
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
        // 🔥 ИСПРАВЛЕНИЕ: Используем Border.all для равномерной рамки. Скругления больше не крашатся.
        border: widget.border ?? Border.all(
          color: Colors.white.withValues(alpha: _isPressed ? 0.3 : 0.15),
          width: _isPressed ? 1.5 : 1.0,
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
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: isReduced
            ? coreContainer
            : BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18, tileMode: TileMode.clamp),
          child: coreContainer,
        ),
      ),
    );

    if (!isInteractive) return glassContent;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: () {
        if (widget.onLongPress != null) {
          HapticFeedback.heavyImpact();
          _controller.reverse();
          widget.onLongPress?.call();
        }
      },
      child: ScaleTransition(scale: _scaleAnimation, child: glassContent),
    );
  }
}