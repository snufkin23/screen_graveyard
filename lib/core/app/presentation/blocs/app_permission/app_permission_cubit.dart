import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

part 'app_permission_cubit.freezed.dart';
part 'app_permission_state.dart';

@injectable
class AppPermissionCubit extends Cubit<AppPermissionState> {
  AppPermissionCubit() : super(const AppPermissionState());

  // ─────────────────────────────────────────────
  // FSM Navigation
  // ─────────────────────────────────────────────

  void next() {
    switch (state.step) {
      case AppPermissionStep.introduction:
        emit(state.copyWith(step: AppPermissionStep.about));

      case AppPermissionStep.about:
        emit(state.copyWith(step: AppPermissionStep.permission));

      case AppPermissionStep.permission:
        if (!state.allPermissionsGranted) {
          return;
        }

        emit(state.copyWith(step: AppPermissionStep.completed));

      case AppPermissionStep.completed:
        break;
    }
  }

  void previous() {
    switch (state.step) {
      case AppPermissionStep.introduction:
        break;

      case AppPermissionStep.about:
        emit(state.copyWith(step: AppPermissionStep.introduction));

      case AppPermissionStep.permission:
        emit(state.copyWith(step: AppPermissionStep.about));

      case AppPermissionStep.completed:
        emit(state.copyWith(step: AppPermissionStep.permission));
    }
  }

  // ─────────────────────────────────────────────
  // Permission Updates
  // ─────────────────────────────────────────────

  void updateNotification(
    PermissionStatus status,
  ) {
    emit(
      state.copyWith(
        notification: status,
      ),
    );
  }

  void updateUsageAccess(
    PermissionStatus status,
  ) {
    emit(
      state.copyWith(
        usageAccess: status,
      ),
    );
  }

  void updateStorage(
    PermissionStatus status,
  ) {
    emit(
      state.copyWith(
        storage: status,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Restore saved onboarding step
  // ─────────────────────────────────────────────

  void restore(AppPermissionStep step) {
    emit(
      state.copyWith(
        step: step,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Mark complete
  // ─────────────────────────────────────────────

  void complete() {
    emit(
      state.copyWith(
        step: AppPermissionStep.completed,
      ),
    );
  }
}
