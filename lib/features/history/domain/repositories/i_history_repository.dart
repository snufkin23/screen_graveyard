import 'package:screen_graveyard/core/typedefs/typedef.dart';
import 'package:screen_graveyard/features/history/domain/entities/weekly_stats.dart';

abstract interface class IHistoryRepository {
  /// Returns statistics for the last 7 days.
  Future<AppResponse<WeeklyStats>> getWeeklyStats();
}
