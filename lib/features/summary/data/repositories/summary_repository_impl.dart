import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/typedefs/typedef.dart';
import 'package:screen_graveyard/features/summary/data/datasources/snapshot_local_datasource.dart';
import 'package:screen_graveyard/features/summary/data/datasources/usage_stats_datasource.dart';
import 'package:screen_graveyard/features/summary/data/models/daily_snapshot_model.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';
import 'package:screen_graveyard/features/summary/domain/repositories/i_summary_repository.dart';

@LazySingleton(as: ISummaryRepository)
class SummaryRepositoryImpl implements ISummaryRepository {
  const SummaryRepositoryImpl(
    this._usageStatsDatasource,
    this._localDatasource,
  );

  final UsageStatsDatasource _usageStatsDatasource;
  final SnapshotLocalDatasource _localDatasource;

  @override
  Future<AppResponse<DailySnapshot>> fetchAndSaveTodaySnapshot() async {
    try {
      final RawDailySummary raw = await _usageStatsDatasource.getDailySummary();

      final DailySnapshotModel model = _rawToModel(raw);
      await _localDatasource.saveSnapshot(model);

      return right(_modelToEntity(model));
    } on AppException {
      rethrow;
    } catch (e) {
      return left(const AppException.usageStats());
    }
  }

  @override
  AppResponse<DailySnapshot?> getTodaySnapshot() {
    try {
      final DailySnapshotModel? model = _localDatasource.getTodaySnapshot();
      return right(model != null ? _modelToEntity(model) : null);
    } on AppException {
      rethrow;
    } catch (e) {
      return left(const AppException.storage());
    }
  }

  @override
  AppResponse<List<DailySnapshot>> getLastNDays(int days) {
    try {
      final List<DailySnapshotModel> models = _localDatasource.getLastNDays(days);
      return right(models.map(_modelToEntity).toList());
    } on AppException {
      rethrow;
    } catch (e) {
      return left(const AppException.storage());
    }
  }

  // ── Mapping ───────────────────────────────────────────────────────────────

  DailySnapshotModel _rawToModel(RawDailySummary raw) {
    final List<dynamic> rawApps = raw['appUsage'] as List<dynamic>? ?? <dynamic>[];

    final List<AppUsageModel> apps = rawApps
        .cast<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> a) => AppUsageModel(
            packageName: a['packageName'] as String,
            totalTimeMillis: (a['totalTimeMillis'] as num).toInt(),
            lastTimeUsed: (a['lastTimeUsed'] as num).toInt(),
          ),
        )
        .toList();

    return DailySnapshotModel(
      dateMillis: (raw['date'] as num).toInt(),
      unlockCount: (raw['unlockCount'] as num).toInt(),
      screenOnMillis: (raw['screenOnMillis'] as num).toInt(),
      notificationDismissals: (raw['notificationDismissals'] as num).toInt(),
      appUsage: apps,
    );
  }

  DailySnapshot _modelToEntity(DailySnapshotModel model) {
    return DailySnapshot(
      date: DateTime.fromMillisecondsSinceEpoch(model.dateMillis),
      unlockCount: model.unlockCount,
      screenOnTime: Duration(milliseconds: model.screenOnMillis),
      notificationDismissals: model.notificationDismissals,
      appUsage: model.appUsage
          .map(
            (AppUsageModel a) => AppStat(
              packageName: a.packageName,
              totalTimeMillis: a.totalTimeMillis,
              lastTimeUsed: DateTime.fromMillisecondsSinceEpoch(a.lastTimeUsed),
            ),
          )
          .toList(),
    );
  }
}
