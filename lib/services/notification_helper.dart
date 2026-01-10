import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:walkgo/constants.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const int _statusNotificationId = foregroundNotificationId;
  static const int _confirmationNotificationId = 1;
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
      foregroundChannelId, 
      foregroundChannelName, 
      channelDescription: foregroundChannelDescription,
      importance: Importance.high, 
      priority: Priority.high,
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
      importance: Importance.high,
      priority: Priority.high,
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
