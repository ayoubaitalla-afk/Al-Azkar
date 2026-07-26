import 'package:alazkar/src/core/manager/notification_manager.dart';

class NotificationBroadcastReceiver {
  static Future<void> handleNotification() async {
    // Initialize NotificationManager
    final notificationManager = NotificationManager();
    await notificationManager.initialize();
    
    // This is called when the notification is received
    print('Notification received via broadcast receiver');
  }
}
