import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';

part 'weekly_stats.freezed.dart';

@freezed
abstract class WeeklyStats with _$WeeklyStats {
  const factory WeeklyStats({
    required List<DailySnapshot> days,
  }) = _WeeklyStats;

  const WeeklyStats._();

  Duration get totalScreenTime => days.fold(Duration.zero, (Duration sum, DailySnapshot day) => sum + day.screenOnTime);

  int get peakUnlocks =>
      days.isEmpty ? 0 : days.map((DailySnapshot d) => d.unlockCount).reduce((int a, int b) => a > b ? a : b);

  double get avgUnlocks => days.isEmpty ? 0.0 : peakUnlocks / days.length;

  bool get isEmpty => days.isEmpty;
}
