import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> hasAllPermissions() async {
    final activityStatus = await Permission.activityRecognition.status;
    final notificationStatus = await Permission.notification.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    return activityStatus.isGranted &&
        notificationStatus.isGranted &&
        batteryStatus.isGranted;
  }

  Future<void> requestPermissions() async {
    await Permission.activityRecognition.request();
    await Permission.notification.request();
    await Permission.ignoreBatteryOptimizations.request();
  }
}
