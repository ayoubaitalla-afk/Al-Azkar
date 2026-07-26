part of 'notification_settings_bloc.dart';

abstract class NotificationSettingsState {
  const NotificationSettingsState();
}

class NotificationSettingsInitial extends NotificationSettingsState {
  const NotificationSettingsInitial();
}

class NotificationSettingsLoading extends NotificationSettingsState {
  const NotificationSettingsLoading();
}

class NotificationSettingsLoaded extends NotificationSettingsState {
  final NotificationSettingsModel settings;

  const NotificationSettingsLoaded(this.settings);
}

class NotificationSettingsError extends NotificationSettingsState {
  final String message;

  const NotificationSettingsError(this.message);
}
