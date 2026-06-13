import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/extensions/theme_context.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/features/history/domain/entities/weekly_stats.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';

class HistoryLoadedView extends StatelessWidget {
  const HistoryLoadedView({required this.stats, super.key});

  final WeeklyStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _WeeklySummaryRow(stats: stats),
          SizedBox(height: AppSizes.sectionSpacing),
          Text(
            'Unlocks',
            style: AppTextStyles.titleMedium.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: AppSizes.md),
          _UnlocksBarChart(days: stats.days),
          SizedBox(height: AppSizes.sectionSpacing),
          Text(
            'Screen time',
            style: AppTextStyles.titleMedium.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: AppSizes.md),
          _ScreenTimeBarChart(days: stats.days),
          SizedBox(height: AppSizes.sectionSpacing),
          Text(
            'Daily breakdown',
            style: AppTextStyles.titleMedium.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: AppSizes.md),
          ...stats.days.map(
            (DailySnapshot day) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.md),
              child: _DailyRow(snapshot: day),
            ),
          ),
          SizedBox(height: AppSizes.xxxxl),
        ],
      ),
    );
  }
}

class _WeeklySummaryRow extends StatelessWidget {
  const _WeeklySummaryRow({required this.stats});
  final WeeklyStats stats;

  @override
  Widget build(BuildContext context) {
    final int totalHours = stats.totalScreenTime.inHours;
    final int totalMinutes = stats.totalScreenTime.inMinutes.remainder(60);

    return Row(
      children: <Widget>[
        Expanded(
          child: _SummaryChip(
            label: 'Peak unlocks',
            value: stats.peakUnlocks.toString(),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: _SummaryChip(
            label: 'Avg unlocks/day',
            value: stats.avgUnlocks.toStringAsFixed(0),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: _SummaryChip(
            label: 'Total screen time',
            value: '${totalHours}h ${totalMinutes}m',
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: context.appColors.onSurfaceTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlocksBarChart extends StatelessWidget {
  const _UnlocksBarChart({required this.days});
  final List<DailySnapshot> days;

  @override
  Widget build(BuildContext context) {
    final int maxVal =
        days.isEmpty ? 1 : days.map((DailySnapshot d) => d.unlockCount).reduce((int a, int b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: (maxVal * 1.2).ceilToDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) =>
                  BarTooltipItem(
                rod.toY.toInt().toString(),
                AppTextStyles.labelSmall.copyWith(color: context.colors.onSurface),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index >= days.length) {
                    return const SizedBox.shrink();
                  }
                  final DateTime date = days[index].date;
                  const List<String> weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      weekdays[date.weekday - 1],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: context.appColors.onSurfaceTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.appColors.border,
              strokeWidth: 0.8,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List<BarChartGroupData>.generate(
            days.length,
            (int i) => BarChartGroupData(
              x: i,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: days[i].unlockCount.toDouble(),
                  color: context.colors.primary,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenTimeBarChart extends StatelessWidget {
  const _ScreenTimeBarChart({required this.days});
  final List<DailySnapshot> days;

  @override
  Widget build(BuildContext context) {
    final int maxMinutes = days.isEmpty
        ? 1
        : days.map((DailySnapshot d) => d.screenOnTime.inMinutes).reduce((int a, int b) => a > b ? a : b);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: (maxMinutes * 1.2).ceilToDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
                final int minutes = rod.toY.toInt();
                final String label = minutes >= 60 ? '${minutes ~/ 60}h ${minutes % 60}m' : '${minutes}m';
                return BarTooltipItem(
                  label,
                  AppTextStyles.labelSmall.copyWith(
                    color: context.colors.onSurface,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index >= days.length) {
                    return const SizedBox.shrink();
                  }
                  final DateTime date = days[index].date;
                  const List<String> weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      weekdays[date.weekday - 1],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: context.appColors.onSurfaceTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.appColors.border,
              strokeWidth: 0.8,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List<BarChartGroupData>.generate(
            days.length,
            (int i) => BarChartGroupData(
              x: i,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: days[i].screenOnTime.inMinutes.toDouble(),
                  color: AppColors.primaryLight,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({required this.snapshot});
  final DailySnapshot snapshot;

  String _formatDate(DateTime d) {
    const List<String> days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String _formatDuration(Duration d) {
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            _formatDate(snapshot.date),
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.colors.onSurface,
            ),
          ),
          Row(
            children: <Widget>[
              _MiniStat(
                icon: Icons.lock_open_rounded,
                value: snapshot.unlockCount.toString(),
              ),
              SizedBox(width: AppSizes.md),
              _MiniStat(
                icon: Icons.phone_android_rounded,
                value: _formatDuration(snapshot.screenOnTime),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: context.appColors.onSurfaceTertiary),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.labelSmall.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
