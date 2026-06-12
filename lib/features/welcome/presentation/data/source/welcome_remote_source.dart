import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/storage/storage.dart';

abstract interface class WelcomeRemoteSource {
  Future<bool> getWelcomeStatus();
  Future<void> setWelcome();
}

@LazySingleton(as: WelcomeRemoteSource)
class WelcomeRemoteSourceImpl implements WelcomeRemoteSource {
  WelcomeRemoteSourceImpl(this._storage);

  final LocalStorage _storage;

  @override
  Future<bool> getWelcomeStatus() async {
    return _storage.get<bool>(StorageKeys.isWelcome) ?? false;
  }

  @override
  Future<void> setWelcome() async {
    await _storage.put<bool>(StorageKeys.isWelcome, true);
  }
}
