import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/constants/app_constants.dart';
import 'package:screen_graveyard/core/storage/local_storage.dart';
import 'package:screen_graveyard/features/welcome/domain/model/welcome_status.dart';

part 'welcome_state.dart';
part 'welcome_cubit.freezed.dart';

@lazySingleton
class WelcomeCubit extends Cubit<WelcomeState> {
  WelcomeCubit(this._storage) : super(const WelcomeState.initial()) {
    _loadPersistedState();
  }

  final LocalStorage _storage;

  void _loadPersistedState() {
    final String? storedStatusName = _storage.get<String>(AppConstants.welcomeStatusKey);
    final WelcomeStatus status = WelcomeStatus.fromString(storedStatusName);
    emit(_mapStatusToState(status));
  }

  void complete() {
    _persistAndEmit(WelcomeStatus.completed);
  }

  void reset() {
    _persistAndEmit(WelcomeStatus.initial);
  }

  void _persistAndEmit(WelcomeStatus status) {
    _storage.put(AppConstants.welcomeStatusKey, status.toStorageString());
    emit(_mapStatusToState(status));
  }

  static WelcomeState _mapStatusToState(WelcomeStatus status) {
    return switch (status) {
      WelcomeStatus.initial => const WelcomeState.initial(),
      WelcomeStatus.completed => const WelcomeState.completed(),
    };
  }
}
