import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const accent = Color(0xFF4A7A5A);
  static const accentLight = Color(0xFFDFF0E8);
  static const teal = Color(0xFF0F6E56);
  static const tealLight = Color(0xFFE1F5EE);
  static const coral = Color(0xFF993C1D);
  static const coralLight = Color(0xFFFAECE7);
  static const amber = Color(0xFF854F0B);
  static const amberLight = Color(0xFFFAEEDA);

  // Neutrals
  static const surface = Color(0xFFF8F7F2);
  static const surfaceDark = Color(0xFF1C1712);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF272018);
  static const borderLight = Color(0xFFD3D1C7);
  static const borderDark = Color(0xFF3D3020);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.light,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        cardTheme: CardThemeData(
          color: AppColors.cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 48, fontWeight: FontWeight.w600, letterSpacing: -1),
          headlineMedium: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5),
          titleLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          labelSmall: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.06),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A7A5A),
          brightness: Brightness.dark,
          surface: AppColors.surfaceDark,
        ),
        scaffoldBackgroundColor: AppColors.surfaceDark,
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
      );
}