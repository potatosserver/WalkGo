import 'package:flutter/material.dart';
import 'package:walkgo/log_service.dart';
import 'l10n/app_localizations.dart';

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
                return ListTile(
                  leading: Icon(isManual
                      ? Icons.touch_app_outlined
                      : Icons.sync_alt_outlined),
                  title: Text(
                    isManual
                        ? l10n.manual_write_success(log['steps'] ?? 0)
                        : l10n.automatic_write_success(log['steps'] ?? 0),
                  ),
                  subtitle: Text(log['timestamp'] ?? ''),
                  trailing: Text(isManual
                      ? l10n.log_type_manual
                      : l10n.log_type_automatic),
                );
              },
            ),
    );
  }
}
