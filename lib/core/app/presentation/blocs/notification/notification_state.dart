part of 'notification_cubit.dart';

enum NotificationStatus { initial, enabled, disabled }

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default(NotificationStatus.initial) NotificationStatus status,
    @Default(<PendingNotificationRequest>[]) List<PendingNotificationRequest> pending,
    @Default(false) bool isLoading,
    @Default(false) bool isDailyReminderEnabled,
    @Default(20) int dailyReminderHour,
    @Default(0) int dailyReminderMinute,
    String? error,
  }) = _NotificationState;

  const NotificationState._();

  bool get isEnabled => status == NotificationStatus.enabled;
  bool get isDisabled => status == NotificationStatus.disabled;
  bool get isInitial => status == NotificationStatus.initial;

  TimeOfDayValue get dailyReminderTime => TimeOfDayValue(hour: dailyReminderHour, minute: dailyReminderMinute);
}
