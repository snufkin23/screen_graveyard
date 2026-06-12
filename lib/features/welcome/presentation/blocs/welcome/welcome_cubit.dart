import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/features/welcome/presentation/domain/repository/welcome_repository.dart';

@lazySingleton
class WelcomeCubit extends Cubit<void> {
  WelcomeCubit(this._repository) : super(null);
  final WelcomeRepository _repository;

  void setWelcome() async {
    await _repository.setWelcome();
  }
}
