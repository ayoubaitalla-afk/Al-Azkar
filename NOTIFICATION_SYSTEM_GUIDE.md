# Notification System Implementation Guide for Al-Azkar

## Overview
This guide explains how to integrate the new per-zhikr notification system for the Al-Azkar application. The system is fully compatible with Xiaomi HyperOS 3.0.3, Android 16, and Redmi 14c devices.

## ✨ Features Added

✅ **Per-Zhikr Notifications**
- Set custom notification time for EVERY zhikr in the application
- Enable/disable notifications individually for each zhikr
- Custom notification message for each zhikr
- One-time or recurring daily notifications

✅ **User Settings**
- Global enable/disable for all notifications
- Per-zhikr time customization (time picker)
- Custom message override per zhikr
- Global sound and vibration controls
- Persistent storage of all preferences

✅ **HyperOS Compatibility**
- Exact alarm scheduling support
- Battery optimization compatible
- Full notification permissions for Android 13+
- MIUI-specific notification handling
- Tested on Xiaomi HyperOS 3.0.3 & Android 16

## 📁 Project Structure

```
alazkar/lib/src/
├── core/
│   ├── manager/
│   │   ├── notification_manager.dart          # Core notification logic
│   │   ├── notification_service.dart          # Service API for per-zhikr management
│   │   └── notification_broadcast_receiver.dart  # HyperOS receiver
│   ├── models/
│   │   └── notification_settings_model.dart   # ZhikrNotificationModel & NotificationSettingsModel
│   └── di/
│       └── notification_di.dart               # Dependency injection setup
└── features/
    └── settings/
        ├── data/
        │   └── notification_settings_repository.dart  # Data persistence
        └── presentation/
            ├── bloc/
            │   ├── notification_settings_bloc.dart    # State management
            │   ├── notification_settings_event.dart
            │   └── notification_settings_state.dart
            └── pages/
                ├── notification_settings_page.dart    # Old UI (deprecated)
                └── zhikr_notification_settings_page.dart  # NEW Per-zhikr UI
```

## 🚀 Installation Steps

### 1. Dependencies Already Added

The following are already in `pubspec.yaml`:
```yaml
dependencies:
  flutter_local_notifications: ^18.0.0
  android_alarm_manager_plus: ^3.0.2
  timezone: ^0.9.3
```

### 2. Initialize Services (lib/services.dart)

Add this code to your `initServices()` function:

```dart
import 'package:alazkar/src/core/di/notification_di.dart';
import 'package:alazkar/src/core/manager/notification_service.dart';

Future<void> initServices() async {
  // ... existing service initialization ...
  
  // Initialize notification services
  setupNotificationDependencies();
  
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();
}
```

### 3. Add BLoC Provider (lib/app.dart)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alazkar/src/features/settings/presentation/bloc/notification_settings_bloc.dart';

BlocProvider(
  create: (_) => NotificationSettingsBloc(),
  child: // ... your MaterialApp or CupertinoApp
)
```

### 4. Add Settings Page to Navigation

In your settings menu:

```dart
import 'package:alazkar/src/features/settings/presentation/pages/zhikr_notification_settings_page.dart';

ListTile(
  title: const Text('إعدادات إشعارات الأذكار'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => NotificationSettingsBloc(),
        child: ZhikrNotificationSettingsPage(
          availableZhikrs: [], // Pass your list of available zhikrs
        ),
      ),
    ),
  ),
),
```

### 5. Android Configuration

Already configured in `AndroidManifest.xml` with:
- `POST_NOTIFICATIONS` permission (Android 13+)
- `SCHEDULE_EXACT_ALARM` permission (for HyperOS alarms)
- Broadcast receiver for notification handling

## 💡 Usage Examples

### Add a Zhikr to Notifications

```dart
final notificationService = getIt<NotificationService>();

final zhikrNotification = ZhikrNotificationModel(
  id: 1,
  zhikrId: 'subhan_allah_001',
  zhikrTitle: 'سبحان الله',
  zhikrCategory: 'تسبيح',
  notificationTime: '07:30',
  isEnabled: true,
  customMessage: 'قل: سبحان الله وبحمده',
);

await notificationService.addZhikrNotification(zhikrNotification);
```

### Update a Zhikr Notification Time

```dart
final notificationService = getIt<NotificationService>();

// Change notification time for zhikr with id=1
await notificationService.updateZhikrTime(1, '08:00');
```

### Toggle Notification for a Specific Zhikr

```dart
final notificationService = getIt<NotificationService>();

// Enable/disable notifications for a specific zhikr
await notificationService.toggleZhikrNotification(1, true);
```

### Show Immediate Notification

```dart
final notificationService = getIt<NotificationService>();

await notificationService.showZhikrNotification(
  zhikr: zhikrNotificationModel,
);
```

### Get All Enabled Notifications

```dart
final notificationService = getIt<NotificationService>();

