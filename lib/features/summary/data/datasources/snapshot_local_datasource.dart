import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/logger/app_logger.dart';
import 'package:screen_graveyard/features/summary/data/models/daily_snapshot_model.dart';

abstract interface class SnapshotLocalDatasource {
  Future<void> saveSnapshot(DailySnapshotModel snapshot);
  DailySnapshotModel? getTodaySnapshot();
  List<DailySnapshotModel> getLastNDays(int days);
}

@LazySingleton(as: SnapshotLocalDatasource)
class SnapshotLocalDatasourceImpl implements SnapshotLocalDatasource {
  SnapshotLocalDatasourceImpl._();

  @preResolve
  @factoryMethod
  static Future<SnapshotLocalDatasourceImpl> init() async {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(DailySnapshotModelAdapter())
      ..registerAdapter(AppUsageModelAdapter());
    await Hive.openBox<DailySnapshotModel>(_boxName);
    AppLogger.d('Daily snapshots Hive box opened');
    return SnapshotLocalDatasourceImpl._();
  }

  static const String _boxName = 'daily_snapshots';

  Box<DailySnapshotModel> get _box => Hive.box<DailySnapshotModel>(_boxName);

  @override
  Future<void> saveSnapshot(DailySnapshotModel snapshot) async {
    await _box.put(snapshot.dateMillis, snapshot);
    AppLogger.d('Snapshot saved for date: ${snapshot.dateMillis}');
  }

  @override
  DailySnapshotModel? getTodaySnapshot() {
    final int todayKey = _startOfTodayMillis();
    return _box.get(todayKey);
  }

  @override
  List<DailySnapshotModel> getLastNDays(int days) {
    final int today = _startOfTodayMillis();
    final int cutoff = today - (days - 1) * Duration.millisecondsPerDay;

    return _box.values.where((DailySnapshotModel s) => s.dateMillis >= cutoff).toList()
      ..sort(
        (DailySnapshotModel a, DailySnapshotModel b) => b.dateMillis.compareTo(a.dateMillis),
      );
  }

  int _startOfTodayMillis() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }
}
