import 'package:alazkar/src/core/models/notification_settings_model.dart';
import 'package:alazkar/src/features/settings/presentation/bloc/notification_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
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
        title: const Text('إعدادات الإشعارات'),
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
        // Enable/Disable Notifications
        Card(
          child: SwitchListTile(
            title: const Text('تفعيل الإشعارات'),
            subtitle: const Text('تلقي إشعارات الأذكار اليومية'),
            value: settings.isEnabled,
            onChanged: (value) {
              final newSettings = settings.copyWith(isEnabled: value);
              context.read<NotificationSettingsBloc>().add(
                    UpdateNotificationSettings(newSettings),
                  );
            },
          ),
        ),
        const SizedBox(height: 16),

        if (settings.isEnabled) ...[
          // Morning Notifications
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('أذكار الصباح'),
                  subtitle: const Text('تلقي إشعار أذكار الصباح'),
                  value: settings.notifyMorning,
                  onChanged: (value) {
                    context.read<NotificationSettingsBloc>().add(
                          ToggleMorningNotification(value),
                        );
                  },
                ),
                if (settings.notifyMorning)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TimePickerTile(
                      title: 'وقت التنبيه',
                      initialTime: settings.morningTime,
                      onTimeChanged: (time) {
                        context.read<NotificationSettingsBloc>().add(
                              UpdateMorningTime(time),
                            );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Evening Notifications
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('أذكار المساء'),
                  subtitle: const Text('تلقي إشعار أذكار المساء'),
                  value: settings.notifyEvening,
                  onChanged: (value) {
                    context.read<NotificationSettingsBloc>().add(
                          ToggleEveningNotification(value),
                        );
                  },
                ),
                if (settings.notifyEvening)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TimePickerTile(
                      title: 'وقت التنبيه',
                      initialTime: settings.eveningTime,
                      onTimeChanged: (time) {
                        context.read<NotificationSettingsBloc>().add(
                              UpdateEveningTime(time),
                            );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Midnight Notifications
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('أذكار الليل'),
                  subtitle: const Text('تلقي إشعار أذكار الليل'),
                  value: settings.notifyMidnight,
                  onChanged: (value) {
                    context.read<NotificationSettingsBloc>().add(
                          ToggleMidnightNotification(value),
                        );
                  },
                ),
                if (settings.notifyMidnight)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TimePickerTile(
                      title: 'وقت التنبيه',
                      initialTime: settings.midnightTime,
                      onTimeChanged: (time) {
                        context.read<NotificationSettingsBloc>().add(
                              UpdateMidnightTime(time),
                            );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sound and Vibration Settings
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تفعيل الصوت'),
                  subtitle: const Text('تشغيل صوت الإشعار'),
                  value: settings.enableSound,
                  onChanged: (value) {
                    context.read<NotificationSettingsBloc>().add(
                          ToggleSound(value),
                        );
                  },
                ),
                SwitchListTile(
                  title: const Text('تفعيل الاهتزاز'),
                  subtitle: const Text('تفعيل الاهتزاز عند الإشعار'),
                  value: settings.enableVibration,
                  onChanged: (value) {
                    context.read<NotificationSettingsBloc>().add(
                          ToggleVibration(value),
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Information
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات مهمة:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• تأكد من تفعيل إذن الإشعارات في إعدادات الهاتف\n'
                    '• يجب أن يكون التطبيق مثبتاً على الهاتف\n'
                    '• قد تختلف أوقات الإشعارات حسب أداء الهاتف\n'
                    '• متوافق مع Xiaomi HyperOS 3.0.3 و Android 16',
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class TimePickerTile extends StatelessWidget {
  final String title;
  final String initialTime;
  final Function(String) onTimeChanged;

  const TimePickerTile({
    super.key,
    required this.title,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text(initialTime),
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
