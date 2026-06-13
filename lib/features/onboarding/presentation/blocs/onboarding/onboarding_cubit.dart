import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_graveyard/core/constants/app_constants.dart';
import 'package:screen_graveyard/core/permissions/permission_service.dart';
import 'package:screen_graveyard/core/storage/local_storage.dart';
import 'package:screen_graveyard/features/onboarding/domain/model/onboarding_step.dart';

part 'onboarding_state.dart';
part 'onboarding_cubit.freezed.dart';

@lazySingleton
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._storage, this._permissionService) : super(const OnboardingState.introduction()) {
    _loadPersistedState();
  }

  final LocalStorage _storage;
  final PermissionService _permissionService;

  bool _wasOpenedSettings = false;

  // ── Persistence ───────────────────────────────────────────────────────────

  void _loadPersistedState() {
    final String? storedStepName = _storage.get<String>(AppConstants.onboardingStepKey);
    final OnboardingStep step = OnboardingStep.fromString(storedStepName);

    if (step == OnboardingStep.permission) {
      emit(const OnboardingState.permission(isChecking: true));
      checkUsageStatsPermission();
    } else if (step == OnboardingStep.storage) {
      emit(const OnboardingState.storage(isChecking: true));
      checkStoragePermission();
    } else {
      emit(_mapStepToState(step));
    }
  }

  void _persistAndEmit(OnboardingStep step) {
    _storage.put(AppConstants.onboardingStepKey, step.toStorageString());

    if (step == OnboardingStep.permission) {
      emit(const OnboardingState.permission(isChecking: true));
      checkUsageStatsPermission();
    } else if (step == OnboardingStep.storage) {
      emit(const OnboardingState.storage(isChecking: true));
      checkStoragePermission();
    } else {
      emit(_mapStepToState(step));
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

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

  /// Directly save a step (used by the page's imperative navigation).
  void saveStep(OnboardingStep step) {
    _persistAndEmit(step);
  }

  /// Public helper to extract the current step from the sealed state.
  OnboardingStep get currentStep {
    return state.when(
      introduction: () => OnboardingStep.introduction,
      about: () => OnboardingStep.about,
      permission: (_, __, ___) => OnboardingStep.permission,
      storage: (_, __, ___) => OnboardingStep.storage,
      completed: () => OnboardingStep.completed,
    );
  }

  // ── Lifecycle (called from page's WidgetsBindingObserver) ─────────────────

  void onResume() {
    if (_wasOpenedSettings) {
      _wasOpenedSettings = false;
      checkUsageStatsPermission();
    }
  }

  // ── Permission: Usage Stats ───────────────────────────────────────────────

  Future<void> checkUsageStatsPermission() async {
    final bool isNowGranted = await _permissionService.isUsageStatsGranted().then(
          (PermissionStatus status) => status == PermissionStatus.granted,
        );

    if (!isClosed) {
      emit(
        state.maybeWhen(
          permission: (
            bool g,
            bool c,
            bool requesting,
          ) =>
              OnboardingState.permission(
            isUsageStatsGranted: isNowGranted,
            isChecking: false,
            isRequesting: requesting,
          ),
          orElse: () => state,
        ),
      );
    }
  }

  Future<void> requestUsageStatsPermission() async {
    emit(
      state.maybeWhen(
        permission: (
          bool granted,
          bool checking,
          bool requesting,
        ) =>
            OnboardingState.permission(
          isUsageStatsGranted: granted,
          isChecking: checking,
          isRequesting: true,
        ),
        orElse: () => state,
      ),
    );

    _wasOpenedSettings = true;
    await _permissionService.openUsageStatsSettings();

    // Don't re-check here — onResume handles it when user returns from settings.
    if (!isClosed) {
      emit(
        state.maybeWhen(
          permission: (
            bool granted,
            bool checking,
            bool requesting,
          ) =>
              OnboardingState.permission(
            isUsageStatsGranted: granted,
            isChecking: checking,
            isRequesting: false,
          ),
          orElse: () => state,
        ),
      );
    }
  }

  // ── Permission: Storage ───────────────────────────────────────────────────

  Future<void> checkStoragePermission() async {
    final bool isNowGranted = await _permissionService.isStorageGranted().then(
          (PermissionStatus status) => status == PermissionStatus.granted,
        );

    if (!isClosed) {
      emit(
        state.maybeWhen(
          storage: (
            bool g,
            bool c,
            bool requesting,
          ) =>
              OnboardingState.storage(
            isStorageGranted: isNowGranted,
            isChecking: false,
            isRequesting: requesting,
          ),
          orElse: () => state,
        ),
      );
    }
  }

  Future<void> requestStoragePermission() async {
    emit(
      state.maybeWhen(
        storage: (
          bool granted,
          bool checking,
          bool requesting,
        ) =>
            OnboardingState.storage(
          isStorageGranted: granted,
          isChecking: checking,
          isRequesting: true,
        ),
        orElse: () => state,
      ),
    );

    final PermissionStatus result = await _permissionService.requestStorage();
    final bool isNowGranted = result == PermissionStatus.granted;

    if (!isClosed) {
      emit(
        OnboardingState.storage(
          isStorageGranted: isNowGranted,
          isChecking: false,
          isRequesting: false,
        ),
      );
    }
  }

  // ── Step mapping helpers ──────────────────────────────────────────────────

  static OnboardingStep _getNextStep(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.introduction => OnboardingStep.about,
      OnboardingStep.about => OnboardingStep.permission,
      OnboardingStep.permission => OnboardingStep.storage,
      OnboardingStep.storage => OnboardingStep.completed,
      OnboardingStep.completed => OnboardingStep.completed,
    };
  }

  static OnboardingStep _getPreviousStep(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.introduction => OnboardingStep.introduction,
      OnboardingStep.about => OnboardingStep.introduction,
      OnboardingStep.permission => OnboardingStep.about,
      OnboardingStep.storage => OnboardingStep.permission,
      OnboardingStep.completed => OnboardingStep.storage,
    };
  }

  static OnboardingState _mapStepToState(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.introduction => const OnboardingState.introduction(),
      OnboardingStep.about => const OnboardingState.about(),
      OnboardingStep.permission => const OnboardingState.permission(),
      OnboardingStep.storage => const OnboardingState.storage(),
      OnboardingStep.completed => const OnboardingState.completed(),
    };
  }

  static OnboardingStep _mapStateToStep(OnboardingState state) {
    return state.when(
      introduction: () => OnboardingStep.introduction,
      about: () => OnboardingStep.about,
      permission: (bool g, bool c, bool r) => OnboardingStep.permission,
      storage: (bool g, bool c, bool r) => OnboardingStep.storage,
      completed: () => OnboardingStep.completed,
    );
  }
}
