import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/logger/app_logger.dart';

/// Raw map returned from the Kotlin channel before mapping to domain models.
typedef RawDailySummary = Map<String, dynamic>;

abstract interface class UsageStatsDatasource {
  Future<RawDailySummary> getDailySummary();
}

@LazySingleton(as: UsageStatsDatasource)
class UsageStatsDatasourceImpl implements UsageStatsDatasource {
  UsageStatsDatasourceImpl();

  static const MethodChannel _channel = MethodChannel(
    'com.sushant.screen_graveyard/usage_stats',
  );

  @override
  Future<RawDailySummary> getDailySummary() async {
    try {
      final Map<dynamic, dynamic> raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
            'getDailySummary',
          ) ??
          <dynamic, dynamic>{};

      return raw.map<String, dynamic>(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      );
    } on PlatformException catch (e) {
      AppLogger.e('getDailySummary failed', e);
      rethrow;
    }
  }
}
