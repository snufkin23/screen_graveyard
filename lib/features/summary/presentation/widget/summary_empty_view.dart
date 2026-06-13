import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/summary/presentation/blocs/summary/summary_cubit.dart';
import 'package:screen_graveyard/localization/localization.dart';

class SummaryEmptyView extends StatelessWidget {
  const SummaryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.nightlight_round,
              size: AppSizes.iconXxl,
              color: context.appColors.onSurfaceTertiary,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              localization.noDataYet,
              style: AppTextStyles.titleLarge,
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              localization.emptySubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: AppSizes.xxl),
            CustomButton.iconText(
              onPressed: () => context.read<SummaryCubit>().load(),
              icon: const Icon(Icons.refresh),
              label: localization.retry,
            ),
          ],
        ),
      ),
    );
  }
}
