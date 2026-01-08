
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int _statusNotificationId = 0;
  static const int _confirmationNotificationId = 1;

  // Notification Channel IDs
  static const String _persistentChannelId = 'walkgo_persistent_notification';
  static const String _confirmationChannelId = 'walkgo_confirmation_notification';

  Future<void> init() async {
    // Correctly reference the launcher icon from the mipmap directory.
    // This is the standard Android path for the app icon.
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

  /// Shows or updates the persistent status notification.
  /// This notification is not dismissible and has low priority.
  Future<void> showOrUpdateStatusNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _persistentChannelId,
      'WalkGo Service Status', // Channel Name
      channelDescription: 'Notification channel for the background service status.',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // Makes the notification persistent
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

  /// Shows a one-time confirmation notification for a successful step write.
  /// This notification is dismissible.
  Future<void> showWriteConfirmationNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _confirmationChannelId,
      'WalkGo Step Confirmation', // Channel Name
      channelDescription: 'Notification channel for step write confirmations.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      autoCancel: true, // Automatically cancels the notification when tapped
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
