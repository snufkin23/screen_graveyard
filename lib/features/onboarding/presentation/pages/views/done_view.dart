import 'package:flutter/material.dart';import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/localization/localization.dart';


class DoneView extends StatelessWidget {
  const DoneView({required this.onFinish, super.key});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle_rounded,
            size: 100.w,
            color: Colors.green,
          ),
          32.verticalSpace,
          Text(
            localization.allSetTitle,
            style: AppTextStyles.headlineLarge,
          ),
          16.verticalSpace,
          Text(
            localization.allSetSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          48.verticalSpace,
          CustomButton.text(
            label: localization.goToApp,
            onPressed: onFinish,
            expanded: true,
          ),
        ],
      ),
    );
  }
}
