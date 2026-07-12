import 'package:flutter/material.dart';

/// Health Companion — Brand Color System
///
/// Emerald green/mint themed color palette optimized for health, calming, and modern design.
abstract final class AppColors {
  // ──────────────────────── Brand Colors ────────────────────────
  static const Color primary = Color(0xFF0F9F68); // Emerald Green
  static const Color secondary = Color(0xFF14B8A6); // Fresh Mint
  static const Color accent = Color(0xFF3B82F6); // Sky Blue
  static const Color tertiary = Color(0xFFF59E0B); // Warm Amber

  // ─────────────────────── Feature Colors ───────────────────────
  static const Color sleep = Color(0xFF6366F1); // Indigo
  static const Color water = Color(0xFF3B82F6); // Blue
  static const Color food = Color(0xFFF97316); // Orange
  static const Color bmi = Color(0xFF8B5CF6); // Purple
  static const Color steps = Color(0xFFFF7A59); // Coral Orange

  // ────────────────────── Semantic Colors ──────────────────────
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Soft Red

  // ──────────────────────── Light Theme Surfaces ────────────────────────
  static const Color lightBackground = Color(0xFFF7FAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE6EFEA);
  static const Color lightOnBackground = Color(0xFF0E1A14);
  static const Color lightOnBackgroundVariant = Color(0xFF4C6154);

  // ──────────────────────── Dark Theme Surfaces ────────────────────────
  static const Color darkBackground = Color(0xFF0F1B16);
  static const Color darkSurface = Color(0xFF152A21);
  static const Color darkSurfaceVariant = Color(0xFF1B3D2F);
  static const Color darkOnBackground = Color(0xFFE4EDE9);
  static const Color darkOnBackgroundVariant = Color(0xFF8BA595);

  // ─────────────────────── Material 3 ColorSchemes ───────────────────────
  
  /// Helper to generate a light color scheme dynamically from a seed.
  static ColorScheme getLightColorScheme(Color seedColor) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      surface: lightSurface,
      onSurface: lightOnBackground,
      error: error,
      secondary: secondary,
      tertiary: seedColor == primary ? accent : primary,
    );
  }

  /// Helper to generate a dark color scheme dynamically from a seed.
  static ColorScheme getDarkColorScheme(Color seedColor) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: darkSurface,
      onSurface: darkOnBackground,
      error: error,
      secondary: secondary,
      tertiary: seedColor == primary ? accent : primary,
    );
  }
}
