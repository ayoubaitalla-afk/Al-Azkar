import 'package:equatable/equatable.dart';

class ZhikrNotificationModel extends Equatable {
  final int id;
  final String zhikrId; // Unique identifier for the zhikr
  final String zhikrTitle; // Title of the zhikr (e.g., "سبحان الله")
  final String zhikrCategory; // Category (morning, evening, etc.)
  final bool isEnabled;
  final String notificationTime; // HH:mm format
  final bool enableSound;
  final bool enableVibration;
  final String? customMessage; // Custom notification message

  const ZhikrNotificationModel({
    required this.id,
    required this.zhikrId,
    required this.zhikrTitle,
    required this.zhikrCategory,
    this.isEnabled = true,
    this.notificationTime = '07:00',
    this.enableSound = true,
    this.enableVibration = true,
    this.customMessage,
  });

  ZhikrNotificationModel copyWith({
    int? id,
    String? zhikrId,
    String? zhikrTitle,
    String? zhikrCategory,
    bool? isEnabled,
    String? notificationTime,
    bool? enableSound,
    bool? enableVibration,
    String? customMessage,
  }) {
    return ZhikrNotificationModel(
      id: id ?? this.id,
      zhikrId: zhikrId ?? this.zhikrId,
      zhikrTitle: zhikrTitle ?? this.zhikrTitle,
      zhikrCategory: zhikrCategory ?? this.zhikrCategory,
      isEnabled: isEnabled ?? this.isEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      customMessage: customMessage ?? this.customMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zhikrId': zhikrId,
      'zhikrTitle': zhikrTitle,
      'zhikrCategory': zhikrCategory,
      'isEnabled': isEnabled,
      'notificationTime': notificationTime,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'customMessage': customMessage,
    };
  }

  factory ZhikrNotificationModel.fromMap(Map<String, dynamic> map) {
    return ZhikrNotificationModel(
      id: map['id'] as int,
      zhikrId: map['zhikrId'] as String,
      zhikrTitle: map['zhikrTitle'] as String,
      zhikrCategory: map['zhikrCategory'] as String,
      isEnabled: map['isEnabled'] as bool? ?? true,
      notificationTime: map['notificationTime'] as String? ?? '07:00',
      enableSound: map['enableSound'] as bool? ?? true,
      enableVibration: map['enableVibration'] as bool? ?? true,
      customMessage: map['customMessage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        zhikrId,
        zhikrTitle,
        zhikrCategory,
        isEnabled,
        notificationTime,
        enableSound,
        enableVibration,
        customMessage,
      ];
}

class NotificationSettingsModel extends Equatable {
  final bool isGloballyEnabled;
  final List<ZhikrNotificationModel> zhikrNotifications;
  final bool globalSound;
  final bool globalVibration;

  const NotificationSettingsModel({
    this.isGloballyEnabled = false,
    this.zhikrNotifications = const [],
    this.globalSound = true,
    this.globalVibration = true,
  });

  bool get isEnabled => isGloballyEnabled;

  bool get notifyMorning => _isCategoryEnabled('morning');
  bool get notifyEvening => _isCategoryEnabled('evening');
  bool get notifyMidnight => _isCategoryEnabled('midnight');

  String get morningTime => _getCategoryTime('morning');
  String get eveningTime => _getCategoryTime('evening');
  String get midnightTime => _getCategoryTime('midnight');

  bool get enableSound => globalSound;
  bool get enableVibration => globalVibration;

  bool _isCategoryEnabled(String category) {
    try {
      return zhikrNotifications
          .firstWhere((z) => z.zhikrCategory == category)
          .isEnabled;
    } catch (_) {
      return false;
    }
  }

  String _getCategoryTime(String category) {
    try {
      return zhikrNotifications
          .firstWhere((z) => z.zhikrCategory == category)
          .notificationTime;
    } catch (_) {
      return '07:00';
    }
  }

  NotificationSettingsModel copyWith({
    bool? isGloballyEnabled,
    bool? isEnabled, // Support both names
    List<ZhikrNotificationModel>? zhikrNotifications,
    bool? globalSound,
    bool? globalVibration,
  }) {
    return NotificationSettingsModel(
      isGloballyEnabled:
          isEnabled ?? isGloballyEnabled ?? this.isGloballyEnabled,
      zhikrNotifications: zhikrNotifications ?? this.zhikrNotifications,
      globalSound: globalSound ?? this.globalSound,
      globalVibration: globalVibration ?? this.globalVibration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isGloballyEnabled': isGloballyEnabled,
      'zhikrNotifications': zhikrNotifications.map((z) => z.toMap()).toList(),
      'globalSound': globalSound,
      'globalVibration': globalVibration,
    };
  }

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      isGloballyEnabled: map['isGloballyEnabled'] as bool? ?? false,
      zhikrNotifications: (map['zhikrNotifications'] as List<dynamic>?)
              ?.map((z) => ZhikrNotificationModel.fromMap(
                  Map<String, dynamic>.from(z as Map)))
              .toList() ??
          [],
      globalSound: map['globalSound'] as bool? ?? true,
      globalVibration: map['globalVibration'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        isGloballyEnabled,
        zhikrNotifications,
        globalSound,
        globalVibration,
      ];
}
