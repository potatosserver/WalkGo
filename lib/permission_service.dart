
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> hasAllPermissions() async {
    final activityStatus = await Permission.activityRecognition.status;
    final notificationStatus = await Permission.notification.status;
    return activityStatus.isGranted && notificationStatus.isGranted;
  }
}
