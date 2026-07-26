part of 'notification_settings_bloc.dart';

abstract class NotificationSettingsEvent {
  const NotificationSettingsEvent();
}

class LoadNotificationSettings extends NotificationSettingsEvent {
  const LoadNotificationSettings();
}

class UpdateNotificationSettings extends NotificationSettingsEvent {
  final NotificationSettingsModel settings;

  const UpdateNotificationSettings(this.settings);
}

class ToggleMorningNotification extends NotificationSettingsEvent {
  final bool enabled;

  const ToggleMorningNotification(this.enabled);
}

class ToggleEveningNotification extends NotificationSettingsEvent {
  final bool enabled;

  const ToggleEveningNotification(this.enabled);
}

class ToggleMidnightNotification extends NotificationSettingsEvent {
  final bool enabled;

  const ToggleMidnightNotification(this.enabled);
}

class UpdateMorningTime extends NotificationSettingsEvent {
  final String time;

  const UpdateMorningTime(this.time);
}

class UpdateEveningTime extends NotificationSettingsEvent {
  final String time;

  const UpdateEveningTime(this.time);
}

class UpdateMidnightTime extends NotificationSettingsEvent {
  final String time;

  const UpdateMidnightTime(this.time);
}

class ToggleSound extends NotificationSettingsEvent {
  final bool enabled;

  const ToggleSound(this.enabled);
}

class ToggleVibration extends NotificationSettingsEvent {
  final bool enabled;

  const ToggleVibration(this.enabled);
}
