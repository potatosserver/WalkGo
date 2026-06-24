import 'package:permission_handler/permission_handler.dart';
import 'preference_service.dart';

class PermissionService {
  Future<bool> hasAllPermissions() async {
    final prefs = PreferenceService();

    // Check actual permission status from the OS
    final notificationStatus = await Permission.notification.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    // Check user's preference to skip the permission prompts
    final skipNotification = await prefs.getSkipNotification();
    final skipBattery = await prefs.getSkipBattery();

    // A permission is considered "handled" if it's either granted by the user
    // OR the user has explicitly chosen to skip the prompt for it.
    final notificationHandled =
        notificationStatus.isGranted || skipNotification;
    final batteryHandled = batteryStatus.isGranted || skipBattery;

    // If a user previously granted a permission, but then revoked it in the settings,
    // we should clear the 'skip' flag so they are prompted again.
    if (!notificationStatus.isGranted && !skipNotification) {
      // This case is handled by the permission page itself, but good to be explicit.
    }
    if (!batteryStatus.isGranted && !skipBattery) {
      // This case is handled by the permission page itself.
    }

    return notificationHandled && batteryHandled;
  }

  Future<void> requestPermissions() async {
    final prefs = PreferenceService();
    final skipNotification = await prefs.getSkipNotification();
    final skipBattery = await prefs.getSkipBattery();

    if (!skipNotification) {
      await Permission.notification.request();
    }

    if (!skipBattery) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }
}
