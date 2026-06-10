import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_graveyard/core/logger/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<Object?> bloc) {
    super.onCreate(bloc);
    AppLogger.i('Created ${bloc.runtimeType}');
  }

  @override
  void onEvent(
    Bloc<Object?, Object?> bloc,
    Object? event,
  ) {
    super.onEvent(bloc, event);
    AppLogger.i('Event in ${bloc.runtimeType}: $event');
  }

  @override
  void onChange(
    BlocBase<Object?> bloc,
    Change<Object?> change,
  ) {
    super.onChange(bloc, change);

    AppLogger.d(
      '[${bloc.runtimeType}] '
      '${change.currentState} -> ${change.nextState}',
    );
  }

  @override
  void onTransition(
    Bloc<Object?, Object?> bloc,
    Transition<Object?, Object?> transition,
  ) {
    super.onTransition(bloc, transition);

    AppLogger.i(
      '[${bloc.runtimeType}] '
      '${transition.currentState} -> ${transition.nextState}',
    );
  }

  @override
  void onError(
    BlocBase<Object?> bloc,
    Object error,
    StackTrace stackTrace,
  ) {
    AppLogger.e(
      'Error in ${bloc.runtimeType}',
      error,
      stackTrace,
    );

    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<Object?> bloc) {
    AppLogger.i('Closed ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}
