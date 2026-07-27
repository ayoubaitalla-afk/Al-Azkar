import 'package:alazkar/src/core/manager/notification_service.dart';
import 'package:alazkar/src/core/models/notification_settings_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

part 'notification_settings_event.dart';
part 'notification_settings_state.dart';

class NotificationSettingsBloc
    extends Bloc<NotificationSettingsEvent, NotificationSettingsState> {
  final NotificationService _notificationService =
      GetIt.instance<NotificationService>();

  NotificationSettingsBloc()
      : super(const NotificationSettingsInitial()) {
    on<LoadNotificationSettings>(_onLoadSettings);
    on<UpdateNotificationSettings>(_onUpdateSettings);
    on<ToggleMorningNotification>(_onToggleMorning);
    on<ToggleEveningNotification>(_onToggleEvening);
    on<ToggleMidnightNotification>(_onToggleMidnight);
    on<UpdateMorningTime>(_onUpdateMorningTime);
    on<UpdateEveningTime>(_onUpdateEveningTime);
    on<UpdateMidnightTime>(_onUpdateMidnightTime);
    on<ToggleSound>(_onToggleSound);
    on<ToggleVibration>(_onToggleVibration);
  }

  Future<void> _onLoadSettings(
    LoadNotificationSettings event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      emit(const NotificationSettingsLoading());
      final settings = _notificationService.currentSettings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateNotificationSettings event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await _notificationService.updateSettings(event.settings);
      emit(NotificationSettingsLoaded(event.settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> _onToggleMorning(
    ToggleMorningNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await _notificationService.setMorningNotification(event.enabled);
      final settings = _notificationService.currentSettings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> _onToggleEvening(
    ToggleEveningNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await _notificationService.setEveningNotification(event.enabled);
      final settings = _notificationService.currentSettings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> _onToggleMidnight(
    ToggleMidnightNotification event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await _notificationService.setMidnightNotification(event.enabled);
      final settings = _notificationService.currentSettings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateMorningTime(
    UpdateMorningTime event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await _notificationService.setMorningTime(event.time);
      final settings = _notificationService.currentSettings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateEveningTime(
    UpdateEveningTime event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await _notificationService.setEveningTime(event.time);
      final settings = _notificationService.currentSettings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateMidnightTime(
    UpdateMidnightTime event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await _notificationService.setMidnightTime(event.time);
      final settings = _notificationService.currentSettings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> _onToggleSound(
    ToggleSound event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await _notificationService.setSoundEnabled(event.enabled);
      final settings = _notificationService.currentSettings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> _onToggleVibration(
    ToggleVibration event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      await _notificationService.setVibrationEnabled(event.enabled);
      final settings = _notificationService.currentSettings;
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }
}
