import 'package:flutter/material.dart';

/// Abstract color palette for Screen Graveyard
/// Supports light and dark themes with graveyard aesthetic
abstract class AppColors {
  const AppColors._();

  // ── Primary & Secondary ───────────────────────────────────────────────────
  static const Color primary =
      Color(0xFF9B8FFF); // Lavender purple (tombstone accent)
  static const Color primaryLight =
      Color(0xFFB8B0FF); // Lighter purple for hover
  static const Color primaryDark = Color(0xFF6B5FCC); // Darker purple for press

  // ── Surfaces ──────────────────────────────────────────────────────────────
  // Dark mode (primary theme)
  static const Color surfaceDark = Color(0xFF0D0D0F); // Near-black background
  static const Color surfaceContainerDark =
      Color(0xFF2E2E3E); // Card/elevated surface
  static const Color surfaceContainerHighDark =
      Color(0xFF3A3A4A); // Hover state

  // Light mode (fallback, minimal use)
  static const Color surfaceLight = Color(0xFFFBFBFB); // Off-white background
  static const Color surfaceContainerLight =
      Color(0xFFF5F5F7); // Card/elevated surface
  static const Color surfaceContainerHighLight =
      Color(0xFFEFEFF2); // Hover state

  // ── Text Colors ───────────────────────────────────────────────────────────
  // Dark mode
  static const Color onSurfaceDark =
      Color(0xFFF0EEFF); // Primary text (off-white)
  static const Color onSurfaceVariantDark =
      Color(0xFFB8B0FF); // Secondary text (muted purple)
  static const Color onSurfaceTertiaryDark =
      Color(0xFF555566); // Tertiary text (dim gray)

  // Light mode
  static const Color onSurfaceLight = Color(0xFF1A1A1F); // Primary text (dark)
  static const Color onSurfaceVariantLight =
      Color(0xFF555566); // Secondary text (gray)
  static const Color onSurfaceTertiaryLight =
      Color(0xFF9B9BA8); // Tertiary text (light gray)

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF6B6B); // Red for errors
  static const Color success = Color(0xFF51CF66); // Green for success
  static const Color warning = Color(0xFFFFA94D); // Amber for warnings
  static const Color info = Color(0xFF74C0FC); // Blue for info

  static const Color errorLight = Color(0xFFFCC7C5);
  static const Color successLight = Color(0xFFCCF0D5);
  static const Color warningLight = Color(0xFFFFE3B3);
  static const Color infoLight = Color(0xFFC5E1FF);

  // ── Borders & Dividers ────────────────────────────────────────────────────
  static const Color borderDark = Color(0xFF3A3A4A); // Subtle borders on dark
  static const Color dividerDark = Color(0xFF1F1F28); // Divider lines on dark

  static const Color borderLight = Color(0xFFE5E5E7); // Subtle borders on light
  static const Color dividerLight = Color(0xFFF0F0F2); // Divider lines on light

  // ── Skeleton / Loading ────────────────────────────────────────────────────
  static const Color skeletonDark = Color(0xFF1F1F28); // Shimmer base on dark
  static const Color skeletonHighlightDark =
      Color(0xFF2A2A34); // Shimmer highlight

  static const Color skeletonLight = Color(0xFFE5E5E7);
  static const Color skeletonHighlightLight = Color(0xFFF5F5F7);

  // ── Overlay & Scrim ──────────────────────────────────────────────────────
  static const Color scrimDark = Color(0x80000000); // 50% black overlay
  static const Color scrimLight = Color(0x33000000); // 20% black overlay
}

/// Convenience extension to get colors based on brightness
extension AppColorsX on BuildContext {
  AppColorScheme get appColors => Theme.of(this).brightness == Brightness.dark
      ? const AppColorSchemeDark()
      : const AppColorSchemeLight();
}

/// Abstract interface for theme-aware colors
abstract class AppColorScheme {
  const AppColorScheme();

  Color get surface;
  Color get surfaceContainer;
  Color get surfaceContainerHigh;
  Color get onSurface;
  Color get onSurfaceVariant;
  Color get onSurfaceTertiary;
  Color get border;
  Color get divider;
  Color get skeleton;
  Color get skeletonHighlight;
  Color get scrim;
}

/// Dark theme colors (primary for Screen Graveyard)
class AppColorSchemeDark extends AppColorScheme {
  const AppColorSchemeDark();

  @override
  Color get surface => AppColors.surfaceDark;
  @override
  Color get surfaceContainer => AppColors.surfaceContainerDark;
  @override
  Color get surfaceContainerHigh => AppColors.surfaceContainerHighDark;
  @override
  Color get onSurface => AppColors.onSurfaceDark;
  @override
  Color get onSurfaceVariant => AppColors.onSurfaceVariantDark;
  @override
  Color get onSurfaceTertiary => AppColors.onSurfaceTertiaryDark;
  @override
  Color get border => AppColors.borderDark;
  @override
  Color get divider => AppColors.dividerDark;
  @override
  Color get skeleton => AppColors.skeletonDark;
  @override
  Color get skeletonHighlight => AppColors.skeletonHighlightDark;
  @override
  Color get scrim => AppColors.scrimDark;
}

/// Light theme colors (fallback)
class AppColorSchemeLight extends AppColorScheme {
  const AppColorSchemeLight();

  @override
  Color get surface => AppColors.surfaceLight;
  @override
  Color get surfaceContainer => AppColors.surfaceContainerLight;
  @override
  Color get surfaceContainerHigh => AppColors.surfaceContainerHighLight;
  @override
  Color get onSurface => AppColors.onSurfaceLight;
  @override
  Color get onSurfaceVariant => AppColors.onSurfaceVariantLight;
  @override
  Color get onSurfaceTertiary => AppColors.onSurfaceTertiaryLight;
  @override
  Color get border => AppColors.borderLight;
  @override
  Color get divider => AppColors.dividerLight;
  @override
  Color get skeleton => AppColors.skeletonLight;
  @override
  Color get skeletonHighlight => AppColors.skeletonHighlightLight;
  @override
  Color get scrim => AppColors.scrimLight;
}
