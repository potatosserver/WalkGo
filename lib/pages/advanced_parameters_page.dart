import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/viewmodels/advanced_settings_viewmodel.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class AdvancedParametersPage extends StatelessWidget {
  const AdvancedParametersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (context) => AdvancedSettingsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.advanced_parameters),
        ),
        body: Consumer<AdvancedSettingsViewModel>(
          builder: (context, viewModel, child) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              children: [
                _buildSettingsCard(
                  context,
                  title: l10n.offset_settings_title,
                  subtitle: l10n.offset_settings_subtitle,
                  trailing: Switch(
                    value: viewModel.offsetEnabled,
                    onChanged: (bool value) {
                      viewModel.setOffsetEnabled(value);
                    },
                  ),
                  child: Visibility(
                    visible: viewModel.offsetEnabled,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: _buildTextField(
                        initialValue: viewModel.offsetSteps,
                        label: l10n.offset_steps,
                        hint: l10n.offset_steps_hint,
                        onChanged: (value) {
                          viewModel.saveOffsetSteps(value);
                        },
                      ),
                    ),
                  ),
                ),
                _buildSettingsCard(
                  context,
                  title: l10n.auto_pause_title,
                  subtitle: l10n.auto_pause_subtitle,
                  trailing: Switch(
                    value: viewModel.autoPauseEnabled,
                    onChanged: (bool value) {
                      viewModel.setAutoPauseEnabled(value);
                    },
                  ),
                  child: Visibility(
                    visible: viewModel.autoPauseEnabled,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: _buildTextField(
                        initialValue: viewModel.autoPauseThreshold,
                        label: l10n.auto_pause_threshold,
                        hint: l10n.auto_pause_threshold_hint,
                        onChanged: (value) {
                          viewModel.saveAutoPauseThreshold(value);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required String title,
      String? subtitle,
      Widget? trailing,
      required Widget child}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: trailing,
                  ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
      ),
      onChanged: onChanged,
    );
  }
}
