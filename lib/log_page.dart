import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Watch the LogService for changes. When notifyListeners() is called,
    // this widget will rebuild.
    final logService = context.watch<LogService>();
    
    // Get the logs directly from the service's in-memory list.
    final logs = logService.logs;

    Future<void> clearLogs() async {
      // Use context.read inside a callback to perform an action.
      await context.read<LogService>().clearLogs();
      if (context.mounted) {
        Fluttertoast.showToast(msg: l10n.logs_cleared);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.write_logs),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: clearLogs,
            tooltip: l10n.clear_all_logs,
          ),
        ],
      ),
      body: logs.isEmpty
          ? Center(child: Text(l10n.no_logs))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];

                final steps = log['steps'] ?? 0;
                final timestamp = log['timestamp'] ?? '';
                final source = log['source'] as String?;

                String title;
                if (source == 'automatic') {
                  title = l10n.log_write_success_auto(steps.toString());
                } else {
                  title = l10n.log_write_success_manual(steps.toString());
                }

                return ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(title),
                  subtitle: Text(timestamp),
                );
              },
            ),
    );
  }
}
