import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 💜 HERO COLORS: Neon Purple & Cyan (Top-1 Aesthetics)
  static const Color heroPrimary = Color(0xFFA155FF); 
  static const Color heroSecondary = Color(0xFF00F0FF); 
  static const Color statusSuccess = Color(0xFF34C759); 
  static const Color statusWarning = Color(0xFFFF9500); 
  static const Color statusError = Color(0xFFFF3B30); 
  static const Color premiumGold = Color(0xFFFFC857);

  // 🌑 DEEP SURFACE COLORS
  static const Color darkBackground = Color(0xFF07090F); 
  static const Color premiumSurface = Color(0xFF131722); 
  static const Color premiumOutline = Color(0x33FFFFFF);

  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightCard = Color(0xFFFFFFFF);

  static final TextTheme _outfitTextTheme = GoogleFonts.outfitTextTheme(
    const TextTheme(
      headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.7),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3),
      bodyLarge: TextStyle(fontSize: 17, letterSpacing: -0.2),
      bodyMedium: TextStyle(fontSize: 15, letterSpacing: -0.1),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: heroPrimary,
    scaffoldBackgroundColor: lightBackground,
    textTheme: _outfitTextTheme.apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black,
    ),
    colorScheme: const ColorScheme.light(
      primary: heroPrimary,
      secondary: heroSecondary,
      tertiary: premiumGold,
      surface: lightCard,
      onSurface: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: _outfitTextTheme.headlineLarge?.copyWith(color: Colors.black),
      centerTitle: false,
      iconTheme: const IconThemeData(color: heroPrimary),
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightCard.withValues(alpha: 0.9),
      selectedItemColor: heroPrimary,
      unselectedItemColor: Colors.grey.shade400,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: heroPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    iconTheme: const IconThemeData(color: heroPrimary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: heroPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: heroPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: Color(0x22000000)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white,
      contentTextStyle: _outfitTextTheme.bodyMedium?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: _outfitTextTheme.titleLarge?.copyWith(color: Colors.black),
      contentTextStyle: _outfitTextTheme.bodyMedium?.copyWith(
        color: Colors.black87,
        height: 1.45,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.03),
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
        borderSide: const BorderSide(color: heroPrimary),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: heroPrimary,
    scaffoldBackgroundColor: darkBackground,
    textTheme: _outfitTextTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    colorScheme: const ColorScheme.dark(
      primary: heroPrimary,
      secondary: heroSecondary,
      tertiary: premiumGold,
      surface: premiumSurface,
      onSurface: Colors.white,
      error: statusError,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: _outfitTextTheme.headlineLarge?.copyWith(color: Colors.white),
      centerTitle: false,
      iconTheme: const IconThemeData(color: heroPrimary),
    ),
    cardTheme: CardThemeData(
      color: premiumSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF0F111A), // Even darker for contrast
      selectedItemColor: heroPrimary,
      unselectedItemColor: Colors.grey.shade600,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: heroPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    iconTheme: const IconThemeData(color: heroPrimary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: heroPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: heroPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: premiumOutline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: premiumSurface,
      contentTextStyle: _outfitTextTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: _outfitTextTheme.titleLarge?.copyWith(color: Colors.white),
      contentTextStyle: _outfitTextTheme.bodyMedium?.copyWith(
        color: Colors.white70,
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
        borderSide: const BorderSide(color: heroPrimary),
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
  );
}
