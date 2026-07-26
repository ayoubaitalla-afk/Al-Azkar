import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alazkar/src/core/models/notification_settings_model.dart';
import 'package:alazkar/src/features/settings/presentation/bloc/notification_settings_bloc.dart';

class ZhikrNotificationSettingsPage extends StatefulWidget {
  final List<ZhikrNotificationModel> availableZhikrs;

  const ZhikrNotificationSettingsPage({
    Key? key,
    required this.availableZhikrs,
  }) : super(key: key);

  @override
  State<ZhikrNotificationSettingsPage> createState() =>
      _ZhikrNotificationSettingsPageState();
}

class _ZhikrNotificationSettingsPageState
    extends State<ZhikrNotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationSettingsBloc>().add(
          const LoadNotificationSettings(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات إشعارات الأذكار'),
        centerTitle: true,
      ),
      body: BlocBuilder<NotificationSettingsBloc, NotificationSettingsState>(
        builder: (context, state) {
          if (state is NotificationSettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is NotificationSettingsLoaded) {
            return _buildNotificationSettings(context, state.settings);
          } else if (state is NotificationSettingsError) {
            return Center(
              child: Text('خطأ: ${state.message}'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationSettings(
    BuildContext context,
    NotificationSettingsModel settings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Global Enable/Disable
        Card(
          child: SwitchListTile(
            title: const Text('تفعيل جميع الإشعارات'),
            subtitle: const Text('تلقي إشعارات الأذكار'),
            value: settings.isGloballyEnabled,
            onChanged: (value) {
              context.read<NotificationSettingsBloc>().add(
                    UpdateNotificationSettings(
                      settings.copyWith(isGloballyEnabled: value),
                    ),
                  );
            },
          ),
        ),
        const SizedBox(height: 16),

        if (settings.isGloballyEnabled) ...[\n          // Global Sound and Vibration
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تفعيل الصوت'),
                  subtitle: const Text('تشغيل صوت الإشعار'),
                  value: settings.globalSound,
                  onChanged: (value) {
                    context.read<NotificationSettingsBloc>().add(
                          UpdateNotificationSettings(
                            settings.copyWith(globalSound: value),
                          ),
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('تفعيل الاهتزاز'),
                  subtitle: const Text('تفعيل الاهتزاز عند الإشعار'),
                  value: settings.globalVibration,
                  onChanged: (value) {
                    context.read<NotificationSettingsBloc>().add(
                          UpdateNotificationSettings(
                            settings.copyWith(globalVibration: value),
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Zhikr Notifications List
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'الأذكار',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (settings.zhikrNotifications.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.notifications_off, size: 48),
                      SizedBox(height: 8),
                      Text('لم يتم إضافة أي أذكار للإشعارات'),
                      Text('أضف أذكار من قائمة الأذكار الرئيسية'),
                    ],
                  ),
                ),
              ),
            )
          else
            ...settings.zhikrNotifications.map((zhikr) {
              return _buildZhikrNotificationCard(
                context,
                zhikr,
                settings,
              );
            }).toList(),
        ],
      ],
    );
  }

  Widget _buildZhikrNotificationCard(
    BuildContext context,
    ZhikrNotificationModel zhikr,
    NotificationSettingsModel settings,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: SizedBox(
          width: 40,
          child: Center(
            child: Checkbox(
              value: zhikr.isEnabled,
              onChanged: (value) {
                if (value != null) {
                  final updated = zhikr.copyWith(isEnabled: value);
                  final newZhikrs = settings.zhikrNotifications.map((z) {
                    return z.id == zhikr.id ? updated : z;
                  }).toList();
                  context.read<NotificationSettingsBloc>().add(
                        UpdateNotificationSettings(
                          settings.copyWith(
                              zhikrNotifications: newZhikrs),
                        ),
                      );
                }
              },
            ),
          ),
        ),
        title: Text(
          zhikr.zhikrTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: zhikr.isEnabled ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          'الوقت: ${zhikr.notificationTime}',
          style: TextStyle(
            color: zhikr.isEnabled ? Colors.grey[700] : Colors.grey,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TimePickerTile(
                  title: 'وقت التنبيه',
                  initialTime: zhikr.notificationTime,
                  onTimeChanged: (time) {
                    final updated = zhikr.copyWith(notificationTime: time);
                    final newZhikrs = settings.zhikrNotifications.map((z) {
                      return z.id == zhikr.id ? updated : z;
                    }).toList();
                    context.read<NotificationSettingsBloc>().add(
                          UpdateNotificationSettings(
                            settings.copyWith(
                                zhikrNotifications: newZhikrs),
                          ),
                        );
                  },
                ),
                const Divider(),
                TextFormField(
                  initialValue: zhikr.customMessage,
                  decoration: InputDecoration(
                    labelText: 'رسالة مخصصة (اختياري)',
                    hintText:
                        'أترك فارغاً للرسالة الافتراضية: ${zhikr.zhikrTitle}',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    final updated = zhikr.copyWith(
                      customMessage: value.isEmpty ? null : value,
                    );
                    final newZhikrs = settings.zhikrNotifications.map((z) {
                      return z.id == zhikr.id ? updated : z;
                    }).toList();
                    context.read<NotificationSettingsBloc>().add(
                          UpdateNotificationSettings(
                            settings.copyWith(
                                zhikrNotifications: newZhikrs),
                          ),
                        );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        final newZhikrs = settings.zhikrNotifications
                            .where((z) => z.id != zhikr.id)
                            .toList();
                        context.read<NotificationSettingsBloc>().add(
                              UpdateNotificationSettings(
                                settings.copyWith(
                                    zhikrNotifications: newZhikrs),
                              ),
                            );
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'حذف',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _showNotificationPreview(context, zhikr);
                      },
                      icon: const Icon(Icons.notifications_active,
                          color: Colors.blue),
                      label: const Text(
                        'معاينة',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationPreview(
    BuildContext context,
    ZhikrNotificationModel zhikr,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zhikr.zhikrTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              zhikr.customMessage ?? 'حان وقت: ${zhikr.zhikrTitle}',
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class TimePickerTile extends StatelessWidget {
  final String title;
  final String initialTime;
  final Function(String) onTimeChanged;

  const TimePickerTile({
    Key? key,
    required this.title,
    required this.initialTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        initialTime,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        final parts = initialTime.split(':');
        final initialHour = int.parse(parts[0]);
        final initialMinute = int.parse(parts[1]);

        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
        );

        if (pickedTime != null) {
          final time =
              '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
          onTimeChanged(time);
        }
      },
    );
  }
}
