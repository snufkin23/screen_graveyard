import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/typedefs/typedef.dart';
import 'package:screen_graveyard/features/history/domain/entities/weekly_stats.dart';
import 'package:screen_graveyard/features/history/domain/usecases/get_weekly_stats.dart';

part 'history_state.dart';
part 'history_cubit.freezed.dart';

@lazySingleton
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._getWeeklyStats) : super(const HistoryState.initial());

  final GetWeeklyStats _getWeeklyStats;

  Future<void> load() async {
    emit(const HistoryState.loading());

    final AppResponse<WeeklyStats> result = await _getWeeklyStats.call();

    if (isClosed) {
      return;
    }

    result.fold(
      (AppException error) => emit(HistoryState.error(error: error)),
      (WeeklyStats stats) {
        if (stats.isEmpty) {
          emit(const HistoryState.empty());
        } else {
          emit(HistoryState.loaded(stats: stats));
        }
      },
    );
  }

  Future<void> refresh() => load();
}
