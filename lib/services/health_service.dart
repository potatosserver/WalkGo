import 'package:health/health.dart';
import 'package:walkgo/services/error_log_service.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  // The Health object is no longer initialized here to avoid issues with background isolates.
  // A new instance will be created within each method where it is needed.

  Future<int> getStepsToday() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    try {
      final health = Health();

      // Ensure we have read permissions. In some systems, write doesn't imply read.
      final bool hasPermission =
          await health.hasPermissions([HealthDataType.STEPS]) ?? false;
      if (!hasPermission) {
        final bool authorized = await health.requestAuthorization([
          HealthDataType.STEPS,
        ]);
        if (!authorized) {
          return 0;
        }
      }

      // Using getTotalStepsInInterval is more efficient and reliable for a summary
      final steps = await health.getTotalStepsInInterval(midnight, now);

      return steps ?? 0;
    } catch (e) {
      ErrorLogService().addErrorLog(
        '[HealthService] Error fetching steps today',
        e.toString(),
      );
      return 0;
    }
  }

  Future<bool> writeSteps(int steps) async {
    final endTime = DateTime.now();
    final startTime = endTime.subtract(const Duration(minutes: 1));
    try {
      // A new Health instance is created on each call.
      final health = Health();
      final success = await health.writeHealthData(
        value: steps.toDouble(),
        type: HealthDataType.STEPS,
        startTime: startTime,
        endTime: endTime,
      );
      return success;
    } catch (e) {
      ErrorLogService().addErrorLog(
        '[HealthService] Error writing steps',
        e.toString(),
      );
      return false;
    }
  }

  Future<bool> requestAuthorization() async {
    // A new Health instance is created on each call.
    final health = Health();
    final types = [HealthDataType.STEPS];
    // Note: It's crucial that this method is only called from the main UI thread.
    return await health.requestAuthorization(types);
  }
}
