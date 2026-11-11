import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Priority Palette
  static const Color level3 = Color(0xFFEF4444); // Crimson Red
  static const Color level2 = Color(0xFFF59E0B); // Amber Orange
  static const Color level1 = Color(0xFF3B82F6); // Vibrant Blue
  static const Color overdue = Color(0xFFDC2626); // Alert Carmine
  static const Color inProgress = Color(0xFF10B981); // Emerald Green
  static const Color ignored = Color(0xFF94A3B8); // Slate Muted

  // Dark Canvas
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B); // Slate 800
  static const Color surfaceLight = Color(0xFF334155); // Slate 700
  static const Color border = Color(0xFF334155);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color primary = Color(0xFF6366F1); // Indigo Accent
}

class AppTheme {
  static ThemeData darkTheme() {
    final baseDark = ThemeData.dark();

    return baseDark.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.overdue,
      ),
      // Apply Inter typography across the whole widget tree cleanly
      textTheme: baseDark.textTheme.apply(
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
    );
  }
}