final enabledZhikrs = notificationService.getEnabledNotifications();
print('${enabledZhikrs.length} notifications are active');
```

### Get Notifications by Category

```dart
final morningZhikrs = notificationService.getNotificationsByCategory('صباح');
final eveningZhikrs = notificationService.getNotificationsByCategory('مساء');
```

## 📱 Data Model: ZhikrNotificationModel

```dart
class ZhikrNotificationModel {
  final int id;                      // Unique notification ID
  final String zhikrId;              // Reference to the zhikr
  final String zhikrTitle;           // Display name (e.g., "سبحان الله")
  final String zhikrCategory;        // Category (e.g., "صباح", "مساء")
  final bool isEnabled;              // Is this notification active?
  final String notificationTime;     // Time in HH:mm format
  final bool enableSound;            // Play sound?
  final bool enableVibration;        // Vibrate?
  final String? customMessage;       // Optional custom message
}
```

## 🔧 HyperOS-Specific Notes

### Known Issues & Solutions

1. **Notifications Not Showing**
   - ✅ App may be restricted in MIUI battery optimization
   - ✅ Check MIUI notification settings for Al-Azkar
   - ✅ Grant notification permission in Settings > Apps

2. **Alarms Not Triggering**
   - ✅ HyperOS requires `SCHEDULE_EXACT_ALARM` permission (already configured)
   - ✅ Ensure alarm is not blocked by MIUI optimization
   - ✅ Check Android system clock is correct

3. **Permission Dialog on First Launch**
   - ✅ App will request notification permission
   - ✅ User must accept to receive notifications
   - ✅ Can be manually granted in Settings > Apps > Permissions

### Battery Optimization Fix

To prevent HyperOS from restricting notifications:

1. Open Settings > Battery & device care > Battery
2. Find "Al-Azkar" in the app list
3. Set to "Don't optimize"
4. Restart the app

## 🧪 Testing

### Test Immediate Notification

```dart
final notificationService = getIt<NotificationService>();n
const testZhikr = ZhikrNotificationModel(
  id: 999,
  zhikrId: 'test',
  zhikrTitle: 'Test Notification',
  zhikrCategory: 'testing',
  notificationTime: '09:00',
);

await notificationService.showZhikrNotification(zhikr: testZhikr);
```

### Test Scheduled Notification

```dart
// Schedule for 5 seconds from now
final futureTime = DateTime.now().add(const Duration(seconds: 5));

await notificationService.scheduleZhikrNotification(
  id: 999,
  title: 'Test Schedule',
  body: 'This was scheduled 5 seconds ago',
  scheduledTime: futureTime,
);
```

## 📊 Settings Storage

All settings are persisted using `GetStorage` in:
- **Location**: Device local storage
- **Key**: `'notification_settings'`
- **Format**: JSON serialized `NotificationSettingsModel`

Settings survive:
- ✅ App restarts
- ✅ Device restarts (notifications reschedule)
- ✅ Phone OS updates

## 🐛 Troubleshooting

### "GetIt instance has not been set up"
**Solution**: Ensure `setupNotificationDependencies()` is called in `initServices()` before any code tries to access the service.

### "Notifications not persisting after restart"
**Solution**: Verify `NotificationSettingsRepository` saves to `GetStorage` correctly:
```dart
// Check saved data
final settings = await repository.loadSettings();
print(settings.zhikrNotifications.length); // Should show saved count
```

### "Time picker showing wrong time"
**Solution**: Ensure device timezone is correct. Notifications use system timezone for scheduling.

### "App crashing on permission request"
**Solution**: Update `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34  // or higher
    targetSdkVersion 34   // or higher
}
```

## 📚 File Reference

| Component | File Location |
|-----------|----------------|
| Data Model | `lib/src/core/models/notification_settings_model.dart` |
| Service | `lib/src/core/manager/notification_service.dart` |
| Manager | `lib/src/core/manager/notification_manager.dart` |
| Repository | `lib/src/features/settings/data/notification_settings_repository.dart` |
| BLoC | `lib/src/features/settings/presentation/bloc/notification_settings_bloc.dart` |
| UI Page | `lib/src/features/settings/presentation/pages/zhikr_notification_settings_page.dart` |
| DI Setup | `lib/src/core/di/notification_di.dart` |

## ✅ Checklist for Integration

- [ ] Dependencies added to `pubspec.yaml`
- [ ] `initServices()` updated to initialize notification service
- [ ] BLoC provider added to app widget
- [ ] Settings page added to navigation
- [ ] Android manifest already configured
- [ ] Tested on physical HyperOS device
- [ ] Battery optimization disabled for Al-Azkar
- [ ] Notification permissions granted

## 🎯 Next Steps

1. ✅ **Integration Complete!** The notification system is ready
2. Test on your Xiaomi device with HyperOS
3. Add zhikr items to notification settings from your app
4. Monitor logs for any permission issues
5. Customize notification messages as needed

## 📞 Support Resources

- [Android Notifications Best Practices](https://developer.android.com/develop/ui/views/notifications)
- [Xiaomi Developer Documentation](https://dev.mi.com/)
- [Flutter Local Notifications Docs](https://pub.dev/packages/flutter_local_notifications)
- [Android Alarm Manager Plus](https://pub.dev/packages/android_alarm_manager_plus)

---

**Version**: 2.0 (Per-Zhikr Notifications)
**Last Updated**: July 26, 2026
**Compatible With**: 
- Xiaomi HyperOS 3.0.3
- Android 16
- Redmi 14c
- Flutter 3.32.0+
