import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdHelper {
  /// 獲取裝置的安全 ID 與型號資訊
  static Future<Map<String, String>> getDeviceInfo() async {
    String secureId = "fallback_${DateTime.now().millisecondsSinceEpoch}";
    String model = "Unknown Device";

    try {
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        
        // 1. 處理安全 ID
        String rawId = androidInfo.id;
        if (rawId.isNotEmpty) {
          secureId = _convertToSha256(rawId);
        }
        
        // 2. 處理裝置型號 (品牌 + 型號)
        model = "${androidInfo.brand} ${androidInfo.model}";
      }
    } catch (e) {
      print("獲取裝置資訊失敗: $e");
    }

    return {
      'id': secureId,
      'model': model,
    };
  }

  /// 為了保持向下相容，保留此方法但內部呼叫 getDeviceInfo
  static Future<String> getSecureDeviceId() async {
    final info = await getDeviceInfo();
    return info['id']!;
  }

  static String _convertToSha256(String input) {
    var bytes = utf8.encode(input); 
    var digest = sha256.convert(bytes); 
    return digest.toString(); 
  }
}
