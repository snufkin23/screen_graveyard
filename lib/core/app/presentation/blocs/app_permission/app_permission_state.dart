part of 'app_permission_cubit.dart';

enum AppPermissionStep {
  introduction,
  about,
  permission,
  completed;

  bool get isIntroduction => this == AppPermissionStep.introduction;
  bool get isCompleted => this == AppPermissionStep.completed;
}

@freezed
sealed class AppPermissionState with _$AppPermissionState {
  const AppPermissionState._();
  const factory AppPermissionState({
    @Default(AppPermissionStep.introduction) AppPermissionStep step,
    @Default(PermissionStatus.denied) PermissionStatus notification,
    @Default(PermissionStatus.denied) PermissionStatus usageAccess,
    @Default(PermissionStatus.denied) PermissionStatus storage,
  }) = _AppPermissionState;

  bool get allPermissionsGranted => notification.isGranted && usageAccess.isGranted && storage.isGranted;
}
