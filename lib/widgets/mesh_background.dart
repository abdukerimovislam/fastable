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
    final Color primaryBlob = widget.isFasting
        ? const Color(0xFFFF8A3D)
        : const Color(0xFF52E7C4);

    final Color secondaryBlob = widget.isFasting
        ? const Color(0xFFB53A2D)
        : const Color(0xFF2D9CDB);
    final Color tertiaryBlob = widget.isFasting
        ? const Color(0xFFFFD36E)
        : const Color(0xFF7AB6FF);

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1017), Color(0xFF090B11), Color(0xFF040507)],
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
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

        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 72, sigmaY: 72),
          child: Container(color: Colors.transparent),
        ),
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
        color: color.withValues(alpha: 0.4), // Полупрозрачность
      ),
    );
  }
}
