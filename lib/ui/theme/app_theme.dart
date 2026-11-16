import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Semantic priority & status hues tuned to Warm Graphite
  static const Color level3 = Color(0xFFE5484D); // Crimson urgency
  static const Color level2 = Color(0xFFE09F3E); // Warm amber approaching
  static const Color level1 = Color(0xFF5E94D4); // Calm cobalt low
  static const Color overdue = Color(0xFFE5484D); // Overdue / destructive
  static const Color inProgress = Color(0xFF3EB489); // Sage emerald active/done
  static const Color ignored = Color(0xFF7D7870); // Muted warm grey

  // Warm Graphite neutral ramp
  static const Color sidebar = Color(0xFF111110);
  static const Color background = Color(0xFF161614);
  static const Color surface = Color(0xFF1D1D1B);
  static const Color surfaceLight = Color(0xFF272724);
  static const Color border = Color(0x17EFECE6); // ~9% warm ivory hairline
  static const Color borderStrong = Color(0x2AEFECE6);

  // Three text roles
  static const Color textPrimary = Color(0xFFEFECE6);
  static const Color textSecondary = Color(0xFFA8A39B);
  static const Color textMuted = Color(0xFF7D7870);

  // Single selection/status accent + off-white primary button
  static const Color primary = Color(0xFF3CA89C); // Mineral teal
  static const Color actionBg = Color(0xFFEFECE6);
  static const Color actionFg = Color(0xFF141413);
}

class AppTheme {
  static const Duration fastDuration = Duration(milliseconds: 160);
  static const Curve motionCurve = Curves.easeOutCubic;

  static TextStyle mono(
    double size, {
    Color color = AppColors.textMuted,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static ThemeData darkTheme() {
    final baseDark = ThemeData.dark(useMaterial3: true);
    final baseText = baseDark.textTheme.apply(
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return baseDark.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.actionFg,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.overdue,
        outline: AppColors.border,
      ),
      textTheme: baseText,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderStrong, width: 1),
        ),
        titleTextStyle: baseText.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.overdue),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionBg,
          foregroundColor: AppColors.actionFg,
          elevation: 0,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Shared flat brand glyph (a simple layered task/sync mark in a single ink).
class TaskerMark extends StatelessWidget {
  final double size;

  const TaskerMark({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderStrong),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check_rounded,
        size: size * 0.62,
        color: AppColors.primary,
      ),
    );
  }
}
