import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_graveyard/core/logger/app_logger.dart';

@singleton
class PermissionService {
  PermissionService(this._deviceInfo);

  final DeviceInfoPlugin _deviceInfo;

  static const MethodChannel _channel = MethodChannel(
    'com.sushant.screengraveyard/usage_stats',
  );

  // ── Notification ───────────────────────────────────────────────────────────

  Future<PermissionStatus> isNotificationGranted() async {
    return Permission.notification.status;
  }

  Future<PermissionStatus> requestNotification() async {
    final PermissionStatus status = await Permission.notification.request();
    AppLogger.d('Notification permission: $status');
    return status;
  }

  // ── Usage Stats (PACKAGE_USAGE_STATS) ─────────────────────────────────────

  Future<PermissionStatus> isUsageStatsGranted() async {
    try {
      final bool granted = await _channel.invokeMethod<bool>(
            'isUsageStatsPermissionGranted',
          ) ??
          false;
      return granted ? PermissionStatus.granted : PermissionStatus.denied;
    } on PlatformException catch (e) {
      AppLogger.e('UsageStats permission check failed : $e');
      return PermissionStatus.denied;
    }
  }

  Future<void> openUsageStatsSettings() async {
    try {
      await _channel.invokeMethod<void>('openUsageAccessSettings');
    } on PlatformException catch (e) {
      AppLogger.e('Failed to open usage access settings : $e');
    }
  }

  // ── Storage ───────────────────────────────────────────────────────────────

  Future<PermissionStatus> isStorageGranted() async {
    final int sdkInt = await _getSdkInt();

    if (sdkInt >= 33) {
      return Permission.photos.status;
    }

    return Permission.storage.status;
  }

  Future<PermissionStatus> requestStorage() async {
    final int sdkInt = await _getSdkInt();

    if (sdkInt >= 33) {
      final PermissionStatus status = await Permission.photos.request();
      AppLogger.d('Storage (photos) permission: $status');
      return status;
    }

    final PermissionStatus status = await Permission.storage.request();
    AppLogger.d('Storage permission: $status');
    return status;
  }

  // ── All ───────────────────────────────────────────────────────────────────

  Future<PermissionStatusBundle> checkAll() async {
    final PermissionStatus notification = await isNotificationGranted();
    final PermissionStatus usageStats = await isUsageStatsGranted();
    final PermissionStatus storage = await isStorageGranted();

    return PermissionStatusBundle(
      notification: notification,
      usageStats: usageStats,
      storage: storage,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<int> _getSdkInt() async {
    try {
      final AndroidDeviceInfo info = await _deviceInfo.androidInfo;
      return info.version.sdkInt;
    } catch (e) {
      AppLogger.e('Failed to get SDK int', e);
      return 0;
    }
  }
}

class PermissionStatusBundle {
  const PermissionStatusBundle({
    required this.notification,
    required this.usageStats,
    required this.storage,
  });

  final PermissionStatus notification;
  final PermissionStatus usageStats;
  final PermissionStatus storage;

  bool get allGranted => notification.isGranted && usageStats.isGranted && storage.isGranted;

  PermissionStatusBundle copyWith({
    PermissionStatus? notification,
    PermissionStatus? usageStats,
    PermissionStatus? storage,
  }) {
    return PermissionStatusBundle(
      notification: notification ?? this.notification,
      usageStats: usageStats ?? this.usageStats,
      storage: storage ?? this.storage,
    );
  }

  @override
  String toString() {
    return 'PermissionStatusBundle('
        'notification: $notification, '
        'usageStats: $usageStats, '
        'storage: $storage'
        ')';
  }
}
