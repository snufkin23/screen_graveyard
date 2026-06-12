part of 'onboarding_cubit.dart';

@freezed
sealed class OnboardingState with _$OnboardingState {
  const factory OnboardingState.introduction() = _Introduction;

  const factory OnboardingState.about() = _About;

  const factory OnboardingState.permission() = _Permission;

  const factory OnboardingState.completed() = _Completed;
}
