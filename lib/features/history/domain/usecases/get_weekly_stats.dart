import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/typedefs/typedef.dart';
import 'package:screen_graveyard/features/history/domain/entities/weekly_stats.dart';
import 'package:screen_graveyard/features/history/domain/repositories/i_history_repository.dart';

@lazySingleton
class GetWeeklyStats {
  const GetWeeklyStats(this._repository);

  final IHistoryRepository _repository;

  Future<AppResponse<WeeklyStats>> call() => _repository.getWeeklyStats();
}
