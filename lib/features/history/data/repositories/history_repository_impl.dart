import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/typedefs/typedef.dart';
import 'package:screen_graveyard/features/history/domain/entities/weekly_stats.dart';
import 'package:screen_graveyard/features/history/domain/repositories/i_history_repository.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';
import 'package:screen_graveyard/features/summary/domain/repositories/i_summary_repository.dart';

@LazySingleton(as: IHistoryRepository)
class HistoryRepositoryImpl implements IHistoryRepository {
  const HistoryRepositoryImpl(this._summaryRepository);

  final ISummaryRepository _summaryRepository;

  @override
  Future<AppResponse<WeeklyStats>> getWeeklyStats() async {
    final AppResponse<List<DailySnapshot>> result = _summaryRepository.getLastNDays(7);

    return result.fold<AppResponse<WeeklyStats>>(
      (AppException error) => Left<AppException, WeeklyStats>(error),
      (List<DailySnapshot> days) => Right<AppException, WeeklyStats>(WeeklyStats(days: days)),
    );
  }
}
