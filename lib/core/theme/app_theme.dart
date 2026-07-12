import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'wellness_theme_extension.dart';
import '../constants/app_values.dart';

/// Health Companion — App Theme
///
/// Provides Material 3 [ThemeData] with support for dynamic accent color seeds.
abstract final class AppTheme {
  
  static Color _getSeedColor(String name) {
    switch (name.toLowerCase()) {
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'purple':
        return const Color(0xFF8B5CF6);
      case 'teal':
        return const Color(0xFF14B8A6);
      case 'green':
      default:
        return AppColors.primary;
    }
  }

  static ThemeData getTheme({
    required Brightness brightness,
    required String accentColor,
  }) {
    final seed = _getSeedColor(accentColor);
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = isDark
        ? AppColors.getDarkColorScheme(seed)
        : AppColors.getLightColorScheme(seed);
    final textTheme = AppTextStyles.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      extensions: [
        WellnessThemeExtension(
          waterColor: AppColors.water,
          stepsColor: AppColors.steps,
          bmiColor: AppColors.bmi,
          sleepColor: AppColors.sleep,
          foodColor: AppColors.food,
          healthColor: seed,
          cardRadius: AppRadius.large,
          softShadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
              blurRadius: isDark ? 16 : 12,
              offset: Offset(0, isDark ? 6 : 4),
            ),
          ],
        ),
      ],

      // ── App Bar ──
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        foregroundColor: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
          fontWeight: FontWeight.bold,
        ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Filled Button ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ── Outlined Button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkOnBackgroundVariant : AppColors.lightOnBackgroundVariant,
        ),
      ),

      // ── Dialog Theme ──
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkOnBackgroundVariant : AppColors.lightOnBackgroundVariant,
        ),
      ),

      // ── Bottom Navigation ──
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        indicatorColor: colorScheme.primaryContainer,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
