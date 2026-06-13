import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/di/injection.dart';
import 'package:screen_graveyard/core/error/app_exception.dart';
import 'package:screen_graveyard/core/router/app_router.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/features/summary/domain/entities/daily_snapshot.dart';
import 'package:screen_graveyard/features/summary/presentation/blocs/summary/summary_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FILTER ENUM
// ─────────────────────────────────────────────────────────────────────────────

enum SummaryFilter { all, unlocks, screenTime, notifications, apps }

extension SummaryFilterX on SummaryFilter {
  String get label => switch (this) {
        SummaryFilter.all => 'All',
        SummaryFilter.unlocks => 'Unlocks',
        SummaryFilter.screenTime => 'Screen',
        SummaryFilter.notifications => 'Notifs',
        SummaryFilter.apps => 'Apps',
      };

  IconData get icon => switch (this) {
        SummaryFilter.all => Icons.dashboard_rounded,
        SummaryFilter.unlocks => Icons.lock_open_rounded,
        SummaryFilter.screenTime => Icons.phone_android_rounded,
        SummaryFilter.notifications => Icons.notifications_off_outlined,
        SummaryFilter.apps => Icons.apps_rounded,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────

@RoutePage()
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  SummaryFilter _activeFilter = SummaryFilter.all;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SummaryCubit>(
      create: (_) => getIt<SummaryCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.surfaceDark,
        body: BlocBuilder<SummaryCubit, SummaryState>(
          builder: (BuildContext context, SummaryState state) {
            return state.when(
              initial: () => const SummaryLoadingView(),
              loading: () => const SummaryLoadingView(),
              empty: () => const SummaryEmptyView(),
              error: (AppException error) => SummaryErrorView(message: error.readableMessage),
              loaded: (DailySnapshot snapshot) => SummaryLoadedView(
                snapshot: snapshot,
                activeFilter: _activeFilter,
                entryController: _entryController,
                onFilterChanged: (SummaryFilter f) => setState(() => _activeFilter = f),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING
// ─────────────────────────────────────────────────────────────────────────────

class SummaryLoadingView extends StatelessWidget {
  const SummaryLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            'Reading your graveyard...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceTertiaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY
// ─────────────────────────────────────────────────────────────────────────────

class SummaryEmptyView extends StatelessWidget {
  const SummaryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerDark,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 36.sp,
                color: AppColors.onSurfaceTertiaryDark,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Nothing yet.',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onSurfaceDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your graveyard fills up as you use your phone. Check back later today.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceTertiaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR
// ─────────────────────────────────────────────────────────────────────────────

class SummaryErrorView extends StatelessWidget {
  const SummaryErrorView({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceTertiaryDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            OutlinedButton(
              onPressed: () => context.read<SummaryCubit>().refresh(),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADED
// ─────────────────────────────────────────────────────────────────────────────

class SummaryLoadedView extends StatelessWidget {
  const SummaryLoadedView({
    required this.snapshot,
    required this.activeFilter,
    required this.entryController,
    required this.onFilterChanged,
    super.key,
  });

  final DailySnapshot snapshot;
  final SummaryFilter activeFilter;
  final AnimationController entryController;
  final ValueChanged<SummaryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerDark,
      onRefresh: () => context.read<SummaryCubit>().refresh(),
      child: CustomScrollView(
        slivers: <Widget>[
          // ── Header ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SummaryHeader(
              snapshot: snapshot,
              entryController: entryController,
            ),
          ),

          // ── Witty headline ────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
            sliver: SliverToBoxAdapter(
              child: SummaryWittyCard(
                snapshot: snapshot,
                controller: entryController,
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            sliver: SliverToBoxAdapter(
              child: SummaryFilterBar(
                active: activeFilter,
                onChanged: onFilterChanged,
              ),
            ),
          ),

          // ── Content based on filter ───────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            sliver: SliverToBoxAdapter(
              child: SummaryFilteredContent(
                snapshot: snapshot,
                filter: activeFilter,
                controller: entryController,
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class SummaryHeader extends StatelessWidget {
  const SummaryHeader({
    required this.snapshot,
    required this.entryController,
    super.key,
  });

  final DailySnapshot snapshot;
  final AnimationController entryController;

  String _formatDate(DateTime d) {
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
    const List<String> days = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.surfaceDark,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Today's Graveyard",
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.onSurfaceDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(snapshot.date),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceTertiaryDark,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SummaryIconButton(
                      icon: Icons.settings_outlined,
                      onTap: () => context.pushRoute(const SettingsRoute()),
                    ),
                    SizedBox(width: 8.w),
                    SummaryIconButton(
                      icon: Icons.bar_chart_rounded,
                      onTap: () => context.pushRoute(const HistoryRoute()),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryIconButton extends StatelessWidget {
  const SummaryIconButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerDark,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isPrimary ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderDark,
          ),
        ),
        child: Icon(
          icon,
          color: isPrimary ? AppColors.primary : AppColors.onSurfaceVariantDark,
          size: 18.sp,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WITTY HEADLINE CARD
// ─────────────────────────────────────────────────────────────────────────────

class SummaryWittyCard extends StatelessWidget {
  const SummaryWittyCard({
    required this.snapshot,
    required this.controller,
    super.key,
  });

  final DailySnapshot snapshot;
  final AnimationController controller;

  String _headline(DailySnapshot s) {
    if (s.unlockCount >= 80) {
      return 'You checked your phone ${s.unlockCount}\u00d7.\nThe phone is starting to worry.';
    }
    if (s.unlockCount >= 50) {
      return '${s.unlockCount} unlocks.\nThat\'s commitment to distraction.';
    }
    if (s.notificationDismissals >= 60) {
      return 'You ghosted ${s.notificationDismissals} notifications.\nThey\'re in a better place now.';
    }
    if (s.notificationDismissals >= 30) {
      return '${s.notificationDismissals} apps tried to reach you.\nYou had other plans.';
    }
    if (s.screenOnTime.inMinutes >= 300) {
      return '${s.screenOnTime.inHours}h of screen time.\nThe graveyard is full.';
    }
    if (s.unlockCount <= 10) {
      return 'A quiet day.\nThe apps barely noticed you.';
    }
    return '${s.unlockCount} unlocks, ${s.notificationDismissals} dismissed.\nAnother day in the graveyard.';
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: controller,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 13.sp),
                  SizedBox(width: 6.w),
                  Text(
                    "TODAY'S OBITUARY",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                _headline(snapshot),
                style: AppTextStyles.wittyHeadline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER BAR
// ─────────────────────────────────────────────────────────────────────────────

class SummaryFilterBar extends StatelessWidget {
  const SummaryFilterBar({
    required this.active,
    required this.onChanged,
    super.key,
  });

  final SummaryFilter active;
  final ValueChanged<SummaryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SummaryFilter.values.map((SummaryFilter f) {
          final bool isActive = f == active;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: SummaryFilterChip(
              filter: f,
              isActive: isActive,
              onTap: () => onChanged(f),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SummaryFilterChip extends StatelessWidget {
  const SummaryFilterChip({
    required this.filter,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  final SummaryFilter filter;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceContainerDark,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.borderDark,
          ),
          boxShadow: isActive
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              filter.icon,
              size: 14.sp,
              color: isActive ? AppColors.onSurfaceDark : AppColors.onSurfaceTertiaryDark,
            ),
            SizedBox(width: 6.w),
            Text(
              filter.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.onSurfaceDark : AppColors.onSurfaceTertiaryDark,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTERED CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class SummaryFilteredContent extends StatelessWidget {
  const SummaryFilteredContent({
    required this.snapshot,
    required this.filter,
    required this.controller,
    super.key,
  });

  final DailySnapshot snapshot;
  final SummaryFilter filter;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey<SummaryFilter>(filter),
        child: switch (filter) {
          SummaryFilter.all => _AllContent(
              snapshot: snapshot,
              controller: controller,
            ),
          SummaryFilter.unlocks => _UnlocksContent(snapshot: snapshot),
          SummaryFilter.screenTime => _ScreenTimeContent(snapshot: snapshot),
          SummaryFilter.notifications => _NotificationsContent(snapshot: snapshot),
          SummaryFilter.apps => _AppsContent(snapshot: snapshot),
        },
      ),
    );
  }
}

// ── All content ───────────────────────────────────────────────────────────────

class _AllContent extends StatelessWidget {
  const _AllContent({required this.snapshot, required this.controller});

  final DailySnapshot snapshot;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SummaryStatGrid(snapshot: snapshot, controller: controller),
        SizedBox(height: 24.h),
        SummaryAppUsageSection(snapshot: snapshot),
      ],
    );
  }
}

// ── Unlocks content ───────────────────────────────────────────────────────────

class _UnlocksContent extends StatelessWidget {
  const _UnlocksContent({required this.snapshot});

  final DailySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SummaryStatDetail(
      icon: Icons.lock_open_rounded,
      label: 'Unlocks today',
      value: snapshot.unlockCount.toString(),
      subtitle: _unlockVerdict(snapshot.unlockCount),
      color: AppColors.primary,
    );
  }

  String _unlockVerdict(int count) {
    if (count >= 80) {
      return 'Dangerously high. Your phone is tired.';
    }
    if (count >= 50) {
      return 'Above average. Consider a detox.';
    }
    if (count >= 20) {
      return 'Moderate. You\'re doing okay.';
    }
    return 'Very low. Impressive restraint.';
  }
}

// ── Screen time content ───────────────────────────────────────────────────────

class _ScreenTimeContent extends StatelessWidget {
  const _ScreenTimeContent({required this.snapshot});

  final DailySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final Duration t = snapshot.screenOnTime;
    final String formatted = t.inHours > 0 ? '${t.inHours}h ${t.inMinutes.remainder(60)}m' : '${t.inMinutes}m';

    return SummaryStatDetail(
      icon: Icons.phone_android_rounded,
      label: 'Screen on time',
      value: formatted,
      subtitle: _screenTimeVerdict(t.inMinutes),
      color: AppColors.primaryLight,
    );
  }

  String _screenTimeVerdict(int minutes) {
    if (minutes >= 360) {
      return 'Over 6 hours. The screen won today.';
    }
    if (minutes >= 180) {
      return 'Heavy usage. You were busy.';
    }
    if (minutes >= 60) {
      return 'Moderate. Not bad.';
    }
    return 'Light usage. Healthy balance.';
  }
}

// ── Notifications content ─────────────────────────────────────────────────────

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent({required this.snapshot});

  final DailySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SummaryStatDetail(
      icon: Icons.notifications_off_outlined,
      label: 'Dismissed notifications',
      value: snapshot.notificationDismissals.toString(),
      subtitle: _notifVerdict(snapshot.notificationDismissals),
      color: AppColors.warning,
    );
  }

  String _notifVerdict(int count) {
    if (count >= 60) {
      return 'Mass ghosting. They never had a chance.';
    }
    if (count >= 30) {
      return 'A lot of dismissals. Popular, are we?';
    }
    if (count >= 10) {
      return 'Average day of ignoring things.';
    }
    return 'Quiet day. The apps respected your time.';
  }
}

// ── Apps content ──────────────────────────────────────────────────────────────

class _AppsContent extends StatelessWidget {
  const _AppsContent({required this.snapshot});

  final DailySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SummaryAppUsageSection(snapshot: snapshot, showAll: true);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT GRID (2x2)
// ─────────────────────────────────────────────────────────────────────────────

class SummaryStatGrid extends StatelessWidget {
  const SummaryStatGrid({
    required this.snapshot,
    required this.controller,
    super.key,
  });

  final DailySnapshot snapshot;
  final AnimationController controller;

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final List<StatData> stats = <StatData>[
      StatData(
        icon: Icons.lock_open_rounded,
        label: 'Unlocks',
        value: snapshot.unlockCount.toString(),
        color: AppColors.primary,
        delay: 0.3,
      ),
      StatData(
        icon: Icons.phone_android_rounded,
        label: 'Screen time',
        value: _formatDuration(snapshot.screenOnTime),
        color: AppColors.primaryLight,
        delay: 0.4,
      ),
      StatData(
        icon: Icons.notifications_off_outlined,
        label: 'Dismissed',
        value: snapshot.notificationDismissals.toString(),
        color: AppColors.warning,
        delay: 0.5,
      ),
      StatData(
        icon: Icons.apps_rounded,
        label: 'Apps used',
        value: snapshot.appUsage.length.toString(),
        color: AppColors.info,
        delay: 0.6,
      ),
    ];

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _AnimatedStatCard(
                data: stats[0],
                controller: controller,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _AnimatedStatCard(
                data: stats[1],
                controller: controller,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: <Widget>[
            Expanded(
              child: _AnimatedStatCard(
                data: stats[2],
                controller: controller,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _AnimatedStatCard(
                data: stats[3],
                controller: controller,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatData {
  const StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double delay;
}

class _AnimatedStatCard extends StatelessWidget {
  const _AnimatedStatCard({
    required this.data,
    required this.controller,
  });

  final StatData data;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final Animation<double> fade = CurvedAnimation(
      parent: controller,
      curve: Interval(data.delay, data.delay + 0.4, curve: Curves.easeOut),
    );
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(data.delay, data.delay + 0.4, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: SummaryStatCard(data: data),
      ),
    );
  }
}

class SummaryStatCard extends StatelessWidget {
  const SummaryStatCard({required this.data, super.key});

  final StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerDark,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(data.icon, color: data.color, size: 18.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            data.value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.onSurfaceDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            data.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceTertiaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT DETAIL (single filter view)
// ─────────────────────────────────────────────────────────────────────────────

class SummaryStatDetail extends StatelessWidget {
  const SummaryStatDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerDark,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 20.h),
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.onSurfaceDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceTertiaryDark,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 16.h),
          const Divider(color: AppColors.borderDark, thickness: 0.8),
          SizedBox(height: 16.h),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariantDark,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP USAGE SECTION
// ─────────────────────────────────────────────────────────────────────────────

class SummaryAppUsageSection extends StatelessWidget {
  const SummaryAppUsageSection({
    required this.snapshot,
    this.showAll = false,
    super.key,
  });

  final DailySnapshot snapshot;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    if (snapshot.appUsage.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<AppStat> apps = showAll ? snapshot.appUsage : snapshot.appUsage.take(5).toList();
    final int maxMillis = snapshot.appUsage.first.totalTimeMillis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              showAll ? 'All apps' : 'Top apps',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurfaceDark,
              ),
            ),
            Text(
              '${snapshot.appUsage.length} total',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceTertiaryDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerDark,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: List<Widget>.generate(apps.length, (int i) {
              return Column(
                children: <Widget>[
                  SummaryAppRow(
                    app: apps[i],
                    maxMillis: maxMillis,
                    rank: i + 1,
                  ),
                  if (i < apps.length - 1)
                    Divider(
                      color: AppColors.dividerDark,
                      height: 1,
                      thickness: 0.8,
                      indent: 16.w,
                      endIndent: 16.w,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class SummaryAppRow extends StatelessWidget {
  const SummaryAppRow({
    required this.app,
    required this.maxMillis,
    required this.rank,
    super.key,
  });

  final AppStat app;
  final int maxMillis;
  final int rank;

  String get _appName {
    final List<String> parts = app.packageName.split('.');
    if (parts.length >= 2) {
      final String name = parts.last == 'android' ? parts[parts.length - 2] : parts.last;
      return name[0].toUpperCase() + name.substring(1);
    }
    return app.packageName;
  }

  String get _time {
    final Duration d = app.totalTime;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m';
    }
    return '${d.inSeconds}s';
  }

  double get _ratio => maxMillis > 0 ? app.totalTimeMillis / maxMillis : 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              // Rank
              SizedBox(
                width: 22.w,
                child: Text(
                  '$rank',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: rank == 1 ? AppColors.primary : AppColors.onSurfaceTertiaryDark,
                    fontWeight: rank == 1 ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _appName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _time,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariantDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: _ratio,
              minHeight: 3.h,
              backgroundColor: AppColors.surfaceContainerHighDark,
              valueColor: AlwaysStoppedAnimation<Color>(
                rank == 1 ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
