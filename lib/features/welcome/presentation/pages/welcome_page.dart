import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/router/app_router.gr.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/welcome/presentation/blocs/welcome/welcome_cubit.dart';
import 'package:screen_graveyard/localization/localization.dart';

@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: <Widget>[
              const Spacer(),
              // Brand Icon/Illustration
              const Icon(
                Icons.auto_awesome_rounded,
                size: 120,
                color: AppColors.primary,
              ),
              SizedBox(height: 48.h),
              Text(
                localization.welcomeScreenTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.displayLarge,
              ),
              SizedBox(height: 16.h),
              Text(
                localization.welcomeScreenDesc,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
              const Spacer(),
              CustomButton(
                label: localization.getStarted,
                onPressed: () {
                  context.read<WelcomeCubit>().complete();
                  context.router.replace(const OnboardingRoute());
                },
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
