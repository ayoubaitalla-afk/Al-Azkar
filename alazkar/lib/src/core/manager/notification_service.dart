import 'package:alazkar/src/core/manager/notification_manager.dart';
import 'package:alazkar/src/core/models/notification_settings_model.dart';
import 'package:alazkar/src/features/settings/data/notification_settings_repository.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final NotificationManager _notificationManager;
  final NotificationSettingsRepository _settingsRepository;

  late NotificationSettingsModel _currentSettings;

  NotificationService({
    required NotificationManager notificationManager,
    required NotificationSettingsRepository settingsRepository,
  })  : _notificationManager = notificationManager,
        _settingsRepository = settingsRepository;

  Future<void> initialize() async {
    await _notificationManager.initialize();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    _currentSettings = await _settingsRepository.loadSettings();
  }

  NotificationSettingsModel get currentSettings => _currentSettings;

  /// Update notification settings and reschedule notifications
  Future<void> updateSettings(NotificationSettingsModel newSettings) async {
    _currentSettings = newSettings;
    await _settingsRepository.saveSettings(newSettings);

    if (newSettings.isGloballyEnabled) {
      await _scheduleAllNotifications();
    } else {
      await _notificationManager.cancelAllNotifications();
    }
  }

  /// Schedule all zhikr notifications based on current settings
  Future<void> _scheduleAllNotifications() async {
    await _notificationManager.cancelAllNotifications();

    for (final zhikrNotif in _currentSettings.zhikrNotifications) {
      if (zhikrNotif.isEnabled) {
        final parts = zhikrNotif.notificationTime.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        await _notificationManager.scheduleDailyZhikrNotification(
          id: zhikrNotif.id,
          title: zhikrNotif.zhikrTitle,
          body: zhikrNotif.customMessage ?? 'حان وقت: ${zhikrNotif.zhikrTitle}',
          time: TimeOfDay(hour: hour, minute: minute),
          payload: zhikrNotif.zhikrId,
        );
      }
    }
  }

  /// Show an immediate notification for a specific zhikr
  Future<void> showZhikrNotification({
    required ZhikrNotificationModel zhikr,
  }) async {
    if (!_currentSettings.isGloballyEnabled || !zhikr.isEnabled) return;

    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _notificationManager.showZhikrNotification(
      id: notificationId,
      title: zhikr.zhikrTitle,
      body: zhikr.customMessage ?? 'حان وقت: ${zhikr.zhikrTitle}',
      payload: zhikr.zhikrId,
    );
  }

  /// Add a new zhikr notification
  Future<void> addZhikrNotification(ZhikrNotificationModel zhikr) async {
    final updated =
        List<ZhikrNotificationModel>.from(_currentSettings.zhikrNotifications);
    updated.add(zhikr);
    await updateSettings(
      _currentSettings.copyWith(zhikrNotifications: updated),
    );
  }

  /// Update an existing zhikr notification
  Future<void> updateZhikrNotification(ZhikrNotificationModel zhikr) async {
    final index = _currentSettings.zhikrNotifications
        .indexWhere((z) => z.id == zhikr.id);
    if (index >= 0) {
      final updated = List<ZhikrNotificationModel>.from(
          _currentSettings.zhikrNotifications);
      updated[index] = zhikr;
      await updateSettings(
        _currentSettings.copyWith(zhikrNotifications: updated),
      );
    }
  }

  /// Remove a zhikr notification
  Future<void> removeZhikrNotification(int zhikrId) async {
    final updated = _currentSettings.zhikrNotifications
        .where((z) => z.id != zhikrId)
        .toList();
    await updateSettings(
      _currentSettings.copyWith(zhikrNotifications: updated),
    );
  }

  /// Toggle notification for a specific zhikr
  Future<void> toggleZhikrNotification(int zhikrId, bool enabled) async {
    final index = _currentSettings.zhikrNotifications
        .indexWhere((z) => z.id == zhikrId);
    if (index >= 0) {
      final updated = List<ZhikrNotificationModel>.from(
          _currentSettings.zhikrNotifications);
      updated[index] = updated[index].copyWith(isEnabled: enabled);
      await updateSettings(
        _currentSettings.copyWith(zhikrNotifications: updated),
      );
    }
  }

  /// Update notification time for a specific zhikr
  Future<void> updateZhikrTime(int zhikrId, String time) async {
    final index = _currentSettings.zhikrNotifications
        .indexWhere((z) => z.id == zhikrId);
    if (index >= 0) {
      final updated = List<ZhikrNotificationModel>.from(
          _currentSettings.zhikrNotifications);
      updated[index] = updated[index].copyWith(notificationTime: time);
      await updateSettings(
        _currentSettings.copyWith(zhikrNotifications: updated),
      );
    }
  }

  /// Update custom message for a specific zhikr
  Future<void> updateZhikrMessage(int zhikrId, String? message) async {
    final index = _currentSettings.zhikrNotifications
        .indexWhere((z) => z.id == zhikrId);
    if (index >= 0) {
      final updated = List<ZhikrNotificationModel>.from(
          _currentSettings.zhikrNotifications);
      updated[index] = updated[index].copyWith(customMessage: message);
      await updateSettings(
        _currentSettings.copyWith(zhikrNotifications: updated),
      );
    }
  }

  /// Helper to toggle notifications by category
  Future<void> _toggleCategoryNotification(
      String category, bool enabled) async {
    final index = _currentSettings.zhikrNotifications
        .indexWhere((z) => z.zhikrCategory == category);
    if (index >= 0) {
      await toggleZhikrNotification(
          _currentSettings.zhikrNotifications[index].id, enabled);
    }
  }

  /// Helper to update time by category
  Future<void> _updateCategoryTime(String category, String time) async {
    final index = _currentSettings.zhikrNotifications
        .indexWhere((z) => z.zhikrCategory == category);
    if (index >= 0) {
      await updateZhikrTime(
          _currentSettings.zhikrNotifications[index].id, time);
    }
  }

  Future<void> setMorningNotification(bool enabled) async =>
      _toggleCategoryNotification('morning', enabled);
  Future<void> setEveningNotification(bool enabled) async =>
      _toggleCategoryNotification('evening', enabled);
  Future<void> setMidnightNotification(bool enabled) async =>
      _toggleCategoryNotification('midnight', enabled);

  Future<void> setMorningTime(String time) async =>
      _updateCategoryTime('morning', time);
  Future<void> setEveningTime(String time) async =>
      _updateCategoryTime('evening', time);
  Future<void> setMidnightTime(String time) async =>
      _updateCategoryTime('midnight', time);

  Future<void> setSoundEnabled(bool enabled) async => toggleGlobalSound(enabled);
  Future<void> setVibrationEnabled(bool enabled) async =>
      toggleGlobalVibration(enabled);

  /// Get notifications for a specific category
  List<ZhikrNotificationModel> getNotificationsByCategory(String category) {
    return _currentSettings.zhikrNotifications
        .where((z) => z.zhikrCategory == category)
        .toList();
  }

  /// Get all enabled notifications
  List<ZhikrNotificationModel> getEnabledNotifications() {
    return _currentSettings.zhikrNotifications
        .where((z) => z.isEnabled)
        .toList();
  }

  /// Get pending notifications
  Future<List<dynamic>> getPendingNotifications() async {
    return await _notificationManager.getPendingNotifications();
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationManager.cancelNotification(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationManager.cancelAllNotifications();
  }

  /// Toggle global notifications
  Future<void> toggleGlobalNotifications(bool enabled) async {
    final newSettings = _currentSettings.copyWith(isGloballyEnabled: enabled);
    await updateSettings(newSettings);
  }

  /// Toggle global sound
  Future<void> toggleGlobalSound(bool enabled) async {
    final newSettings = _currentSettings.copyWith(globalSound: enabled);
    await updateSettings(newSettings);
  }

  /// Toggle global vibration
  Future<void> toggleGlobalVibration(bool enabled) async {
    final newSettings = _currentSettings.copyWith(globalVibration: enabled);
    await updateSettings(newSettings);
  }
}
