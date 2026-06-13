import 'package:flutter/material.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    required this.title,
    this.icon,
    super.key,
  });

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.pagePadding,
        right: AppSizes.pagePadding,
        top: AppSizes.xxl,
        bottom: AppSizes.md,
      ),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(
              icon,
              size: AppSizes.iconSm,
              color: AppColors.primary,
            ),
            SizedBox(width: AppSizes.sm),
          ],
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurfaceDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
