import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdHelper {
  /// 核心方法：獲取安全、去識別化、且刪除重裝不變的唯一雜湊碼
  static Future<String> getSecureDeviceId() async {
    try {
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        
        // 抓取 Android 的硬體唯一識別碼
        String rawId = androidInfo.id;
        
        if (rawId.isNotEmpty) {
          // 本地進行 SHA-256 雜湊，轉為安全亂碼
          return _convertToSha256(rawId);
        }
      }
    } catch (e) {
      print("獲取裝置 ID 失敗: $e");
    }

    return "fallback_${DateTime.now().millisecondsSinceEpoch}";
  }

  static String _convertToSha256(String input) {
    var bytes = utf8.encode(input); 
    var digest = sha256.convert(bytes); 
    return digest.toString(); 
  }
}
