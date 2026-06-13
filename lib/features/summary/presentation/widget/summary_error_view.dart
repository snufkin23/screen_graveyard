import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/summary/presentation/blocs/summary/summary_cubit.dart';
import 'package:screen_graveyard/localization/localization.dart';

class SummaryErrorView extends StatelessWidget {
  const SummaryErrorView({required this.error, super.key});

  final AppException error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: AppSizes.iconXxl,
              color: context.colors.error,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              localization.oops,
              style: AppTextStyles.titleLarge,
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              error.readableMessage,
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
