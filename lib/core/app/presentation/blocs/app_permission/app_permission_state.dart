part of 'app_permission_cubit.dart';

enum AppPermissionStep {
  introduction,
  about,
  permission,
  completed;

  bool get isIntroduction => this == AppPermissionStep.introduction;
  bool get isAbout => this == AppPermissionStep.about;
  bool get isPermission => this == AppPermissionStep.permission;
  bool get isCompleted => this == AppPermissionStep.completed;
}

@freezed
sealed class AppPermissionState with _$AppPermissionState {
  const factory AppPermissionState({
    @Default(AppPermissionStep.introduction) AppPermissionStep step,
    @Default(PermissionStatus.denied) PermissionStatus notification,
    @Default(PermissionStatus.denied) PermissionStatus usageAccess,
    @Default(PermissionStatus.denied) PermissionStatus storage,
  }) = _AppPermissionState;

  const AppPermissionState._();

  bool get allPermissionsGranted => notification.isGranted && usageAccess.isGranted && storage.isGranted;

  bool get canContinue => !step.isPermission || allPermissionsGranted;
}
