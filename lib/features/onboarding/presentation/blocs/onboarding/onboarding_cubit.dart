import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/constants/app_constants.dart';
import 'package:screen_graveyard/core/storage/local_storage.dart';
import 'package:screen_graveyard/features/onboarding/domain/model/onboarding_step.dart';

part 'onboarding_state.dart';
part 'onboarding_cubit.freezed.dart';

@lazySingleton
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._storage) : super(const OnboardingState.introduction()) {
    _loadPersistedState();
  }

  final LocalStorage _storage;

  void _loadPersistedState() {
    final String? storedStepName = _storage.get<String>(AppConstants.onboardingStepKey);
    final OnboardingStep step = OnboardingStep.fromString(storedStepName);
    emit(_mapStepToState(step));
  }

  void next() {
    final OnboardingStep currentStep = _mapStateToStep(state);
    final OnboardingStep nextStep = _getNextStep(currentStep);

    _persistAndEmit(nextStep);
  }

  void previous() {
    final OnboardingStep currentStep = _mapStateToStep(state);
    final OnboardingStep prevStep = _getPreviousStep(currentStep);

    _persistAndEmit(prevStep);
  }

  void reset() {
    _persistAndEmit(OnboardingStep.introduction);
  }

  void _persistAndEmit(OnboardingStep step) {
    _storage.put(AppConstants.onboardingStepKey, step.toStorageString());
    emit(_mapStepToState(step));
  }

  static OnboardingStep _getNextStep(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.introduction => OnboardingStep.about,
      OnboardingStep.about => OnboardingStep.permission,
      OnboardingStep.permission => OnboardingStep.completed,
      OnboardingStep.completed => OnboardingStep.completed,
    };
  }

  static OnboardingStep _getPreviousStep(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.introduction => OnboardingStep.introduction,
      OnboardingStep.about => OnboardingStep.introduction,
      OnboardingStep.permission => OnboardingStep.about,
      OnboardingStep.completed => OnboardingStep.permission,
    };
  }

  static OnboardingState _mapStepToState(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.introduction => const OnboardingState.introduction(),
      OnboardingStep.about => const OnboardingState.about(),
      OnboardingStep.permission => const OnboardingState.permission(),
      OnboardingStep.completed => const OnboardingState.completed(),
    };
  }

  static OnboardingStep _mapStateToStep(OnboardingState state) {
    return state.when(
      introduction: () => OnboardingStep.introduction,
      about: () => OnboardingStep.about,
      permission: () => OnboardingStep.permission,
      completed: () => OnboardingStep.completed,
    );
  }
}
