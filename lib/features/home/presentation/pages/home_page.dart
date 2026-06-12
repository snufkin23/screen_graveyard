import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';
import 'package:screen_graveyard/features/summary/presentation/blocs/summary/summary_cubit.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SummaryCubit>(
      create: (_) => getIt<SummaryCubit>()..load(),
      child: Builder(
        builder: (BuildContext context) {
          return CustomScaffold(
            usePadding: false,
            showAppBar: true,
            title: "Today's Report",
            body: BlocBuilder<SummaryCubit, SummaryState>(
              builder: (BuildContext context, SummaryState state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const _SummaryLoadingView(),
                  loaded: (DailySnapshot snapshot) => _SummaryLoadedView(snapshot: snapshot),
                  empty: () => const _SummaryEmptyView(),
                  error: (AppException error) => _SummaryErrorView(error: error),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────

String _formatDuration(Duration d) {
  final int h = d.inHours;
  final int m = d.inMinutes.remainder(60);
  if (h > 0) {
    return '${h}h ${m}m';
  }
  return '${m}m';
}

String _appLabel(String packageName) {
  final List<String> parts = packageName.split('.');
  if (parts.length >= 2) {
    final String last = parts.last;
    if (last.length <= 2 && parts.length >= 3) {
      return parts[parts.length - 2];
    }
    return '${last[0].toUpperCase()}${last.substring(1)}';
  }
  return packageName;
}

// ════════════════════════════════════════════════════════════════════════
// LOADING VIEW
// ════════════════════════════════════════════════════════════════════════

class _SummaryLoadingView extends StatelessWidget {
  const _SummaryLoadingView();

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.appColors;
    final double screenWidth = context.width;
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: AppSizes.sm),
          _skeleton(28, colors, screenWidth, widthFactor: 0.6),
          SizedBox(height: AppSizes.sectionSpacing),
          Row(
            children: <Widget>[
              for (int i = 0; i < 3; i++) ...<Widget>[
                Expanded(child: _skeletonCard(colors)),
                if (i < 2) SizedBox(width: AppSizes.sm),
              ],
            ],
          ),
          SizedBox(height: AppSizes.sectionSpacing),
          _skeleton(20, colors, screenWidth, widthFactor: 0.35),
          SizedBox(height: AppSizes.lg),
          ...List<Widget>.generate(
            4,
            (int i) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.md),
              child: _skeleton(48, colors, screenWidth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeleton(
    double height,
    AppColorScheme colors,
    double screenWidth, {
    double? widthFactor,
  }) {
    return Container(
      width: widthFactor != null ? screenWidth * widthFactor : double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.skeleton,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
    );
  }

  Widget _skeletonCard(AppColorScheme colors) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: colors.skeleton,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// LOADED VIEW
// ════════════════════════════════════════════════════════════════════════

class _SummaryLoadedView extends StatelessWidget {
  const _SummaryLoadedView({required this.snapshot});

  final DailySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.appColors;
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
            style: AppTextStyles.wittyHeadline.copyWith(color: colors.onSurface),
          ),
          SizedBox(height: AppSizes.sectionSpacing),
          // Stat cards
          _StatCardsRow(snapshot: snapshot),
          // Top offenders
          if (snapshot.appUsage.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSizes.sectionSpacing),
            Text(
              'Top Offenders',
              style: AppTextStyles.titleLarge.copyWith(color: colors.onSurface),
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
            _MostIgnoredCard(app: snapshot.mostIgnoredApp!),
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

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.snapshot});

  final DailySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _StatCard(
          icon: Icons.lock_open_rounded,
          value: '${snapshot.unlockCount}',
          label: 'Unlocks',
        ),
        SizedBox(width: AppSizes.sm),
        _StatCard(
          icon: Icons.smartphone_rounded,
          value: _formatDuration(snapshot.screenOnTime),
          label: 'Screen Time',
        ),
        SizedBox(width: AppSizes.sm),
        _StatCard(
          icon: Icons.notifications_off_rounded,
          value: '${snapshot.notificationDismissals}',
          label: 'Dismissed',
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
    final AppColorScheme colors = context.appColors;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.md,
          horizontal: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: colors.onSurfaceVariant, size: AppSizes.iconMd),
            SizedBox(height: AppSizes.sm),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(color: colors.onSurface),
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: colors.onSurfaceVariant),
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
    final AppColorScheme colors = context.appColors;
    final double ratio = maxTime > 0 ? app.totalTimeMillis / maxTime : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _appLabel(app.packageName),
              style: AppTextStyles.titleSmall.copyWith(color: colors.onSurface),
            ),
            Text(
              _formatDuration(app.totalTime),
              style: AppTextStyles.bodySmall.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
        SizedBox(height: AppSizes.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: colors.skeleton,
            valueColor: AlwaysStoppedAnimation<Color>(
              ratio > 0.7 ? AppColors.primary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Most Ignored Card ──────────────────────────────────────────────────

class _MostIgnoredCard extends StatelessWidget {
  const _MostIgnoredCard({required this.app});

  final AppStat app;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.bedtime_rounded,
            color: colors.onSurfaceVariant,
            size: AppSizes.iconLg,
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Most Ignored',
                  style: AppTextStyles.labelMedium.copyWith(color: colors.onSurfaceVariant),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  _appLabel(app.packageName),
                  style: AppTextStyles.titleMedium.copyWith(color: colors.onSurface),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  'Only ${_formatDuration(app.totalTime)} today',
                  style: AppTextStyles.bodySmall.copyWith(color: colors.onSurfaceTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// EMPTY VIEW
// ════════════════════════════════════════════════════════════════════════

class _SummaryEmptyView extends StatelessWidget {
  const _SummaryEmptyView();

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.appColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.nightlight_round,
              size: AppSizes.iconXxl,
              color: colors.onSurfaceTertiary,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'No data yet',
              style: AppTextStyles.titleLarge.copyWith(color: colors.onSurface),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Grant usage access and come back later\n'
              'to see your phone\'s daily report.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
            ),
            SizedBox(height: AppSizes.xxl),
            CustomButton.iconText(
              onPressed: () => context.read<SummaryCubit>().load(),
              icon: const Icon(Icons.refresh),
              label: 'Retry',
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ERROR VIEW
// ════════════════════════════════════════════════════════════════════════

class _SummaryErrorView extends StatelessWidget {
  const _SummaryErrorView({required this.error});

  final AppException error;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.appColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: AppSizes.iconXxl,
              color: AppColors.error,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              'Oops!',
              style: AppTextStyles.titleLarge.copyWith(color: colors.onSurface),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              error.readableMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
            ),
            SizedBox(height: AppSizes.xxl),
            CustomButton.iconText(
              onPressed: () => context.read<SummaryCubit>().load(),
              icon: const Icon(Icons.refresh),
              label: 'Retry',
            ),
          ],
        ),
      ),
    );
  }
}
