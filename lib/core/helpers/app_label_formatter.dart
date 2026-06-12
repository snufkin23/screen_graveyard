/// Extracts a human-readable app label from an Android package name.
///
/// Examples:
/// - `com.android.chrome` → `"Chrome"`
/// - `com.instagram.android` → `"Instagram"`
class AppLabelFormatter {
  const AppLabelFormatter._();

  /// Converts a package name like `"com.example.app"` to `"App"`.
  static String fromPackageName(String packageName) {
    final List<String> parts = packageName.split('.');
    if (parts.length >= 2) {
      final String last = parts.last;
      if (last.length <= 2 && parts.length >= 3) {
        return parts[parts.length - 2];
      }
      return '${last[0].toUpperCase()}${last.substring(1)}';
    }
    return packageName;
  }
}
