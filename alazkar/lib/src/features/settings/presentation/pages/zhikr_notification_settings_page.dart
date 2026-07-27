import 'package:alazkar/src/core/models/notification_settings_model.dart';
import 'package:alazkar/src/features/settings/presentation/bloc/notification_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ZhikrNotificationSettingsPage extends StatefulWidget {
  const ZhikrNotificationSettingsPage({super.key});

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
            return _buildSettingsList(context, state.settings);
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

  Widget _buildSettingsList(
    BuildContext context,
    NotificationSettingsModel settings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Global Toggle
        Card(
          child: SwitchListTile(
            title: const Text('تفعيل الإشعارات'),
            subtitle: const Text('تفعيل أو تعطيل جميع الإشعارات'),
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

        if (settings.isGloballyEnabled) ...[
          // Global Sound and Vibration
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
          const SizedBox(height: 24),

          const Text(
            'تخصيص الأذكار',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ...settings.zhikrNotifications.map((zhikr) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(zhikr.zhikrTitle),
                subtitle: Text('وقت التنبيه: ${zhikr.notificationTime}'),
                trailing: Switch(
                  value: zhikr.isEnabled,
                  onChanged: (value) {
                    final updatedList =
                        settings.zhikrNotifications.map((z) {
                      if (z.id == zhikr.id) {
                        return z.copyWith(isEnabled: value);
                      }
                      return z;
                    }).toList();
                    context.read<NotificationSettingsBloc>().add(
                          UpdateNotificationSettings(
                            settings.copyWith(
                                zhikrNotifications: updatedList),
                          ),
                        );
                  },
                ),
                onTap: () => _showEditDialog(context, zhikr, settings),
              ),
            );
          }),
        ],
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    ZhikrNotificationModel zhikr,
    NotificationSettingsModel settings,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return ZhikrEditDialog(
          zhikr: zhikr,
          onSave: (updatedZhikr) {
            final updatedList = settings.zhikrNotifications.map((z) {
              if (z.id == updatedZhikr.id) {
                return updatedZhikr;
              }
              return z;
            }).toList();
            context.read<NotificationSettingsBloc>().add(
                  UpdateNotificationSettings(
                    settings.copyWith(zhikrNotifications: updatedList),
                  ),
                );
          },
        );
      },
    );
  }
}

class ZhikrEditDialog extends StatefulWidget {
  final ZhikrNotificationModel zhikr;
  final Function(ZhikrNotificationModel) onSave;

  const ZhikrEditDialog({
    super.key,
    required this.zhikr,
    required this.onSave,
  });

  @override
  State<ZhikrEditDialog> createState() => _ZhikrEditDialogState();
}

class _ZhikrEditDialogState extends State<ZhikrEditDialog> {
  late String _time;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _time = widget.zhikr.notificationTime;
    _messageController =
        TextEditingController(text: widget.zhikr.customMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تعديل: ${widget.zhikr.zhikrTitle}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('وقت التنبيه'),
              trailing: Text(_time),
              onTap: () async {
                final parts = _time.split(':');
                final hour = int.parse(parts[0]);
                final minute = int.parse(parts[1]);

                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: hour, minute: minute),
                );

                if (picked != null) {
                  setState(() {
                    _time =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  });
                }
              },
            ),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'رسالة التنبيه (اختياري)',
                hintText: 'مثال: حان وقت ذكر الله',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final updated = widget.zhikr.copyWith(
              notificationTime: _time,
              customMessage: _messageController.text.isEmpty
                  ? null
                  : _messageController.text,
            );
            widget.onSave(updated);
            Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
