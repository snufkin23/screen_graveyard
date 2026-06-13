import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    required this.currentIndex,
    required this.total,
    super.key,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(total, (int index) {
        final bool isActive = index <= currentIndex;
        final bool isCurrent = index == currentIndex;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 3.h,
            margin: EdgeInsets.only(right: index < total - 1 ? 6.w : 0),
            decoration: BoxDecoration(
              color: isActive ? context.colors.primary : context.appColors.surfaceContainer,
              borderRadius: BorderRadius.circular(2.r),
              boxShadow: isCurrent
                  ? <BoxShadow>[
                      BoxShadow(
                        color: context.colors.primary.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
