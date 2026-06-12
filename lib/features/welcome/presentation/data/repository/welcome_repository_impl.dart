import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/features/welcome/presentation/data/source/welcome_remote_source.dart';
import 'package:screen_graveyard/features/welcome/presentation/domain/repository/welcome_repository.dart';

@LazySingleton(as: WelcomeRepository)
class WelcomeRepositoryImpl implements WelcomeRepository {
  WelcomeRepositoryImpl(this._remoteSource);

  final WelcomeRemoteSource _remoteSource;

  @override
  Future<bool> isWelcome() => _remoteSource.getWelcomeStatus();

  @override
  Future<void> setWelcome() => _remoteSource.setWelcome();
}
