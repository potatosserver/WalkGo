import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/log_service.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final logService = context.watch<LogService>();
    final logs = logService.logs;

    Future<void> clearLogs() async {
      await context.read<LogService>().clearLogs();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.clear_all_logs),
            content: Text(l10n.logs_cleared),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          ),
        );
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
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final steps = log['steps'] ?? 0;
                final timestamp = log['timestamp'] ?? '';
                final source = log['source'] as String?;

                IconData iconData;
                Color iconColor;
                String title;

                if (source == 'automatic') {
                  iconData = Icons.auto_awesome;
                  iconColor = Colors.blue.shade600;
                  title = l10n.log_write_success_auto(steps.toString());
                } else {
                  iconData = Icons.edit;
                  iconColor = Colors.orange.shade600;
                  title = l10n.log_write_success_manual(steps.toString());
                }

                final formattedTimestamp = DateFormat(
                  'yyyy-MM-dd HH:mm',
                ).format(DateTime.parse(timestamp));

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Icon(iconData, color: iconColor, size: 36),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      formattedTimestamp,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
