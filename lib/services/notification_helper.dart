
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:walkgo/constants.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int _statusNotificationId = foregroundNotificationId; // Use the constant
  static const int _confirmationNotificationId = 1;

  // Notification Channel IDs
  static const String _confirmationChannelId = 'walkgo_confirmation_notification';

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showOrUpdateStatusNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      foregroundChannelId, // CORRECTED: Use the consistent channel ID from constants.dart
      foregroundChannelName, 
      channelDescription: foregroundChannelDescription,
      importance: Importance.defaultImportance, 
      priority: Priority.defaultPriority,
      ongoing: true, 
      autoCancel: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      _statusNotificationId,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> showWriteConfirmationNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _confirmationChannelId,
      'WalkGo Step Confirmation', 
      channelDescription: 'Notification channel for step write confirmations.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      autoCancel: true, 
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      _confirmationNotificationId,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
