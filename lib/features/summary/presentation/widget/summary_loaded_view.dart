import 'package:flutter/material.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/helpers/helpers.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';
import 'package:screen_graveyard/localization/localization.dart';

class SummaryLoadedView extends StatelessWidget {
  const SummaryLoadedView({required this.snapshot, super.key});

  final DailySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final int maxTime = snapshot.appUsage.fold<int>(
      0,
      (int max, AppStat app) => app.totalTimeMillis > max ? app.totalTimeMillis : max,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: AppSizes.sm),
          // Witty headline
          Text(
            _wittyHeadline(),
            style: AppTextStyles.wittyHeadline,
          ),
          SizedBox(height: AppSizes.sectionSpacing),
          // Stat cards
          StatCardsRow(snapshot: snapshot),
          // Top offenders
          if (snapshot.appUsage.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSizes.sectionSpacing),
            Text(
              localization.topOffenders,
              style: AppTextStyles.titleLarge,
            ),
            SizedBox(height: AppSizes.md),
            ...snapshot.appUsage.map(
              (AppStat app) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.md),
                child: _AppUsageBar(app: app, maxTime: maxTime),
              ),
            ),
          ],
          // Most ignored app
          if (snapshot.mostIgnoredApp != null &&
              snapshot.mostIgnoredApp != snapshot.mostUsedApp &&
              snapshot.appUsage.length > 1) ...<Widget>[
            SizedBox(height: AppSizes.sectionSpacing),
            MostIgnoredCard(app: snapshot.mostIgnoredApp!),
          ],
          // Ad banner
          SizedBox(height: AppSizes.sectionSpacing),
          const AdBannerWidget(),
          SizedBox(height: AppSizes.xxxxl),
        ],
      ),
    );
  }

  String _wittyHeadline() {
    const List<String> headlines = <String>[
      'Your phone\'s daily obituary',
      'Another day, another screen',
      'The graveyard never sleeps',
      'Today\'s digital autopsy',
      'Your screen time sentenced',
      'The verdict is in',
      'A day in the life of your thumb',
    ];
    return headlines[snapshot.unlockCount % headlines.length];
  }
}

// ── Stat Cards Row ─────────────────────────────────────────────────────

class StatCardsRow extends StatelessWidget {
  const StatCardsRow({required this.snapshot, super.key});

  final DailySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _StatCard(
          icon: Icons.lock_open_rounded,
          value: '${snapshot.unlockCount}',
          label: localization.unlocks,
        ),
        SizedBox(width: AppSizes.sm),
        _StatCard(
          icon: Icons.smartphone_rounded,
          value: DurationFormatter.format(snapshot.screenOnTime),
          label: localization.screenTime,
        ),
        SizedBox(width: AppSizes.sm),
        _StatCard(
          icon: Icons.notifications_off_rounded,
          value: '${snapshot.notificationDismissals}',
          label: localization.dismissed,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.md,
          horizontal: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: context.appColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: context.appColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: context.colors.onSurfaceVariant,
              size: AppSizes.iconMd,
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              value,
              style: AppTextStyles.titleLarge,
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: AppTextStyles.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ── App Usage Bar ──────────────────────────────────────────────────────

class _AppUsageBar extends StatelessWidget {
  const _AppUsageBar({required this.app, required this.maxTime});

  final AppStat app;
  final int maxTime;

  @override
  Widget build(BuildContext context) {
    final double ratio = maxTime > 0 ? app.totalTimeMillis / maxTime : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              AppLabelFormatter.fromPackageName(app.packageName),
              style: AppTextStyles.titleSmall,
            ),
            Text(
              DurationFormatter.format(app.totalTime),
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        SizedBox(height: AppSizes.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: context.appColors.skeleton,
            valueColor: AlwaysStoppedAnimation<Color>(
              ratio > 0.7 ? context.colors.primary : context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Most Ignored Card ──────────────────────────────────────────────────

class MostIgnoredCard extends StatelessWidget {
  const MostIgnoredCard({required this.app, super.key});

  final AppStat app;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.bedtime_rounded,
            color: context.colors.onSurfaceVariant,
            size: AppSizes.iconLg,
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  localization.mostIgnored,
                  style: AppTextStyles.labelMedium,
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  AppLabelFormatter.fromPackageName(app.packageName),
                  style: AppTextStyles.titleMedium,
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  localization.onlyToday(DurationFormatter.format(app.totalTime)),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
