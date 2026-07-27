import 'dart:convert';
import 'package:alazkar/src/core/models/notification_settings_model.dart';
import 'package:get_storage/get_storage.dart';

class NotificationSettingsRepository {
  final _storage = GetStorage();
  static const _key = 'notification_settings';

  Future<NotificationSettingsModel> loadSettings() async {
    final String? data = _storage.read(_key);
    if (data == null) {
      return const NotificationSettingsModel();
    }
    return NotificationSettingsModel.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  Future<void> saveSettings(NotificationSettingsModel settings) async {
    await _storage.write(_key, json.encode(settings.toMap()));
  }
}
