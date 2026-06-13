import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/onboarding/presentation/blocs/onboarding/onboarding_cubit.dart';
import 'package:screen_graveyard/localization/localization.dart';

/// Reusable permission page wired into [OnboardingCubit] for state management.
///
/// No `setState` — all state (granted / checking / requesting) is read from
/// the cubit's [OnboardingState.permission] variant.
class OnboardingPermissionPage extends StatelessWidget {
  const OnboardingPermissionPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.onContinue,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final Color primary = context.colors.primary;

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (BuildContext context, OnboardingState state) {
        final bool isGranted = state.maybeWhen(
          permission: (bool g, bool c, bool r) => g,
          orElse: () => false,
        );
        final bool isChecking = state.maybeWhen(
          permission: (bool g, bool c, bool r) => c,
          orElse: () => false,
        );
        final bool isRequesting = state.maybeWhen(
          permission: (bool g, bool c, bool r) => r,
          orElse: () => false,
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Spacer(flex: 2),

              // ── Icon badge ────────────────────────────────────────────────
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: isGranted ? AppColors.success.withValues(alpha: 0.12) : primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: isChecking
                    ? Padding(
                        padding: EdgeInsets.all(18.w),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primary,
                        ),
                      )
                    : Icon(
                        isGranted ? Icons.check_circle_outline_rounded : icon,
                        color: isGranted ? AppColors.success : primary,
                        size: 32.sp,
                      ),
              ),

              SizedBox(height: 28.h),

              // ── Title ──────────────────────────────────────────────────────
              Text(
                title,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: context.colors.onSurface,
                ),
              ),

              SizedBox(height: 16.h),

              // ── Description ────────────────────────────────────────────────
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.appColors.onSurfaceTertiary,
                  height: 1.6,
                ),
              ),

              // ── System-settings hint ───────────────────────────────────────
              if (!isGranted) ...<Widget>[
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: context.colors.onSurfaceVariant,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          localization.permissionHint,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Granted confirmation banner ───────────────────────────────
              if (isGranted) ...<Widget>[
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        localization.permissionGrantedMessage,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(flex: 3),

              // ── CTA ────────────────────────────────────────────────────────
              CustomButton(
                label: isGranted ? localization.permissionContinue : localization.permissionGrantAccess,
                onPressed: isGranted ? onContinue : () => context.read<OnboardingCubit>().requestUsageStatsPermission(),
                expanded: true,
                isLoading: !isGranted && isRequesting,
                disabled: !isGranted && isChecking,
              ),

              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }
}
