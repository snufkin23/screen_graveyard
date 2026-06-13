// notification_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:screen_graveyard/core/notifications/notification_service.dart';
import 'package:screen_graveyard/core/storage/storage.dart';

part 'notification_cubit.freezed.dart';
part 'notification_state.dart';

@lazySingleton
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(
    this._notificationService,
    this._localStorage,
  ) : super(const NotificationState());

  final NotificationService _notificationService;
  final LocalStorage _localStorage;

  /// Notification ID used for the daily reminder schedule
  static const int _dailyReminderNotificationId = 1001;

  // ── Load persisted daily reminder preference ──────────────────
  void loadDailyReminderPreference() {
    final bool enabled = _localStorage.get<bool>(StorageKeys.dailyReminderEnabled) ?? false;
    final int hour = _localStorage.get<int>(StorageKeys.dailyReminderHour) ?? 20;
    final int minute = _localStorage.get<int>(StorageKeys.dailyReminderMinute) ?? 0;
    emit(
      state.copyWith(
        isDailyReminderEnabled: enabled,
        dailyReminderHour: hour,
        dailyReminderMinute: minute,
      ),
    );
  }

  // ── Check if enabled ──────────────────────────────────────────
  Future<void> checkStatus() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final bool? enabled = await _notificationService.areNotificationsEnabled();
      emit(
        state.copyWith(
          isLoading: false,
          status: enabled == true ? NotificationStatus.enabled : NotificationStatus.disabled,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // ── Show instantly ────────────────────────────────────────────
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await _notificationService.showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // ── Schedule at datetime ──────────────────────────────────────
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await _notificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: payload,
      );
      await refreshPending();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // ── Schedule daily ────────────────────────────────────────────
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDayValue time,
    String? payload,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await _notificationService.scheduleDailyNotification(
        id: id,
        title: title,
        body: body,
        time: time,
        payload: payload,
      );
      await refreshPending();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // ── Schedule weekly ───────────────────────────────────────────
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required TimeOfDayValue time,
    String? payload,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await _notificationService.scheduleWeeklyNotification(
        id: id,
        title: title,
        body: body,
        weekday: weekday,
        time: time,
        payload: payload,
      );
      await refreshPending();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // ── Refresh pending list ──────────────────────────────────────
  Future<void> refreshPending() async {
    final List<PendingNotificationRequest> pending = await _notificationService.getPendingNotifications();
    emit(state.copyWith(pending: pending));
  }

  // ── Cancel single ─────────────────────────────────────────────
  Future<void> cancel(int id) async {
    await _notificationService.cancelNotification(id);
    await refreshPending();
  }

  // ── Cancel all ────────────────────────────────────────────────
  Future<void> cancelAll() async {
    await _notificationService.cancelAllNotifications();
    emit(state.copyWith(pending: <PendingNotificationRequest>[]));
  }

  // ── Toggle daily reminder ─────────────────────────────────────
  Future<void> toggleDailyReminder() async {
    final bool newEnabled = !state.isDailyReminderEnabled;
    await _localStorage.put<bool>(StorageKeys.dailyReminderEnabled, newEnabled);
    emit(state.copyWith(isDailyReminderEnabled: newEnabled));

    if (newEnabled) {
      await _scheduleDailyReminder();
    } else {
      await _notificationService.cancelNotification(_dailyReminderNotificationId);
    }
    await refreshPending();
  }

  // ── Set daily reminder time ───────────────────────────────────
  Future<void> setDailyReminderTime({
    required int hour,
    required int minute,
  }) async {
    await _localStorage.put<int>(StorageKeys.dailyReminderHour, hour);
    await _localStorage.put<int>(StorageKeys.dailyReminderMinute, minute);
    emit(state.copyWith(dailyReminderHour: hour, dailyReminderMinute: minute));

    if (state.isDailyReminderEnabled) {
      await _scheduleDailyReminder();
    }
    await refreshPending();
  }

  // ── Helper: schedule or reschedule daily reminder ─────────────
  Future<void> _scheduleDailyReminder() async {
    final TimeOfDayValue time = state.dailyReminderTime;
    await _notificationService.scheduleDailyNotification(
      id: _dailyReminderNotificationId,
      title: 'Screen Graveyard',
      body: "Here's your daily screen time summary.",
      time: time,
    );
  }
}
