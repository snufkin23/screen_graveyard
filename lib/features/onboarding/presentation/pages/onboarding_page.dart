import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/router/app_router.gr.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/onboarding/presentation/blocs/onboarding/onboarding_cubit.dart';
import 'package:screen_graveyard/features/onboarding/presentation/widgets/onboarding_permission_page.dart';
import 'package:screen_graveyard/features/onboarding/presentation/widgets/onboarding_progress_indicator.dart';
import 'package:screen_graveyard/localization/localization.dart';

@RoutePage()
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (_) => getIt<OnboardingCubit>(),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> with WidgetsBindingObserver {
  late final PageController _pageController;

  // Page index → onboarding step mapping
  // 0: introduction, 1: about, 2: permission (usage stats)
  static const int _totalPages = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int initialIndex = context.read<OnboardingCubit>().state.when(
            introduction: () => 0,
            about: () => 1,
            permission: (bool a, bool b, bool c) => 2,
            completed: () => 2,
          );
      if (initialIndex > 0) {
        _pageController.jumpToPage(initialIndex);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  /// Forward app lifecycle events to the cubit so it can re-check
  /// permissions after the user returns from system settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      context.read<OnboardingCubit>().onResume();
    }
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (OnboardingState prev, OnboardingState curr) =>
          curr.maybeWhen(completed: () => true, orElse: () => false),
      listener: (BuildContext context, OnboardingState state) {
        context.router.replaceAll(<PageRouteInfo<Object?>>[const SummaryRoute()]);
      },
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (BuildContext context, OnboardingState state) {
          final int currentIndex = state.when(
            introduction: () => 0,
            about: () => 1,
            permission: (bool a, bool b, bool c) => 2,
            completed: () => 2,
          );

          return CustomScaffold(
            scaffoldBackgroundColor: context.colors.surface,
            usePadding: false,
            body: Column(
              children: <Widget>[
                // ── Progress indicator ───────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
                  child: OnboardingProgressIndicator(
                    currentIndex: currentIndex,
                    total: _totalPages,
                  ),
                ),

                // ── Pages ────────────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      // Page 0 — Introduction
                      IntroductionPage(
                        onContinue: () {
                          context.read<OnboardingCubit>().next();
                          _goToPage(1);
                        },
                      ),

                      // Page 1 — About
                      AboutPage(
                        onContinue: () {
                          context.read<OnboardingCubit>().next();
                          _goToPage(2);
                        },
                      ),

                      // Page 2 — Usage Stats Permission
                      OnboardingPermissionPage(
                        title: localization.permissionTitle,
                        description: localization.permissionDesc,
                        icon: Icons.query_stats_rounded,
                        onContinue: () {
                          context.read<OnboardingCubit>().next();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Page 0 — Introduction
// ═══════════════════════════════════════════════════════════════════════════════

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Spacer(flex: 2),
          Text(
            localization.introTitle,
            style: AppTextStyles.headlineLarge.copyWith(
              color: context.colors.onSurface,
              height: 1.2,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            localization.introDesc,
            style: AppTextStyles.bodyLarge.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const Spacer(flex: 3),
          CustomButton.iconText(
            icon: const Icon(Icons.arrow_forward_rounded),
            label: localization.introButton,
            onPressed: onContinue,
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Page 1 — About (what we track)
// ═══════════════════════════════════════════════════════════════════════════════

class AboutPage extends StatelessWidget {
  const AboutPage({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final Color primary = context.colors.primary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Spacer(flex: 2),
          Text(
            localization.aboutTitle,
            style: AppTextStyles.headlineLarge.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: 32.h),
          AboutItem(
            icon: Icons.lock_open_rounded,
            title: localization.aboutUnlocksTitle,
            subtitle: localization.aboutUnlocksDesc,
            iconColor: primary,
          ),
          SizedBox(height: 24.h),
          AboutItem(
            icon: Icons.apps_rounded,
            title: localization.aboutAppUsageTitle,
            subtitle: localization.aboutAppUsageDesc,
            iconColor: primary,
          ),
          SizedBox(height: 24.h),
          AboutItem(
            icon: Icons.notifications_off_outlined,
            title: localization.aboutDismissedTitle,
            subtitle: localization.aboutDismissedDesc,
            iconColor: primary,
          ),
          SizedBox(height: 32.h),
          Row(
            children: <Widget>[
              Icon(
                Icons.shield_outlined,
                size: 16,
                color: primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  localization.aboutPrivacy,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(flex: 2),
          CustomButton.iconText(
            icon: const Icon(Icons.check_rounded),
            label: localization.aboutButton,
            onPressed: onContinue,
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

class AboutItem extends StatelessWidget {
  const AboutItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: iconColor, size: 22.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.appColors.onSurfaceTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
