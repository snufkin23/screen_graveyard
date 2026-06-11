import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nested/nested.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/router/app_router.dart';
import 'package:screen_graveyard/core/theme/theme.dart';
import 'package:screen_graveyard/localization/localization.dart';

import 'blocs/app_startup/app_startup_cubit.dart';
import 'global_app_provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AppRouter _appRouter = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return GlobalAppProvider(
      child: MultiBlocListener(
        listeners: <SingleChildWidget>[
          BlocListener<AppStartupCubit, AppStartupState>(
            listener: (BuildContext _, AppStartupState state) {
              state.maybeWhen(
                orElse: () {},
                initial: () => _appRouter.replaceAll(<PageRouteInfo<Object?>>[
                  const WelcomeRoute(),
                ]),
                onboarding: () {
                  _appRouter.replaceAll(<PageRouteInfo<Object?>>[
                    const OnboardingRoute(),
                  ]);
                },
                ready: () {
                  _appRouter.replaceAll(<PageRouteInfo<Object?>>[
                    const HomeRoute(),
                  ]);
                },
              );
            },
          ),
        ],
        child: _AppMaterialRouter(appRouter: _appRouter),
      ),
    );
  }
}

class _AppMaterialRouter extends StatelessWidget {
  const _AppMaterialRouter({required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilPlusInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        routerConfig: appRouter.config(),
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: GlobalConfigProvider.of(context).themeMode,
        locale: GlobalConfigProvider.of(context).locale,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
      ),
    );
  }
}
