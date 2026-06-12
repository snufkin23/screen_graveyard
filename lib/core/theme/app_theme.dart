import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const ColorScheme colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onSurfaceDark,
      primaryContainer: AppColors.surfaceContainerDark,
      onPrimaryContainer: AppColors.onSurfaceVariantDark,
      secondary: AppColors.primaryLight,
      onSecondary: AppColors.surfaceDark,
      tertiary: AppColors.borderDark,
      onTertiary: AppColors.onSurfaceDark,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surfaceContainerDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // ── Scaffold & Background ─────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.surfaceDark,
      canvasColor: AppColors.surfaceDark,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceContainerDark,
        foregroundColor: AppColors.onSurfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Button Themes ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onSurfaceDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.titleMedium.copyWith(
            color: AppColors.onSurfaceDark,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ).copyWith(
          // Pressed state
          backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryDark;
            }
            if (states.contains(WidgetState.disabled)) {
              return AppColors.onSurfaceTertiaryDark;
            }
            return AppColors.primary;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ── Floating Action Button ────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onSurfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Input & Forms ─────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighDark,
        hintStyle: AppTextStyles.hintText,
        labelStyle: AppTextStyles.labelLarge.copyWith(
          color: AppColors.onSurfaceVariantDark,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        errorStyle: AppTextStyles.errorText,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerDark,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),

      // ── Dialog & BottomSheet ──────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceVariantDark,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // ── Lists & Dividers ──────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        textColor: AppColors.onSurfaceDark,
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.onSurfaceDark,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onSurfaceVariantDark,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 0.8,
        space: 16,
      ),

      // ── Icons ─────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.onSurfaceVariantDark,
        size: 24,
      ),

      // ── Tabs ──────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        labelColor: AppColors.onSurfaceDark,
        unselectedLabelColor: AppColors.onSurfaceVariantDark,
        labelStyle: AppTextStyles.titleSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceDark,
        ),
        unselectedLabelStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.onSurfaceVariantDark,
        ),
      ),

      // ── Progress Indicators ───────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearMinHeight: 4,
        circularTrackColor: AppColors.surfaceContainerHighDark,
      ),

      // ── Snackbar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighDark,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.onSurfaceDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),

      // ── Text & Typography ────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }

  /// Light theme (minimal, for fallback)
  static ThemeData get light {
    const ColorScheme colorScheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.surfaceContainerLight,
      onPrimaryContainer: AppColors.onSurfaceLight,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      tertiary: AppColors.borderLight,
      onTertiary: AppColors.onSurfaceLight,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surfaceContainerLight,
      onSurface: AppColors.onSurfaceLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      // Use same patterns as dark theme, just with light colors
    );
  }
}
