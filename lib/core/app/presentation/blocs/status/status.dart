import 'package:freezed_annotation/freezed_annotation.dart';

part 'status.freezed.dart';

@freezed
sealed class Status with _$Status {
  const factory Status.initial() = _Initial;

  const factory Status.loading() = _Loading;

  const factory Status.success({
    String? message,
  }) = _Success;

  const factory Status.error({
    String? message,
    String? code,
  }) = _Error;
}
