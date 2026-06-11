part of 'welcome_cubit.dart';

@freezed
sealed class WelcomeState with _$WelcomeState {
  const factory WelcomeState.initial() = _Initial;

  const factory WelcomeState.completed() = _Completed;
}
