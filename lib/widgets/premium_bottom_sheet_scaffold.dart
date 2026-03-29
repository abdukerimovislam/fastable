import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:fastable/ui/app_layout.dart';

class PremiumBottomSheetScaffold extends StatelessWidget {
  final Widget child;
  final double maxHeightFactor;

  const PremiumBottomSheetScaffold({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.92,
  });

  @override
  Widget build(BuildContext context) {
    final edgePadding = AppLayout.edgePadding(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: const Color(0xFF101318).withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.34),
                  blurRadius: 40,
                  spreadRadius: -16,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                edgePadding,
                12,
                edgePadding,
                16 + safeBottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
