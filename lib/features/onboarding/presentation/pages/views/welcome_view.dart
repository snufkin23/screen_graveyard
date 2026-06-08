import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/custom_button.dart';
import 'package:screen_graveyard/localization/localization.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.rocket_launch_rounded,
            size: 100.w,
            color: Theme.of(context).colorScheme.primary,
          ),
          32.verticalSpace,
          Text(
            localization.onboardingTitle1,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge,
          ),
          16.verticalSpace,
          Text(
            localization.onboardingDesc1,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          48.verticalSpace,
          CustomButton.text(
            label: localization.getStarted,
            onPressed: onNext,
            expanded: true,
          ),
        ],
      ),
    );
  }
}
