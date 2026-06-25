import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walkgo/services/debug_log_service.dart';

class DebugLogPage extends StatelessWidget {
  const DebugLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Logs',
            onPressed: () => DebugLogService().clear(),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Logs',
            onPressed: () async {
              final allLogs = DebugLogService().allLogs.join('\n');
              await Clipboard.setData(ClipboardData(text: allLogs));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logs copied to clipboard')),
                );
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: DebugLogService().logsNotifier,
        builder: (context, logs, child) {
          if (logs.isEmpty) {
            return const Center(child: Text('No logs available yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  logs[index],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
