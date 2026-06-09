import 'package:flutter/material.dart';

abstract class AppColors {
  const AppColors._();

  /// Main brand purple
  static const Color primary = Color(0xFF9B8FFF);

  /// Secondary dark purple
  static const Color secondary = Color(0xFF3D2D9E);

  /// Primary dark background
  static const Color dark = Color(0xFF0D0D0F);

  /// Additional brand colors
  static const Color primaryLight = Color(0xFFF0EEFF);
  static const Color primaryDark = Color(0xFF2A1F6E);

  // =========================
  // Light Theme
  // =========================

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF0EEFF);

  static const Color lightOnBackground = Color(0xFF0D0D0F);
  static const Color lightOnSurface = Color(0xFF141418);

  static const Color lightSubtext = Color(0xFF666677);
  static const Color lightDivider = Color(0xFFE8E8EE);

  // =========================
  // Dark Theme
  // =========================

  static const Color darkBackground = Color(0xFF0D0D0F);
  static const Color darkSurface = Color(0xFF141418);

  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFF0EEFF);

  static const Color darkSubtext = Color(0xFF666677);
  static const Color darkDivider = Color(0xFF2E2E3E);

  // =========================
  // Semantic
  // =========================

  static const Color success = Color(0xFF4CAF50);

  static const Color warning = Color(0xFFFFB020);

  static const Color error = Color(0xFFE53935);

  static const Color info = Color(0xFF9B8FFF);
}
