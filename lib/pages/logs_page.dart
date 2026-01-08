import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final LogService _logService = LogService();
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _logService.getLogs();
    setState(() {
      _logs = logs;
    });
  }

  Future<void> _clearLogs() async {
    await _logService.clearLogs();
    if (mounted) {
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.logs_cleared);
    }
    _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.write_logs),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _clearLogs,
            tooltip: l10n.clear_all_logs,
          ),
        ],
      ),
      body: _logs.isEmpty
          ? Center(child: Text(l10n.no_logs))
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isManual = log['type'] == 'manual';

                // Safely extract step details
                final originalSteps = log['originalSteps'] ?? 0;
                final stepsAdded = log['stepsAdded'] ?? 0;
                final totalSteps = log['totalStepsWritten'] ?? 0;

                return ListTile(
                  leading: Icon(isManual
                      ? Icons.touch_app_outlined
                      : Icons.sync_alt_outlined),
                  title: Text(
                    '${l10n.automatic_write_success(totalSteps.toString())} (+$stepsAdded)',
                  ),
                  subtitle: Text(
                      'Original: $originalSteps | ${log['timestamp'] ?? ''}'),
                  trailing: Text(isManual
                      ? l10n.log_type_manual
                      : l10n.log_type_automatic),
                );
              },
            ),
    );
  }
}
