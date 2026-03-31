import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🔥 HERO COLORS: Weight Loss / Fitness / Energy
  static const Color heroPrimary = Color(0xFF39D353); // Яркий лаймово-зеленый
  static const Color heroSecondary = Color(0xFFFF6B3D); // Насыщенный кораллово-оранжевый

  static const Color statusSuccess = Color(0xFF22C55E);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusError = Color(0xFFEF4444);
  static const Color premiumGold = Color(0xFFFFC857);

  // 🌈 Primary gradient for CTA / progress / highlights
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF39D353),
      Color(0xFFFF6B3D),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌑 DARK SURFACES
  static const Color darkBackground = Color(0xFF05070A);
  static const Color premiumSurface = Color(0xFF0F141B);
  static const Color premiumOutline = Color(0x22FFFFFF);

  // ☀️ LIGHT SURFACES
  static const Color lightBackground = Color(0xFFF7F8F4);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceTint = Color(0xFFF1F7EE);

  // 📝 Text colors
  static const Color lightTextPrimary = Color(0xFF161A18);
  static const Color lightTextSecondary = Color(0xFF5B635E);

  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xB3FFFFFF);

  static final TextTheme _outfitTextTheme = GoogleFonts.outfitTextTheme(
    const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        letterSpacing: -0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        letterSpacing: -0.1,
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: heroPrimary,
    scaffoldBackgroundColor: lightBackground,
    textTheme: _outfitTextTheme.apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    ),
    colorScheme: const ColorScheme.light(
      primary: heroPrimary,
      secondary: heroSecondary,
      tertiary: premiumGold,
      surface: lightCard,
      onSurface: lightTextPrimary,
      error: statusError,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: _outfitTextTheme.headlineLarge?.copyWith(
        color: lightTextPrimary,
      ),
      centerTitle: false,
      iconTheme: const IconThemeData(color: heroPrimary),
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightCard.withValues(alpha: 0.97),
      selectedItemColor: heroPrimary,
      unselectedItemColor: Colors.grey.shade500,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: heroPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    ),
    iconTheme: const IconThemeData(color: heroPrimary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: heroPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: heroPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightTextPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: Color(0x18000000)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: lightTextPrimary,
      contentTextStyle: _outfitTextTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: _outfitTextTheme.titleLarge?.copyWith(
        color: lightTextPrimary,
      ),
      contentTextStyle: _outfitTextTheme.bodyMedium?.copyWith(
        color: lightTextSecondary,
        height: 1.45,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceTint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0x14000000)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0x14000000)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: heroPrimary, width: 1.4),
      ),
      hintStyle: const TextStyle(color: Color(0xFF8A938D)),
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x12000000),
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: heroPrimary,
      linearTrackColor: Color(0x14000000),
      circularTrackColor: Color(0x14000000),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0x1439D353),
      selectedColor: heroPrimary,
      disabledColor: Colors.grey.shade300,
      secondarySelectedColor: heroSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelStyle: const TextStyle(
        color: lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: heroPrimary,
    scaffoldBackgroundColor: darkBackground,
    textTheme: _outfitTextTheme.apply(
      bodyColor: darkTextPrimary,
      displayColor: darkTextPrimary,
    ),
    colorScheme: const ColorScheme.dark(
      primary: heroPrimary,
      secondary: heroSecondary,
      tertiary: premiumGold,
      surface: premiumSurface,
      onSurface: darkTextPrimary,
      error: statusError,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: _outfitTextTheme.headlineLarge?.copyWith(
        color: Colors.white,
      ),
      centerTitle: false,
      iconTheme: const IconThemeData(color: heroPrimary),
    ),
    cardTheme: CardThemeData(
      color: premiumSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF080B10),
      selectedItemColor: heroPrimary,
      unselectedItemColor: Colors.grey.shade600,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: heroPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    ),
    iconTheme: const IconThemeData(color: heroPrimary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: heroPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: heroPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: premiumOutline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: premiumSurface,
      contentTextStyle: _outfitTextTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: premiumSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: _outfitTextTheme.titleLarge?.copyWith(
        color: Colors.white,
      ),
      contentTextStyle: _outfitTextTheme.bodyMedium?.copyWith(
        color: darkTextSecondary,
        height: 1.45,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: premiumOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: premiumOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: heroPrimary, width: 1.4),
      ),
      hintStyle: const TextStyle(color: Colors.white30),
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    ),
    dividerTheme: const DividerThemeData(
      color: premiumOutline,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: heroPrimary,
      linearTrackColor: Color(0x22FFFFFF),
      circularTrackColor: Color(0x22FFFFFF),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0x1F39D353),
      selectedColor: heroPrimary,
      disabledColor: const Color(0x1FFFFFFF),
      secondarySelectedColor: heroSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}