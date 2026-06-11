import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/router/app_router.gr.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/onboarding/presentation/blocs/onboarding/onboarding_cubit.dart';
import 'package:screen_graveyard/features/onboarding/presentation/widgets/onboarding_progress_indicator.dart';
import 'package:screen_graveyard/features/onboarding/presentation/widgets/onboarding_step_view.dart';
import 'package:screen_graveyard/localization/localization.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  static const IconData _introIcon = Icons.auto_awesome_rounded;
  static const IconData _aboutIcon = Icons.architecture_rounded;
  static const IconData _permissionIcon = Icons.tune_rounded;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int initialIndex = context.read<OnboardingCubit>().state.when(
            introduction: () => 0,
            about: () => 1,
            permission: () => 2,
            completed: () => 2,
          );
      _pageController.jumpToPage(initialIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (BuildContext context, OnboardingState state) {
        final int index = state.when(
          introduction: () => 0,
          about: () => 1,
          permission: () => 2,
          completed: () => 2,
        );

        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        state.maybeWhen(
          completed: () => context.router.replace(const HomeRoute()),
          orElse: () {},
        );
      },
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (BuildContext context, OnboardingState state) {
          final int currentIndex = state.when(
            introduction: () => 0,
            about: () => 1,
            permission: () => 2,
            completed: () => 2,
          );

          return CustomScaffold(
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int index) {
                        if (index > currentIndex) {
                          context.read<OnboardingCubit>().next();
                        } else if (index < currentIndex) {
                          context.read<OnboardingCubit>().previous();
                        }
                      },
                      children: <Widget>[
                        OnboardingStepView(
                          icon: _introIcon,
                          title: localization.onboardingTitle1,
                          description: localization.onboardingDesc1,
                        ),
                        OnboardingStepView(
                          icon: _aboutIcon,
                          title: localization.onboardingTitle2,
                          description: localization.onboardingDesc2,
                        ),
                        OnboardingStepView(
                          icon: _permissionIcon,
                          title: localization.onboardingTitle3,
                          description: localization.onboardingDesc3,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                    child: Column(
                      children: <Widget>[
                        OnboardingProgressIndicator(
                          currentIndex: currentIndex,
                          totalSteps: 3,
                        ),
                        SizedBox(height: 32.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            if (currentIndex > 0)
                              CustomOutlinedButton(
                                label: localization.back,
                                onPressed: () =>
                                    context.read<OnboardingCubit>().previous(),
                              )
                            else
                              const SizedBox.shrink(),
                            CustomButton(
                              label: currentIndex == 2
                                  ? localization.getStarted
                                  : localization.continueButton,
                              onPressed: () =>
                                  context.read<OnboardingCubit>().next(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
