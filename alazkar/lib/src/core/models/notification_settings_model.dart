import 'package:equatable/equatable.dart';

class NotificationSettingsModel extends Equatable {
  final bool isEnabled;
  final bool notifyMorning;
  final bool notifyEvening;
  final bool notifyMidnight;
  final String morningTime; // HH:mm format
  final String eveningTime; // HH:mm format
  final String midnightTime; // HH:mm format
  final bool enableSound;
  final bool enableVibration;
  final int notificationChannel; // 1: all, 2: morning only, 3: evening only

  const NotificationSettingsModel({
    this.isEnabled = false,
    this.notifyMorning = true,
    this.notifyEvening = true,
    this.notifyMidnight = false,
    this.morningTime = '07:00',
    this.eveningTime = '18:00',
    this.midnightTime = '00:00',
    this.enableSound = true,
    this.enableVibration = true,
    this.notificationChannel = 1,
  });

  NotificationSettingsModel copyWith({
    bool? isEnabled,
    bool? notifyMorning,
    bool? notifyEvening,
    bool? notifyMidnight,
    String? morningTime,
    String? eveningTime,
    String? midnightTime,
    bool? enableSound,
    bool? enableVibration,
    int? notificationChannel,
  }) {
    return NotificationSettingsModel(
      isEnabled: isEnabled ?? this.isEnabled,
      notifyMorning: notifyMorning ?? this.notifyMorning,
      notifyEvening: notifyEvening ?? this.notifyEvening,
      notifyMidnight: notifyMidnight ?? this.notifyMidnight,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
      midnightTime: midnightTime ?? this.midnightTime,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      notificationChannel: notificationChannel ?? this.notificationChannel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'notifyMorning': notifyMorning,
      'notifyEvening': notifyEvening,
      'notifyMidnight': notifyMidnight,
      'morningTime': morningTime,
      'eveningTime': eveningTime,
      'midnightTime': midnightTime,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'notificationChannel': notificationChannel,
    };
  }

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      isEnabled: map['isEnabled'] as bool? ?? false,
      notifyMorning: map['notifyMorning'] as bool? ?? true,
      notifyEvening: map['notifyEvening'] as bool? ?? true,
      notifyMidnight: map['notifyMidnight'] as bool? ?? false,
      morningTime: map['morningTime'] as String? ?? '07:00',
      eveningTime: map['eveningTime'] as String? ?? '18:00',
      midnightTime: map['midnightTime'] as String? ?? '00:00',
      enableSound: map['enableSound'] as bool? ?? true,
      enableVibration: map['enableVibration'] as bool? ?? true,
      notificationChannel: map['notificationChannel'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [
    isEnabled,
    notifyMorning,
    notifyEvening,
    notifyMidnight,
    morningTime,
    eveningTime,
    midnightTime,
    enableSound,
    enableVibration,
    notificationChannel,
  ];
}
