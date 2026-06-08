import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/helpers/language_selector.dart';
import 'package:screen_graveyard/core/router/app_router.gr.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/onboarding/presentation/blocs/onboarding_cubit.dart';
import 'package:screen_graveyard/features/onboarding/presentation/pages/views/done_view.dart';
import 'package:screen_graveyard/features/onboarding/presentation/pages/views/permission_view.dart';
import 'package:screen_graveyard/features/onboarding/presentation/pages/views/welcome_view.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncPage(int page) {
    if (_pageController.hasClients && _pageController.page?.round() != page) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (BuildContext context, OnboardingState state) {
        if (state.isCompleted) {
          context.router
              .replaceAll(<PageRouteInfo<Object?>>[const HomeRoute()]);
        } else {
          _syncPage(state.currentPage);
        }
      },
      child: CustomScaffold(
        showAppBar: true,
        actions: const <Widget>[
          LanguageSelector(),
          SizedBox(width: 16),
        ],
        body: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  WelcomeView(
                    onNext: () => context.read<OnboardingCubit>().nextPage(),
                  ),
                  PermissionView(
                    onNext: () => context.read<OnboardingCubit>().nextPage(),
                  ),
                  DoneView(
                    onFinish: () =>
                        context.read<OnboardingCubit>().completeOnboarding(),
                  ),
                ],
              ),
            ),

            // ── Page indicator ─────────────────────────────────
            BlocSelector<OnboardingCubit, OnboardingState, int>(
              selector: (OnboardingState state) => state.currentPage,
              builder: (BuildContext context, int currentPage) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.xxl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                      3,
                      (int index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: AppSizes.xs,
                        ),
                        width: currentPage == index ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
