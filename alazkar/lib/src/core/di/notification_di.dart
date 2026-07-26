import 'package:alazkar/src/core/manager/notification_manager.dart';
import 'package:alazkar/src/core/manager/notification_service.dart';
import 'package:alazkar/src/features/settings/data/notification_settings_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Register notification services in the dependency injection container
void setupNotificationDependencies() {
  // Register NotificationManager (singleton)
  getIt.registerSingleton<NotificationManager>(
    NotificationManager(),
  );

  // Register NotificationSettingsRepository (singleton)
  getIt.registerSingleton<NotificationSettingsRepository>(
    NotificationSettingsRepository(),
  );

  // Register NotificationService (singleton)
  getIt.registerSingleton<NotificationService>(
    NotificationService(
      notificationManager: getIt<NotificationManager>(),
      settingsRepository: getIt<NotificationSettingsRepository>(),
    ),
  );
}
