import 'package:flutter/material.dart';

class AppLayout {
  const AppLayout._();

  static double edgePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 350) return 12;
    if (width < 390) return 14;
    if (width < 430) return 16;
    return 20;
  }

  static double cardPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 350) return 14;
    if (width < 430) return 16;
    return 18;
  }

  static double compactCardPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 350) return 12;
    if (width < 430) return 14;
    return 16;
  }

  static double sectionGap(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 350 ? 10 : 12;
  }

  static double largeGap(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 350 ? 14 : 16;
  }

  static BorderRadius cardRadius(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 350) return BorderRadius.circular(20);
    if (width < 430) return BorderRadius.circular(22);
    return BorderRadius.circular(26);
  }

  static EdgeInsets screenPadding(
    BuildContext context, {
    double top = 12,
    double bottom = 16,
    bool includeBottomSafeArea = false,
  }) {
    final edge = edgePadding(context);
    final safeBottom = includeBottomSafeArea
        ? MediaQuery.paddingOf(context).bottom
        : 0.0;
    return EdgeInsets.fromLTRB(edge, top, edge, bottom + safeBottom);
  }

  static EdgeInsets contentPadding(
    BuildContext context, {
    double vertical = 16,
  }) {
    final edge = edgePadding(context);
    return EdgeInsets.symmetric(horizontal: edge, vertical: vertical);
  }
}
