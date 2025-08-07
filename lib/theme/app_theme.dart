import 'package:flutter/material.dart';

class AppTheme {
  // --- PRIMARY BRAND COLORS ---
  // Your company's colors
  static const Color primaryColor = Color(0xFF00DEDA); // Turquoise-like color
  static const Color accentColor = Color(0xFF939598);  // Light gray
  static const Color backgroundColor = Color(0xFFFFFFFF); // White
  static const Color textColor = Color(0xFF000000); // Black

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
      onPrimary: textColor,
      onSecondary: textColor,
      onBackground: textColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textColor, // Text/icon color on app bar
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor, // Button background
        foregroundColor: textColor, // Button text color
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentColor), // Lighter border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: primaryColor),
      hintStyle: TextStyle(color: accentColor),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      bodyText1: TextStyle(color: textColor),
      bodyText2: TextStyle(color: accentColor), // Subtle text color
      button: TextStyle(color: textColor),
      caption: TextStyle(color: accentColor),
    ),
  );
}
