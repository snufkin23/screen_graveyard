abstract class StorageKeys {
  // Hive box names
  static const String appBox = 'app_box';

  // Keys
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String isWelcome = 'is_welcome';
  static const String isLoggedIn = 'is_logged_in';

  static const String accessToken = '__ACCESS_TOKEN__';
  static const String refreshToken = '__REFRESH_TOKEN__';
  static const String rememberMe = 'remember_me';

  static const String themeMode = 'theme_mode';
  static const String locale = 'app_locale';

  // Notification preferences
  static const String dailyReminderEnabled = 'daily_reminder_enabled';
  static const String dailyReminderHour = 'daily_reminder_hour';
  static const String dailyReminderMinute = 'daily_reminder_minute';
}
