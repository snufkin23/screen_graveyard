import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ExternalModule {
  @singleton
  DeviceInfoPlugin get deviceInfo => DeviceInfoPlugin();
}
