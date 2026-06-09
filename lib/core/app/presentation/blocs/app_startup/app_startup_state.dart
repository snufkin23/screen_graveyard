part of 'app_startup_cubit.dart';

@freezed
sealed class AppStartupState with _$AppStartupState {
  const factory AppStartupState.initial() = Initial;

  const factory AppStartupState.onboarding() = Onboarding;

  const factory AppStartupState.ready() = Ready;
}
