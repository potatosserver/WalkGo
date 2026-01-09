import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Use context.watch<LogService>() to make the widget listen to changes.
    // The FutureBuilder will re-run whenever LogService notifies its listeners.
    final logService = context.watch<LogService>();

    Future<void> clearLogs() async {
      // Use context.read inside a callback
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
      // FutureBuilder rebuilds when the future (getLogs) is re-fetched.
      // By watching the logService, any change will trigger a rebuild of this widget,
      // which in turn re-triggers the FutureBuilder.
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: logService.getLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final logs = snapshot.data;

          if (logs == null || logs.isEmpty) {
            return Center(child: Text(l10n.no_logs));
          }

          return ListView.builder(
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
          );
        },
      ),
    );
  }
}
