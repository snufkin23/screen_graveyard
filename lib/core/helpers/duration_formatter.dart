/// Formats [Duration] into a human-readable string.
///
/// Example: `DurationFormatter.format(Duration(hours: 2, minutes: 34))`
/// returns `"2h 34m"`.
class DurationFormatter {
  const DurationFormatter._();

  /// Formats [duration] as `"Xh Ym"` or `"Ym"` if less than an hour.
  static String format(Duration duration) {
    final int h = duration.inHours;
    final int m = duration.inMinutes.remainder(60);
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }
}
