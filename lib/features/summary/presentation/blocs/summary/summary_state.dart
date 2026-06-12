part of 'summary_cubit.dart';

@freezed
sealed class SummaryState with _$SummaryState {
  const factory SummaryState.initial() = _SummaryInitial;

  const factory SummaryState.loading() = _SummaryLoading;

  const factory SummaryState.loaded({
    required DailySnapshot snapshot,
  }) = _SummaryLoaded;

  const factory SummaryState.empty() = _SummaryEmpty;

  const factory SummaryState.error({
    required AppException error,
  }) = _SummaryError;
}
