import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'app_router.gr.dart';
export 'app_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(page: WelcomeRoute.page, initial: true),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(page: SummaryRoute.page),
        AutoRoute(page: HistoryRoute.page),
        AutoRoute(page: SettingsRoute.page),
      ];
}
