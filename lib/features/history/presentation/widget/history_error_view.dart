import 'package:flutter/material.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/localization/localization.dart';

class HistoryErrorView extends StatelessWidget {
  const HistoryErrorView({required this.error, super.key});

  final AppException error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              localization.oops,
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.readableMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appColors.onSurfaceTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
