import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive_ce.dart';

part 'daily_snapshot_model.freezed.dart';
part 'daily_snapshot_model.g.dart';

@freezed
@HiveType(typeId: 0)
sealed class DailySnapshotModel with _$DailySnapshotModel {
  const factory DailySnapshotModel({
    @HiveField(0) required int dateMillis,
    @HiveField(1) required int unlockCount,
    @HiveField(2) required int screenOnMillis,
    @HiveField(3) required int notificationDismissals,
    @HiveField(4) required List<AppUsageModel> appUsage,
  }) = _DailySnapshotModel;

  factory DailySnapshotModel.fromJson(Map<String, dynamic> json) => _$DailySnapshotModelFromJson(json);
}

@freezed
@HiveType(typeId: 1)
sealed class AppUsageModel with _$AppUsageModel {
  const factory AppUsageModel({
    @HiveField(0) required String packageName,
    @HiveField(1) required int totalTimeMillis,
    @HiveField(2) required int lastTimeUsed,
  }) = _AppUsageModel;

  factory AppUsageModel.fromJson(Map<String, dynamic> json) => _$AppUsageModelFromJson(json);
}
