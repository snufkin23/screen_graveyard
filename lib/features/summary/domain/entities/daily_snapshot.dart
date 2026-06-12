import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_snapshot.freezed.dart';

/// Pure domain entity — no Flutter, no Hive, no external deps.
@freezed
sealed class DailySnapshot with _$DailySnapshot {
  const factory DailySnapshot({
    required DateTime date,
    required int unlockCount,
    required Duration screenOnTime,
    required int notificationDismissals,
    required List<AppStat> appUsage,
  }) = _DailySnapshot;

  const DailySnapshot._();

  /// Most used app by foreground time
  AppStat? get mostUsedApp => appUsage.isEmpty ? null : appUsage.first;

  /// App with fewest foreground time
  AppStat? get mostIgnoredApp => appUsage.isEmpty
      ? null
      : appUsage.reduce(
          (AppStat a, AppStat b) => a.totalTimeMillis < b.totalTimeMillis ? a : b,
        );

  bool get isEmpty => unlockCount == 0 && screenOnTime == Duration.zero && appUsage.isEmpty;
}

@freezed
sealed class AppStat with _$AppStat {
  const factory AppStat({
    required String packageName,
    required int totalTimeMillis,
    required DateTime lastTimeUsed,
  }) = _AppStat;

  const AppStat._();

  Duration get totalTime => Duration(milliseconds: totalTimeMillis);
}
