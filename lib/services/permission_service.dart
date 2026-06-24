import 'package:permission_handler/permission_handler.dart';
import 'preference_service.dart';

class PermissionService {
  Future<bool> hasAllPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    
    // If user chose to skip, we consider the "permission flow" completed for those items
    final skipNotification = await PreferenceService().getSkipNotification();
    final skipBattery = await PreferenceService().getSkipBattery();

    return (notificationStatus.isGranted || skipNotification) &&
        (batteryStatus.isGranted || skipBattery);
  }

  Future<void> requestPermissions() async {
    final skipNotification = await PreferenceService().getSkipNotification();
    final skipBattery = await PreferenceService().getSkipBattery();

    if (!skipNotification) {
      await Permission.notification.request();
    }
    
    if (!skipBattery) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }
}
