import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/permissions/permission_service.dart';
import 'package:screen_graveyard/core/router/app_router.gr.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/features/onboarding/domain/model/onboarding_step.dart';
import 'package:screen_graveyard/features/onboarding/presentation/blocs/onboarding/onboarding_cubit.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _contentController;
  late final AnimationController _progressController;
  int _currentIndex = 0;

  static const int _totalPages = 4;

  static const List<String> _stepLabels = <String>[
    'Introduction',
    'About',
    'Usage Access',
    'Storage',
  ];

  @override
  void initState() {
    super.initState();
    final OnboardingCubit cubit = context.read<OnboardingCubit>();
    _currentIndex = _stepToIndex(cubit.currentStep);

    _pageController = PageController(initialPage: _currentIndex);

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: (_currentIndex + 1) / _totalPages,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  int _stepToIndex(OnboardingStep step) => switch (step) {
        OnboardingStep.introduction => 0,
        OnboardingStep.about => 1,
        OnboardingStep.permission => 2,
        OnboardingStep.storage => 3,
        OnboardingStep.completed => 3,
      };

  OnboardingStep _indexToStep(int index) => switch (index) {
        0 => OnboardingStep.introduction,
        1 => OnboardingStep.about,
        2 => OnboardingStep.permission,
        3 => OnboardingStep.storage,
        _ => OnboardingStep.completed,
      };

  Future<void> _goToPage(int index) async {
    if (index < 0 || index >= _totalPages) {
      return;
    }
    final OnboardingCubit cubit = context.read<OnboardingCubit>();
    _contentController.reset();
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
    setState(() => _currentIndex = index);
    unawaited(
      _progressController.animateTo(
        (index + 1) / _totalPages,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    );
    unawaited(_contentController.forward());
    cubit.saveStep(_indexToStep(index));
  }

  void _onNext() {
    if (_currentIndex < _totalPages - 1) {
      unawaited(_goToPage(_currentIndex + 1));
    }
  }

  void _onBack() {
    if (_currentIndex > 0) {
      unawaited(_goToPage(_currentIndex - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (_, OnboardingState curr) => curr.maybeWhen(completed: () => true, orElse: () => false),
      listener: (_, __) => context.router.replaceAll(<PageRouteInfo<Object?>>[const SummaryRoute()]),
      child: Scaffold(
        backgroundColor: AppColors.surfaceDark,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              OnboardingTopBar(
                currentIndex: _currentIndex,
                total: _totalPages,
                stepLabels: _stepLabels,
                progressController: _progressController,
                onBack: _currentIndex > 0 ? _onBack : null,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    OnboardingIntroductionPage(
                      contentController: _contentController,
                    ),
                    OnboardingAboutPage(
                      contentController: _contentController,
                    ),
                    OnboardingUsageStatsPage(
                      contentController: _contentController,
                      onGranted: _onNext,
                    ),
                    OnboardingStoragePage(
                      contentController: _contentController,
                      onGranted: () => context.read<OnboardingCubit>().saveStep(OnboardingStep.completed),
                    ),
                  ],
                ),
              ),
              OnboardingBottomNav(
                currentIndex: _currentIndex,
                contentController: _contentController,
                onNext: _onNext,
                onBack: _currentIndex > 0 ? _onBack : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    required this.currentIndex,
    required this.total,
    required this.stepLabels,
    required this.progressController,
    required this.onBack,
    super.key,
  });

  final int currentIndex;
  final int total;
  final List<String> stepLabels;
  final AnimationController progressController;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AnimatedOpacity(
                opacity: onBack != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerDark,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.onSurfaceVariantDark,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AnimatedBuilder(
                  animation: progressController,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: progressController.value,
                      minHeight: 4.h,
                      backgroundColor: AppColors.surfaceContainerDark,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '${currentIndex + 1}/$total',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceTertiaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Align(
              key: ValueKey<int>(currentIndex),
              alignment: Alignment.centerLeft,
              child: Text(
                stepLabels[currentIndex],
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAV — hidden on permission pages (they own their own CTA)
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingBottomNav extends StatelessWidget {
  const OnboardingBottomNav({
    required this.currentIndex,
    required this.contentController,
    required this.onNext,
    required this.onBack,
    super.key,
  });

  final int currentIndex;
  final AnimationController contentController;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  bool get _isPermissionPage => currentIndex >= 2;

  @override
  Widget build(BuildContext context) {
    if (_isPermissionPage) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: contentController,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 28.h),
        child: Row(
          children: <Widget>[
            if (onBack != null) ...<Widget>[
              GestureDetector(
                onTap: onBack,
                child: Container(
                  height: 52.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerDark,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.onSurfaceVariantDark,
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Back',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.onSurfaceVariantDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Continue',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.onSurfaceDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.onSurfaceDark,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOTS INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingDotsIndicator extends StatelessWidget {
  const OnboardingDotsIndicator({
    required this.currentIndex,
    required this.total,
    super.key,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(total, (int i) {
        final bool isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 24.w : 8.w,
          height: 8.h,
          margin: EdgeInsets.only(right: 6.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceContainerDark,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED CONTENT WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingAnimatedContent extends StatelessWidget {
  const OnboardingAnimatedContent({
    required this.controller,
    required this.child,
    super.key,
  });

  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> fade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERMISSION CTA BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingCtaButton extends StatelessWidget {
  const OnboardingCtaButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isLoading,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLoading)
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onSurfaceDark,
                ),
              )
            else ...<Widget>[
              Text(
                label,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.onSurfaceDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(icon, color: AppColors.onSurfaceDark, size: 18.sp),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERMISSION GRANTED BADGE
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingGrantedBadge extends StatelessWidget {
  const OnboardingGrantedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.check_circle_rounded,
            size: 16.sp,
            color: AppColors.success,
          ),
          SizedBox(width: 8.w),
          Text(
            'Permission granted',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 0: INTRODUCTION
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingIntroductionPage extends StatelessWidget {
  const OnboardingIntroductionPage({
    required this.contentController,
    super.key,
  });

  final AnimationController contentController;

  @override
  Widget build(BuildContext context) {
    return OnboardingAnimatedContent(
      controller: contentController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40.h),
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.phone_android_rounded,
                color: AppColors.primary,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Your phone has\na graveyard.',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.onSurfaceDark,
                height: 1.15,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Every notification you dismissed, every app you opened and forgot \u2014 they all leave a trace.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.onSurfaceTertiaryDark,
                height: 1.65,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'It\u2019s time to see them.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.onSurfaceVariantDark,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(),
            const OnboardingDotsIndicator(currentIndex: 0, total: 4),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 1: ABOUT
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingAboutPage extends StatelessWidget {
  const OnboardingAboutPage({
    required this.contentController,
    super.key,
  });

  final AnimationController contentController;

  @override
  Widget build(BuildContext context) {
    return OnboardingAnimatedContent(
      controller: contentController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40.h),
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                color: AppColors.primary,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'What we track.',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.onSurfaceDark,
              ),
            ),
            SizedBox(height: 32.h),
            OnboardingAboutItem(
              icon: Icons.lock_open_rounded,
              title: 'Unlocks',
              subtitle: 'How many times you checked your phone.',
              animationInterval: const Interval(0.2, 0.7, curve: Curves.easeOut),
              controller: contentController,
            ),
            SizedBox(height: 20.h),
            OnboardingAboutItem(
              icon: Icons.apps_rounded,
              title: 'App usage',
              subtitle: 'Which apps got your attention and for how long.',
              animationInterval: const Interval(0.35, 0.85, curve: Curves.easeOut),
              controller: contentController,
            ),
            SizedBox(height: 20.h),
            OnboardingAboutItem(
              icon: Icons.notifications_off_outlined,
              title: 'Dismissed notifications',
              subtitle: 'The apps you ghosted without a second thought.',
              animationInterval: const Interval(0.5, 1.0, curve: Curves.easeOut),
              controller: contentController,
            ),
            SizedBox(height: 28.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.shield_outlined, color: AppColors.primary, size: 16.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Everything stays on your device. We never collect or share your data.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariantDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const OnboardingDotsIndicator(currentIndex: 1, total: 4),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}

class OnboardingAboutItem extends StatelessWidget {
  const OnboardingAboutItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.animationInterval,
    required this.controller,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Interval animationInterval;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final Animation<double> fade = CurvedAnimation(
      parent: controller,
      curve: animationInterval,
    );
    return FadeTransition(
      opacity: fade,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerDark,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.onSurfaceDark,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceTertiaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 2: USAGE STATS PERMISSION
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingUsageStatsPage extends StatefulWidget {
  const OnboardingUsageStatsPage({
    required this.contentController,
    required this.onGranted,
    super.key,
  });

  final AnimationController contentController;
  final VoidCallback onGranted;

  @override
  State<OnboardingUsageStatsPage> createState() => _OnboardingUsageStatsPageState();
}

class _OnboardingUsageStatsPageState extends State<OnboardingUsageStatsPage> with WidgetsBindingObserver {
  bool _isGranted = false;
  bool _isChecking = true;
  bool _wasOpenedSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _wasOpenedSettings) {
      _wasOpenedSettings = false;
      _check();
    }
  }

  Future<void> _check() async {
    setState(() => _isChecking = true);
    final bool granted = await getIt<PermissionService>().isUsageStatsGranted().then(
          (PermissionStatus status) => status == PermissionStatus.granted,
        );
    if (mounted) {
      setState(() {
        _isGranted = granted;
        _isChecking = false;
      });
    }
  }

  Future<void> _grant() async {
    _wasOpenedSettings = true;
    await getIt<PermissionService>().openUsageStatsSettings();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingAnimatedContent(
      controller: widget.contentController,
      child: OnboardingPermissionLayout(
        icon: Icons.query_stats_rounded,
        pageIndex: 2,
        title: 'Track Your\nScreen Time',
        description: 'Screen Graveyard needs Usage Stats access to monitor app usage '
            'and screen time. This allows the app to analyze your device usage '
            'patterns and provide accurate insights.',
        hint: "You'll be taken to system settings \u2014 find Screen Graveyard and toggle it on, then return.",
        isGranted: _isGranted,
        isChecking: _isChecking,
        isSystemSettings: true,
        onGrant: _grant,
        onContinue: widget.onGranted,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 3: STORAGE PERMISSION
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingStoragePage extends StatefulWidget {
  const OnboardingStoragePage({
    required this.contentController,
    required this.onGranted,
    super.key,
  });

  final AnimationController contentController;
  final VoidCallback onGranted;

  @override
  State<OnboardingStoragePage> createState() => _OnboardingStoragePageState();
}

class _OnboardingStoragePageState extends State<OnboardingStoragePage> {
  bool _isGranted = false;
  bool _isChecking = true;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _isChecking = true);
    final bool granted = await getIt<PermissionService>().isStorageGranted().then(
          (PermissionStatus status) => status == PermissionStatus.granted,
        );
    if (mounted) {
      setState(() {
        _isGranted = granted;
        _isChecking = false;
      });
    }
  }

  Future<void> _grant() async {
    setState(() => _isRequesting = true);
    final PermissionStatus result = await getIt<PermissionService>().requestStorage();
    final bool granted = result == PermissionStatus.granted;
    if (mounted) {
      setState(() {
        _isGranted = granted;
        _isRequesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingAnimatedContent(
      controller: widget.contentController,
      child: OnboardingPermissionLayout(
        icon: Icons.folder_outlined,
        pageIndex: 3,
        title: 'Access\nYour Files',
        description: 'Storage access is required to export and manage screenshots or '
            'generated reports. Your files remain on your device and are only '
            'accessed when needed.',
        hint: null,
        isGranted: _isGranted,
        isChecking: _isChecking || _isRequesting,
        isSystemSettings: false,
        onGrant: _grant,
        onContinue: widget.onGranted,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED PERMISSION LAYOUT
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingPermissionLayout extends StatelessWidget {
  const OnboardingPermissionLayout({
    required this.icon,
    required this.pageIndex,
    required this.title,
    required this.description,
    required this.hint,
    required this.isGranted,
    required this.isChecking,
    required this.isSystemSettings,
    required this.onGrant,
    required this.onContinue,
    super.key,
  });

  final IconData icon;
  final int pageIndex;
  final String title;
  final String description;
  final String? hint;
  final bool isGranted;
  final bool isChecking;
  final bool isSystemSettings;
  final VoidCallback onGrant;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 40.h),

          // Icon — animates between permission icon and check
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: isGranted ? AppColors.success.withValues(alpha: 0.12) : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isGranted ? AppColors.success.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: isChecking
                ? Padding(
                    padding: EdgeInsets.all(20.w),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    isGranted ? Icons.check_circle_outline_rounded : icon,
                    color: isGranted ? AppColors.success : AppColors.primary,
                    size: 36.sp,
                  ),
          ),

          SizedBox(height: 32.h),

          Text(
            title,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.onSurfaceDark,
              height: 1.15,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceTertiaryDark,
              height: 1.65,
            ),
          ),

          // System settings hint
          if (hint != null && !isGranted) ...<Widget>[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerDark,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16.sp,
                    color: AppColors.onSurfaceVariantDark,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      hint!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariantDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Granted badge
          if (isGranted) ...<Widget>[
            SizedBox(height: 20.h),
            const OnboardingGrantedBadge(),
          ],

          const Spacer(),

          OnboardingDotsIndicator(currentIndex: pageIndex, total: 4),

          SizedBox(height: 20.h),

          // CTA — switches between Grant and Continue
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isGranted
                ? OnboardingCtaButton(
                    key: const ValueKey<String>('continue'),
                    label: 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onTap: onContinue,
                    isLoading: false,
                  )
                : OnboardingCtaButton(
                    key: const ValueKey<String>('grant'),
                    label: isSystemSettings ? 'Open Settings' : 'Grant Access',
                    icon: isSystemSettings ? Icons.settings_outlined : Icons.security_rounded,
                    onTap: isChecking ? () {} : onGrant,
                    isLoading: isChecking,
                  ),
          ),

          SizedBox(height: 28.h),
        ],
      ),
    );
  }
}
