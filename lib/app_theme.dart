import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Apple System Colors Reference
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosGreen = Color(0xFF34C759);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosRed = Color(0xFFFF3B30);

  // Backgrounds
  static const Color lightBackground = Color(0xFFF2F2F7); // System Gray 6 Light
  static const Color darkBackground = Color(0xFF000000); // Pure Black

  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF1C1C1E); // System Gray 6 Dark

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Включаем Material 3 для лучших анимаций, но стилизуем под iOS
    brightness: Brightness.light,
    primaryColor: iosBlue,
    scaffoldBackgroundColor: lightBackground,

    // Шрифт - по умолчанию Flutter использует San Francisco на iOS
    fontFamily: 'SF Pro Display',

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 34, // Large Title Style
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      centerTitle: false, // Apple style: title on the left (usually)
      iconTheme: IconThemeData(color: iosBlue),
    ),

    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0, // Apple стиль - без теней elevation, или очень мягкие
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), // Большие скругления
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightCard.withOpacity(0.9), // Чуть прозрачности
      selectedItemColor: iosBlue,
      unselectedItemColor: Colors.grey.shade400,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: iosBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), // Круг
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.black, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      titleLarge: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 17),
      bodyMedium: TextStyle(color: Colors.black54, fontSize: 15),
    ),

    iconTheme: const IconThemeData(color: iosBlue),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: iosBlue,
    scaffoldBackgroundColor: darkBackground,

    fontFamily: 'SF Pro Display',

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 34,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      centerTitle: false,
      iconTheme: IconThemeData(color: iosBlue),
    ),

    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF121212), // Чуть светлее фона
      selectedItemColor: iosBlue,
      unselectedItemColor: Colors.grey.shade600,
      elevation: 0,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: iosBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      titleLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 17),
      bodyMedium: TextStyle(color: Colors.grey, fontSize: 15),
    ),

    iconTheme: const IconThemeData(color: iosBlue),
  );
}