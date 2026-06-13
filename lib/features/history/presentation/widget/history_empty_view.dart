import 'package:flutter/material.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/localization/localization.dart';

class HistoryEmptyView extends StatelessWidget {
  const HistoryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: context.appColors.onSurfaceTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              localization.noDataYet,
              style: AppTextStyles.headlineSmall.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Come back tomorrow — your 7-day chart fills up as you use the app.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appColors.onSurfaceTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
