import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/constants/app_constants.dart';
import 'package:screen_graveyard/core/storage/local_storage.dart';
import 'package:screen_graveyard/core/storage/storage.dart';
import 'package:screen_graveyard/features/onboarding/domain/model/onboarding_step.dart';
import 'package:screen_graveyard/features/welcome/presentation/domain/repository/welcome_repository.dart';

part 'app_startup_cubit.freezed.dart';
part 'app_startup_state.dart';

/// AppStartupCubit is responsible for **deciding the first screen** on app launch:
/// - Shows onboarding if the user has not completed it
/// - Shows home/ready if the user has already completed onboarding
/// It keeps the **native splash visible** until the decision is made.
///
@injectable
class AppStartupCubit extends Cubit<AppStartupState> {
  AppStartupCubit(this._storage, this._welcomeRepository) : super(const AppStartupState.welcome()) {
    _init();
  }

  final LocalStorage _storage;
  final WelcomeRepository _welcomeRepository;

  Future<void> _init() async {
    final bool hasBeenWelcomed = await _welcomeRepository.isWelcome();

    if (hasBeenWelcomed) {
      final String? storedStepName = _storage.get<String>(AppConstants.onboardingStepKey);

      final OnboardingStep step = OnboardingStep.fromString(storedStepName);

      if (step == OnboardingStep.completed) {
        emit(const AppStartupState.ready());
      } else {
        emit(const AppStartupState.onboarding());
      }
    } else {
      emit(const AppStartupState.welcome());
    }

    FlutterNativeSplash.remove();
  }
}
