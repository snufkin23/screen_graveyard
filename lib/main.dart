import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:screen_graveyard/core/app/presentation/app.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/app_bloc_observer.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/logger/app_logger.dart';
import 'package:screen_graveyard/core/notifications/notification_service.dart';
import 'package:screen_graveyard/firebase_options.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      final WidgetsBinding widgetsBinding =
          WidgetsFlutterBinding.ensureInitialized();

      // ── Splash ─────────────────────────────────────────────────
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      // ── Firebase ───────────────────────────────────────────────────
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // ── Flutter framework errors ────────────────────────────────
      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.e('Flutter Error', details.exception, details.stack);
        FlutterError.presentError(details);
      };

      // ── Bloc Observer ───────────────────────────────────────────────
      Bloc.observer = AppBlocObserver();

      // ── Dependency injection ────────────────────────────────────
      await configureDependencies();

      // ── Notification service ────────────────────────────────────
      getIt<NotificationService>();

      runApp(const App());
    },
    // ── Dart async errors (outside Flutter framework) ─────────────
    (Object error, StackTrace stack) {
      AppLogger.e('Unhandled error', error, stack);
      // tODO: send to Crashlytics / Sentry in production
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}
