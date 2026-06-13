import 'package:flutter/material.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';

class SummaryLoadingView extends StatelessWidget {
  const SummaryLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: AppSizes.sm),
          SkeletonBlock(width: context.width * 0.6, height: 28),
          SizedBox(height: AppSizes.sectionSpacing),
          Row(
            children: <Widget>[
              for (int i = 0; i < 3; i++) ...<Widget>[
                const Expanded(child: SkeletonCard()),
                if (i < 2) SizedBox(width: AppSizes.sm),
              ],
            ],
          ),
          SizedBox(height: AppSizes.sectionSpacing),
          SkeletonBlock(width: context.width * 0.35, height: 20),
          SizedBox(height: AppSizes.lg),
          ...List<Widget>.generate(
            4,
            (int i) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.md),
              child: const SkeletonBlock(height: 48),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading block — a rectangular shimmer placeholder.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 100,
      decoration: BoxDecoration(
        color: context.appColors.skeleton,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.radiusSm),
      ),
    );
  }
}

/// Skeleton loading card — a rectangular placeholder used inside stat card rows.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.appColors.skeleton,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
  }
}
