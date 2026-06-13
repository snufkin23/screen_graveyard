import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/router/app_router.gr.dart';
import 'package:screen_graveyard/core/theme/theme.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/welcome/presentation/blocs/welcome/welcome_cubit.dart';
import 'package:screen_graveyard/localization/localization.dart';

@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WelcomeCubit>(
      create: (_) => getIt<WelcomeCubit>(),
      child: const WelcomeView(),
    );
  }
}

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WelcomeCubit, bool>(
      listener: (BuildContext context, bool state) {
        if (state) {
          context.router.replaceAll(<PageRouteInfo<Object?>>[
            const OnboardingRoute(),
          ]);
        }
      },
      child: CustomScaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: <Widget>[
                const Spacer(),
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 120,
                  color: context.colors.primary,
                ),
                SizedBox(height: 48.h),
                Text(
                  localization.welcomeScreenTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  localization.welcomeScreenDesc,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: SafeArea(
                    top: false,
                    child: CustomButton.iconText(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: localization.getStarted,
                      onPressed: () => context.read<WelcomeCubit>().setWelcome(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
