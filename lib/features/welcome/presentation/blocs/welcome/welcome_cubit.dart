import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/features/welcome/presentation/domain/repository/welcome_repository.dart';

@lazySingleton
class WelcomeCubit extends Cubit<bool> {
  WelcomeCubit(this._repository) : super(false);
  final WelcomeRepository _repository;

  void setWelcome() async {
    await _repository.setWelcome();
    emit(true);
  }
}
