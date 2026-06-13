import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:screen_graveyard/core/app/presentation/blocs/notification/notification_cubit.dart';
import 'package:screen_graveyard/core/constants/sizes.dart';
import 'package:screen_graveyard/core/helpers/language_selector.dart';
import 'package:screen_graveyard/core/helpers/theme_selector.dart';
import 'package:screen_graveyard/core/theme/app_colors.dart';
import 'package:screen_graveyard/core/theme/app_text_styles.dart';
import 'package:screen_graveyard/core/widgets/widgets.dart';
import 'package:screen_graveyard/features/settings/presentation/widget/settings_section_header.dart';
import 'package:screen_graveyard/features/settings/presentation/widget/settings_tile.dart';
import 'package:screen_graveyard/localization/localization.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const SettingView();
}

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingView> {
  @override
  void initState() {
    super.initState();
    // Cubits are already provided by GlobalAppProvider at app root,
    // so we can reach them via context.read
    context.read<NotificationCubit>()
      ..loadDailyReminderPreference()
      ..checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      usePadding: false,
      showAppBar: true,
      title: localization.settings,
      body: ListView(
        children: <Widget>[
          SettingsSectionHeader(
            icon: Icons.palette_rounded,
            title: localization.settingsAppTheme,
          ),
          const ThemeSection(),
          SettingsSectionHeader(
            icon: Icons.language_rounded,
            title: localization.settingsLanguage,
          ),
          const LanguageSection(),
          SettingsSectionHeader(
            icon: Icons.notifications_rounded,
            title: localization.settingsNotifications,
          ),
          const NotificationSection(),
          SizedBox(height: AppSizes.xxxxl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME SECTION
// ─────────────────────────────────────────────────────────────────────────────

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            localization.settingsThemeSubtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceTertiaryDark,
            ),
          ),
          SizedBox(height: AppSizes.md),
          const Center(child: ThemeSelector()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LANGUAGE SECTION
// ─────────────────────────────────────────────────────────────────────────────

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerDark,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            localization.settingsLanguageSubtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceTertiaryDark,
            ),
          ),
          SizedBox(height: AppSizes.md),
          const Center(child: LanguageSelector()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION SECTION
// ─────────────────────────────────────────────────────────────────────────────

class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (BuildContext context, NotificationState state) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerDark,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: <Widget>[
              // ── Status tile ──────────────────────────────────
              SettingsTile(
                icon: state.isEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                label: localization.settingsNotificationStatus,
                subtitle: state.isLoading
                    ? 'Checking...'
                    : state.isEnabled
                        ? 'Enabled'
                        : state.isDisabled
                            ? 'Disabled'
                            : 'Unknown',
                trailing: state.isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        state.isEnabled ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                        size: AppSizes.iconMd,
                        color: state.isEnabled ? AppColors.success : AppColors.error,
                      ),
              ),

              _divider(),

              // ── Daily reminder toggle ───────────────────────
              SettingsTile(
                icon: Icons.alarm_rounded,
                label: localization.settingsDailyReminder,
                subtitle: localization.settingsDailyReminderSubtitle,
                trailing: Switch(
                  value: state.isDailyReminderEnabled,
                  onChanged: (_) => context.read<NotificationCubit>().toggleDailyReminder(),
                  activeThumbColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surfaceContainerHighDark,
                ),
              ),

              // ── Time picker row (visible when enabled) ──────
              if (state.isDailyReminderEnabled) ...<Widget>[
                _divider(),
                _TimeTile(
                  hour: state.dailyReminderHour,
                  minute: state.dailyReminderMinute,
                ),
              ],

              _divider(),

              // ── Test notification ───────────────────────────
              SettingsTile(
                icon: Icons.send_rounded,
                label: localization.settingsTestNotification,
                subtitle: localization.settingsTestNotificationSubtitle,
                onTap: () => _sendTestNotification(context),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  size: AppSizes.iconMd,
                  color: AppColors.onSurfaceTertiaryDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider() => Padding(
        padding: EdgeInsets.only(left: AppSizes.pagePadding),
        child: const Divider(
          color: AppColors.dividerDark,
          height: 1,
          thickness: 0.8,
        ),
      );

  Future<void> _sendTestNotification(BuildContext context) async {
    await context.read<NotificationCubit>().showNow(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Screen Graveyard',
          body: 'Notifications are working!',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceContainerHighDark,
          content: Text(
            localization.settingsNotificationSent,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceDark,
            ),
          ),
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIME PICKER TILE
// ─────────────────────────────────────────────────────────────────────────────

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.hour, required this.minute});

  final int hour;
  final int minute;

  String get _formattedTime {
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String paddedMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$paddedMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: Icons.access_time_rounded,
      label: localization.settingsReminderTime,
      subtitle: _formattedTime,
      onTap: () => _pickTime(context),
      trailing: Icon(
        Icons.edit_rounded,
        size: AppSizes.iconSm,
        color: AppColors.primary,
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: AppColors.onSurfaceDark,
                  surface: AppColors.surfaceContainerDark,
                  onSurface: AppColors.onSurfaceDark,
                ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surfaceContainerDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      await context.read<NotificationCubit>().setDailyReminderTime(
            hour: picked.hour,
            minute: picked.minute,
          );
    }
  }
}
