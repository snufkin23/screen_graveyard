part of 'history_cubit.dart';

@freezed
sealed class HistoryState with _$HistoryState {
  const factory HistoryState.initial() = _HistoryInitial;
  const factory HistoryState.loading() = _HistoryLoading;
  const factory HistoryState.loaded({
    required WeeklyStats stats,
  }) = _HistoryLoaded;
  const factory HistoryState.empty() = _HistoryEmpty;
  const factory HistoryState.error({
    required AppException error,
  }) = _HistoryError;
}
