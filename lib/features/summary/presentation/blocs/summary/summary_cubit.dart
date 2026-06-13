import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/typedefs/typedef.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';
import 'package:screen_graveyard/features/summary/domain/usecases/get_today_snapshot.dart';

part 'summary_state.dart';
part 'summary_cubit.freezed.dart';

@lazySingleton
class SummaryCubit extends Cubit<SummaryState> {
  SummaryCubit(this._getTodaySnapshot) : super(const SummaryState.initial());

  final GetTodaySnapshot _getTodaySnapshot;

  Future<void> refresh() => load();

  Future<void> load() async {
    emit(const SummaryState.loading());

    final AppResponse<DailySnapshot> result = await _getTodaySnapshot.call();

    if (isClosed) {
      return;
    }

    result.fold(
      (AppException error) => emit(SummaryState.error(error: error)),
      (DailySnapshot snapshot) {
        if (snapshot.isEmpty) {
          emit(const SummaryState.empty());
        } else {
          emit(SummaryState.loaded(snapshot: snapshot));
        }
      },
    );
  }
}
