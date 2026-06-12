import 'package:screen_graveyard/core/typedefs/typedef.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';

abstract interface class ISummaryRepository {
  /// Fetches today's usage from Android and persists it locally.
  Future<AppResponse<DailySnapshot>> fetchAndSaveTodaySnapshot();

  /// Returns the locally stored snapshot for today (null if not yet fetched).
  AppResponse<DailySnapshot?> getTodaySnapshot();

  /// Returns last [days] daily snapshots from local storage.
  AppResponse<List<DailySnapshot>> getLastNDays(int days);
}
