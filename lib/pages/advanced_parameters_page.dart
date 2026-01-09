import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/viewmodels/advanced_settings_viewmodel.dart';
import 'package:walkgo/l10n/app_localizations.dart';

// The page is now a StatefulWidget to manage the controllers.
class AdvancedParametersPage extends StatefulWidget {
  const AdvancedParametersPage({super.key});

  @override
  State<AdvancedParametersPage> createState() => _AdvancedParametersPageState();
}

class _AdvancedParametersPageState extends State<AdvancedParametersPage> {
  // Controllers for the text fields.
  late final TextEditingController _offsetStepsController;
  late final TextEditingController _autoPauseThresholdController;

  @override
  void initState() {
    super.initState();
    // Get the ViewModel without listening, as the Consumer will handle updates.
    final viewModel = Provider.of<AdvancedSettingsViewModel>(context, listen: false);

    // Initialize controllers with values from the ViewModel.
    _offsetStepsController = TextEditingController(text: viewModel.offsetSteps);
    _autoPauseThresholdController = TextEditingController(text: viewModel.autoPauseThreshold);
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources.
    _offsetStepsController.dispose();
    _autoPauseThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Use a Consumer to listen for changes in the ViewModel and rebuild the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.advanced_parameters),
      ),
      body: Consumer<AdvancedSettingsViewModel>(
        builder: (context, viewModel, child) {
          // Update controllers if the viewmodel's data has changed from an external source.
          // This check prevents cursor jumping.
          if (_offsetStepsController.text != viewModel.offsetSteps) {
            _offsetStepsController.text = viewModel.offsetSteps;
          }
          if (_autoPauseThresholdController.text != viewModel.autoPauseThreshold) {
            _autoPauseThresholdController.text = viewModel.autoPauseThreshold;
          }

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
                    // Use the controller instead of initialValue.
                    child: _buildTextField(
                      controller: _offsetStepsController,
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
                    // Use the controller instead of initialValue.
                    child: _buildTextField(
                      controller: _autoPauseThresholdController,
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

  // Modified helper method to accept a controller.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
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