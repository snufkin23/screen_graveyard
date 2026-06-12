import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Abstract text styles for Screen Graveyard
/// Uses Playfair Display for display/headlines (elegant, graveyard aesthetic)
/// Uses DM Sans for body and labels (clean, readable)
abstract class AppTextStyles {
  const AppTextStyles._();

  // ── Base style builders ────────────────────────────────────────────────────
  static TextStyle _playfair({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color ?? AppColors.onSurfaceDark,
      );

  static TextStyle _dmSans({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color ?? AppColors.onSurfaceDark,
      );

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║ DISPLAY — Large dramatic headlines, brand presence                    ║
  // ╚════════════════════════════════════════════════════════════════════════╝

  /// Extra large display — for app title / splash screen
  /// Example: "Screen Graveyard"
  static TextStyle get displayLarge => _playfair(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.1,
      );

  /// Large display — for feature titles
  static TextStyle get displayMedium => _playfair(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.2,
      );

  /// Medium display — for section headers
  static TextStyle get displaySmall => _playfair(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
      );

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║ HEADLINE — Section and subsection titles                              ║
  // ╚════════════════════════════════════════════════════════════════════════╝

  /// Large headline — main section title
  /// Example: "Your graveyard today"
  static TextStyle get headlineLarge => _playfair(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.15,
        height: 1.3,
      );

  /// Medium headline — subsection title
  static TextStyle get headlineMedium => _playfair(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
      );

  /// Small headline — card title, quote
  static TextStyle get headlineSmall => _dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.12,
        height: 1.4,
      );

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║ TITLE — UI element labels and callouts                                ║
  // ╚════════════════════════════════════════════════════════════════════════╝

  /// Large title — primary UI labels
  static TextStyle get titleLarge => _dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  /// Medium title — card headers, section labels
  static TextStyle get titleMedium => _dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      );

  /// Small title — button labels, metadata
  static TextStyle get titleSmall => _dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.5,
      );

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║ BODY — Paragraph text and descriptions                                ║
  // ╚════════════════════════════════════════════════════════════════════════╝

  /// Large body — primary paragraph text
  /// Example: Explanation on onboarding screen
  static TextStyle get bodyLarge => _dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.6,
      );

  /// Medium body — standard paragraph
  static TextStyle get bodyMedium => _dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.6,
      );

  /// Small body — secondary text, captions
  static TextStyle get bodySmall => _dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
      );

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║ LABEL — Badges, tags, small indicators                                ║
  // ╚════════════════════════════════════════════════════════════════════════╝

  /// Large label — prominent badge / tag
  static TextStyle get labelLarge => _dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  /// Medium label — standard label, chip text
  static TextStyle get labelMedium => _dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
      );

  /// Small label — tiny indicator, hint text
  static TextStyle get labelSmall => _dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
      );

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║ BRAND — App name, logo text, signature styles                         ║
  // ╚════════════════════════════════════════════════════════════════════════╝

  /// Brand title — "Screen Graveyard" wordmark
  static TextStyle get brandTitle => _playfair(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.primary,
      );

  /// Brand tagline — "Your phone's daily obituary"
  static TextStyle get brandTagline => _dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.4,
        color: AppColors.onSurfaceVariantDark,
      );

  /// RIP text — on tombstone cards
  static TextStyle get rip => _playfair(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.primary,
      );

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║ CONTEXTUAL — Semantic text styles for common patterns                 ║
  // ╚════════════════════════════════════════════════════════════════════════╝

  /// Witty headline — dramatic copy on summary screen
  static TextStyle get wittyHeadline => _playfair(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        height: 1.3,
        color: AppColors.onSurfaceDark,
      );

  /// Error text — for validation messages
  static TextStyle get errorText => _dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
        color: AppColors.error,
      );

  /// Success text — for completion messages
  static TextStyle get successText => _dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
        color: AppColors.success,
      );

  /// Hint text — placeholder, helper text
  static TextStyle get hintText => _dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.4,
        color: AppColors.onSurfaceTertiaryDark,
      );
}
