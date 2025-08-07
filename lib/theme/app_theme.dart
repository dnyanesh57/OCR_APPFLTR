import 'package:flutter/material.dart';

class AppTheme {
  // --- PRIMARY BRAND COLORS ---
  static const Color primaryColor = Color(0xFF00DEDA); // Turquoise-like color
  static const Color accentColor = Color(0xFF939598);  // Light gray
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color textColor = Color(0xFF000000); // Black

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textColor, // Use black text on the turquoise app bar
    ),
    textTheme: const TextTheme(
      // CORRECTED: headline1 is deprecated, use headlineLarge instead
      headlineLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: textColor), // Ensure default text is black
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor, // Button background is light gray
        foregroundColor: textColor, // Button text color is black
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: primaryColor),
    ),
  );
}
