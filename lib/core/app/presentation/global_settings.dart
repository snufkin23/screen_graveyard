import 'package:flutter/material.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/app_locale/app_locale_cubit.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/app_theme/app_theme_cubit.dart';
import 'package:screen_graveyard/core/di/injection.dart';

/// GlobalSettings provides a non-contextual way to get and set app-wide configurations.
/// It wraps the respective Cubits registered as lazy singletons in getIt.
class GlobalSettings {
  GlobalSettings._();

  static AppLocaleCubit get localeCubit => getIt<AppLocaleCubit>();
  static AppThemeCubit get themeCubit => getIt<AppThemeCubit>();

  /// Get current locale
  static AppLocale get currentLocale => localeCubit.state;

  /// Get current theme mode
  static ThemeMode get currentThemeMode => themeCubit.state;

  /// Set app locale
  static Future<void> setLocale(AppLocale locale) => localeCubit.setLocale(locale);

  /// Set app theme mode
  static Future<void> setThemeMode(ThemeMode mode) => themeCubit.setMode(mode);

  /// Toggle theme mode
  static Future<void> toggleTheme() => themeCubit.toggle();

  /// Shortcut to set English
  static Future<void> setEnglish() => localeCubit.setEnglish();

  /// Shortcut to set Nepali
  static Future<void> setNepali() => localeCubit.setNepali();
}
