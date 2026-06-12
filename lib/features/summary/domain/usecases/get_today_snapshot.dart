import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/typedefs/typedef.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';
import 'package:screen_graveyard/features/summary/domain/repositories/i_summary_repository.dart';

@lazySingleton
class GetTodaySnapshot {
  const GetTodaySnapshot(this._repository);

  final ISummaryRepository _repository;

  /// Fetches fresh data from Android and persists it.
  Future<AppResponse<DailySnapshot>> call() => _repository.fetchAndSaveTodaySnapshot();
}
