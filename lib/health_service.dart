import 'package:health/health.dart';
import 'package:walkgo/log_service.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

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
      LogService().addLog({'event': '[HealthService] Error writing steps', 'error': e.toString()});
      return false;
    }
  }

  Future<bool> requestAuthorization() async {
    final types = [HealthDataType.STEPS];
    return await _health.requestAuthorization(types);
  }
}
