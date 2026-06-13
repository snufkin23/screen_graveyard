import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';

/// A reusable settings tile with icon, label, trailing widget, and tap handler.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.pagePadding,
          vertical: AppSizes.lg,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerDark,
          border: Border(
            bottom: BorderSide(
              color: AppColors.dividerDark,
              width: 0.8,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            // Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                icon,
                size: AppSizes.iconSm,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppSizes.md),
            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceTertiaryDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trailing widget (e.g. switch, chevron, selector)
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
