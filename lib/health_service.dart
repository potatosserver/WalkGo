import 'package:health/health.dart';
import 'package:walkgo/log_service.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  Future<int> getStepsToday() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    try {
      final steps = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.STEPS],
      );
      if (steps.isEmpty) {
        return 0;
      }
      return steps.fold<int>(0, (sum, data) => sum + (data.value as num).toInt());
    } catch (e) {
      LogService().addLog({
        'event': '[HealthService] Error fetching steps today',
        'error': e.toString()
      });
      return 0;
    }
  }

  Future<bool> writeSteps(int steps) async {
    final endTime = DateTime.now();
    final startTime = endTime.subtract(const Duration(minutes: 1));
    try {
      final success = await _health.writeHealthData(
        value: steps.toDouble(),
        type: HealthDataType.STEPS,
        startTime: startTime,
        endTime: endTime,
      );
      return success;
    } catch (e) {
      LogService().addLog({
        'event': '[HealthService] Error writing steps',
        'error': e.toString()
      });
      return false;
    }
  }

  Future<bool> requestAuthorization() async {
    final types = [HealthDataType.STEPS];
    return await _health.requestAuthorization(types);
  }
}
