import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
    if (mounted) {
      setState(() {
        _logs = logs;
      });
    }
  }

  Future<void> _clearLogs() async {
    await _logService.clearLogs();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.logs_cleared)));
    _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    final systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLightMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.colorScheme.surface, // Changed from black
      systemNavigationBarIconBrightness:
          isLightMode ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(l10n.write_logs),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              onPressed: _logs.isEmpty ? null : _clearLogs,
              tooltip: l10n.clear_all_logs,
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        l10n.no_logs,
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: kToolbarHeight, left: 8.0, right: 8.0, bottom: 8.0),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final int steps = log['steps'] as int? ?? 0;
                    final String type = log['type'] as String? ?? 'unknown';
                    final String timestampStr = log['timestamp'] as String? ?? DateTime.now().toIso8601String();
                    final DateTime timestamp = DateTime.parse(timestampStr).toLocal();

                    final String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
                    
                    final String typeText = type == 'manual'
                        ? l10n.log_type_manual
                        : l10n.log_type_automatic;
                    
                    final IconData iconData = type == 'manual'
                        ? Icons.touch_app_outlined
                        : Icons.sync;

                    return Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(iconData, color: theme.colorScheme.primary, size: 30),
                        title: Text(
                          '$steps', 
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary
                          ),
                        ),
                        subtitle: Text(
                          typeText,
                          style: theme.textTheme.bodyMedium,
                        ),
                        trailing: Text(
                          formattedTime,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
