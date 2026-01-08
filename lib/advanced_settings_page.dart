import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

const String prefOffsetEnabled = "offset_enabled";
const String prefOffset = "offset_steps";
const String prefAutoPauseEnabled = "auto_pause_enabled";
const String prefAutoPauseSteps = "auto_pause_steps";

class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  bool _offsetEnabled = true;
  bool _autoPauseEnabled = false;
  final TextEditingController _offsetController = TextEditingController();
  final TextEditingController _autoPauseStepsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _offsetEnabled = prefs.getBool(prefOffsetEnabled) ?? true;
      _offsetController.text = (prefs.getInt(prefOffset) ?? 50).toString();
      _autoPauseEnabled = prefs.getBool(prefAutoPauseEnabled) ?? false;
      _autoPauseStepsController.text =
          (prefs.getInt(prefAutoPauseSteps) ?? 50000).toString();
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefOffsetEnabled, _offsetEnabled);
    await prefs.setInt(prefOffset, int.tryParse(_offsetController.text) ?? 50);
    await prefs.setBool(prefAutoPauseEnabled, _autoPauseEnabled);
    await prefs.setInt(prefAutoPauseSteps,
        int.tryParse(_autoPauseStepsController.text) ?? 50000);

    // Notify the background service to update its settings
    FlutterBackgroundService().invoke('update');
  }

  @override
  void dispose() {
    _offsetController.dispose();
    _autoPauseStepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.advanced_settings),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          children: [
            _buildSettingsCard(
              context: context,
              title: l10n.offset_settings_title,
              value: _offsetEnabled,
              onChanged: (bool value) {
                setState(() {
                  _offsetEnabled = value;
                });
                _saveSettings();
              },
              child: _buildTextField(
                controller: _offsetController,
                label: l10n.offset_steps_hint,
                enabled: _offsetEnabled,
              ),
            ),
            _buildSettingsCard(
              context: context,
              title: l10n.auto_pause_title,
              value: _autoPauseEnabled,
              onChanged: (bool value) {
                setState(() {
                  _autoPauseEnabled = value;
                });
                _saveSettings();
              },
              child: _buildTextField(
                controller: _autoPauseStepsController,
                label: l10n.auto_pause_steps_hint,
                enabled: _autoPauseEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(title, style: theme.textTheme.titleMedium),
              trailing: Switch(value: value, onChanged: onChanged),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: Theme.of(context).colorScheme.onSurface.withAlpha(12),
      ),
      onChanged: (_) => _saveSettings(),
    );
  }
}
