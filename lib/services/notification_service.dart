import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  /// 獲取設備唯一的 FCM Token
  static Future<String?> getFcmToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      return token;
    } catch (e) {
      debugPrint('獲取 FCM Token 失敗: $e');
      return null;
    }
  }

  /// 初始化前景訊息監聽
  static void initializeForegroundListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('收到 FCM 前景訊息: ${message.notification?.title}');
      debugPrint('訊息內容: ${message.notification?.body}');
      debugPrint('數據載荷: ${message.data}');
    });
  }
}
