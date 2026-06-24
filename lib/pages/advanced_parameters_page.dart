import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/viewmodels/advanced_settings_viewmodel.dart';
import 'package:walkgo/l10n/app_localizations.dart';

class AdvancedParametersPage extends StatefulWidget {
  const AdvancedParametersPage({super.key});

  @override
  State<AdvancedParametersPage> createState() => _AdvancedParametersPageState();
}

class _AdvancedParametersPageState extends State<AdvancedParametersPage> {
  late final TextEditingController _offsetStepsController;
  late final TextEditingController _autoPauseThresholdController;
  late final FocusNode _offsetStepsFocusNode;
  late final FocusNode _autoPauseThresholdFocusNode;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<AdvancedSettingsViewModel>(
      context,
      listen: false,
    );

    _offsetStepsController = TextEditingController(text: viewModel.offsetSteps);
    _autoPauseThresholdController = TextEditingController(
      text: viewModel.autoPauseThreshold,
    );

    _offsetStepsFocusNode = FocusNode();
    _autoPauseThresholdFocusNode = FocusNode();

    _offsetStepsFocusNode.addListener(() {
      if (!_offsetStepsFocusNode.hasFocus) {
        viewModel.saveOffsetSteps(_offsetStepsController.text);
      }
    });

    _autoPauseThresholdFocusNode.addListener(() {
      if (!_autoPauseThresholdFocusNode.hasFocus) {
        viewModel.saveAutoPauseThreshold(_autoPauseThresholdController.text);
      }
    });
  }

  @override
  void dispose() {
    _offsetStepsController.dispose();
    _autoPauseThresholdController.dispose();
    _offsetStepsFocusNode.dispose();
    _autoPauseThresholdFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.advanced_parameters)),
      body: SafeArea(
        child: Consumer<AdvancedSettingsViewModel>(
          builder: (context, viewModel, child) {
            final isLocked = viewModel.isAutoModeRunning;

            return AbsorbPointer(
              absorbing: isLocked,
              child: Opacity(
                opacity: isLocked ? 0.5 : 1.0,
                child: Column(
                  children: [
                    if (isLocked)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        color: theme.colorScheme.errorContainer,
                        width: double.infinity,
                        child: Text(
                          l10n.auto_mode_running_lock_warning,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 16.0,
                          ),
                          children: [
                            _buildSettingsCard(
                              context,
                              title: l10n.offset_settings_title,
                              subtitle: l10n.offset_settings_subtitle,
                              trailing: Switch(
                                value: viewModel.offsetEnabled,
                                onChanged: isLocked
                                    ? null
                                    : (bool value) {
                                        viewModel.setOffsetEnabled(value);
                                      },
                              ),
                              child: Visibility(
                                visible: viewModel.offsetEnabled,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  child: _buildTextField(
                                    key: const ValueKey('offset_steps_textfield'),
                                    enabled: !isLocked,
                                    controller: _offsetStepsController,
                                    focusNode: _offsetStepsFocusNode,
                                    label: l10n.offset_steps,
                                    hint: l10n.offset_steps_hint,
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
                                onChanged: isLocked
                                    ? null
                                    : (bool value) {
                                        viewModel.setAutoPauseEnabled(value);
                                      },
                              ),
                              child: Visibility(
                                visible: viewModel.autoPauseEnabled,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  child: _buildTextField(
                                    key: const ValueKey('auto_pause_textfield'),
                                    enabled: !isLocked,
                                    controller: _autoPauseThresholdController,
                                    focusNode: _autoPauseThresholdFocusNode,
                                    label: l10n.auto_pause_threshold,
                                    hint: l10n.auto_pause_threshold_hint,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
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
    Key? key, // Accept an optional key
    required TextEditingController controller,
    required String label,
    required String hint,
    FocusNode? focusNode,
    bool enabled = true,
  }) {
    return TextFormField(
      key: key, // Pass the key to the TextFormField
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
      ),
    );
  }
}
