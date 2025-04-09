import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF4CAF50),
    scaffoldBackgroundColor: Color(0xFFF4F5F7),
    appBarTheme: AppBarTheme(
      color: Color(0xFF4CAF50),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF344C64)),
      bodyMedium: TextStyle(color: Color(0xFF344C64)),
      bodySmall: TextStyle(color: Color(0xFF344C64)),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF81C784),
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      color: Color(0xFF2E7D32),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white54),
    ),
  );
}
