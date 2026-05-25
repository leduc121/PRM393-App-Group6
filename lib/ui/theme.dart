import 'package:flutter/material.dart';

class AeroColors {
  static const aeroOrange = Color(0xFF6750A4);      // Geometric Purple - Brand Signature
  static const aeroOrangeLight = Color(0xFFD0BCFF); // Light lavender highlight
  static const aeroEmerald = Color(0xFF10B981);     // Smooth emerald green for active tags
  static const aeroSlateBg = Color(0xFFFEF7FF);     // Balanced Lavender White Background
  static const aeroCardDark = Color(0xFFFFFFFF);    // Symmetric clean card white
  static const aeroTextPrimaryDark = Color(0xFF1D1B20);   // Dark Charcoal primary text
  static const aeroTextSecondaryDark = Color(0xFF49454F); // Subtitle Slate text
  
  static const aeroM3Container = Color(0xFFF3EDF7);   // Soft purple container
  static const aeroM3Outline = Color(0xFFCAC4D0);     // Classic geometric outline
  static const aeroM3Accent = Color(0xFFEADDFF);      // Warm Selection Accent
  
  static const bottomBarBg = Color(0xFFFFFFFF);
}

final ThemeData aeroTheme = ThemeData(
  useMaterial3: true,
  primaryColor: AeroColors.aeroOrange,
  scaffoldBackgroundColor: AeroColors.aeroSlateBg,
  colorScheme: const ColorScheme.light(
    primary: AeroColors.aeroOrange,
    secondary: AeroColors.aeroOrangeLight,
    tertiary: AeroColors.aeroEmerald,
    background: AeroColors.aeroSlateBg,
    surface: AeroColors.aeroCardDark,
    onPrimary: Colors.white,
    onSecondary: AeroColors.aeroTextPrimaryDark,
    onTertiary: Colors.white,
    onBackground: AeroColors.aeroTextPrimaryDark,
    onSurface: AeroColors.aeroTextPrimaryDark,
    surfaceVariant: AeroColors.aeroM3Container,
    onSurfaceVariant: AeroColors.aeroTextSecondaryDark,
    outline: AeroColors.aeroM3Outline,
  ),
);
