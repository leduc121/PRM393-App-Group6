import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class SportZoneTheme {
  static const primary = Color(0xFF000000);
  static const onPrimary = Color(0xFFFFFFFF);
  static const background = Color(0xFFF9F9F9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F5);
  static const surfaceContainerLow = Color(0xFFF3F3F4);
  static const secondary = Color(0xFF5D5F5F);
  static const electricLime = Color(0xFFD5FF44);
  static const borderSubtle = Color(0xFFE0E0E0);
  static const error = Color(0xFFBA1A1A);

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      surface: surface,
      onSurface: Color(0xFF1A1C1C),
      surfaceContainerHighest: surfaceVariant,
      onSecondary: onPrimary,
      secondary: secondary,
      error: error,
      onError: onPrimary,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w900, fontSize: 44),
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      labelLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      labelSmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

