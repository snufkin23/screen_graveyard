import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/app_locale/app_locale_cubit.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/app_permission/app_permission_cubit.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/app_startup/app_startup_cubit.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/app_theme/app_theme_cubit.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/notification/notification_cubit.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/storage/local_storage.dart';
import 'package:screen_graveyard/features/onboarding/presentation/blocs/onboarding/onboarding_cubit.dart';

class GlobalAppConfig {
  const GlobalAppConfig({required this.locale, required this.themeMode});
  final Locale locale;
  final ThemeMode themeMode;
}

class GlobalConfigProvider extends InheritedWidget {
  const GlobalConfigProvider({
    required this.config,
    required super.child,
    super.key,
  });
  final GlobalAppConfig config;

  static GlobalAppConfig of(BuildContext context) {
    final GlobalConfigProvider? provider =
        context.dependOnInheritedWidgetOfExactType<GlobalConfigProvider>();
    if (provider == null) {
      throw Exception('GlobalConfigProvider not found in context');
    }
    return provider.config;
  }

  @override
  bool updateShouldNotify(GlobalConfigProvider oldWidget) {
    return config.locale != oldWidget.config.locale ||
        config.themeMode != oldWidget.config.themeMode;
  }
}

class GlobalAppProvider extends StatelessWidget {
  const GlobalAppProvider({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<AppStartupCubit>(
          create: (_) => AppStartupCubit(getIt<LocalStorage>()),
        ),
        BlocProvider<AppThemeCubit>(
          create: (_) => AppThemeCubit(getIt<LocalStorage>()),
        ),
        BlocProvider<AppLocaleCubit>(
          create: (_) => getIt<AppLocaleCubit>(),
        ),
        BlocProvider<AppPermissionCubit>(create: (_) => AppPermissionCubit()),
        BlocProvider<NotificationCubit>(
          create: (_) => getIt<NotificationCubit>(),
        ),
        BlocProvider<OnboardingCubit>(
          create: (_) => OnboardingCubit(getIt<LocalStorage>()),
        ),
      ],
      child: BlocBuilder<AppThemeCubit, ThemeMode>(
        builder: (BuildContext context, ThemeMode themeMode) {
          return BlocBuilder<AppLocaleCubit, AppLocale>(
            builder: (BuildContext context, AppLocale appLocale) {
              return GlobalConfigProvider(
                config: GlobalAppConfig(
                  locale: appLocale.locale,
                  themeMode: themeMode,
                ),
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
