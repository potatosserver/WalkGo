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

    viewModel.addListener(_syncControllers);
  }

  void _syncControllers() {
    final viewModel =
        Provider.of<AdvancedSettingsViewModel>(context, listen: false);
    if (_offsetStepsController.text != viewModel.offsetSteps) {
      _offsetStepsController.text = viewModel.offsetSteps;
    }
    if (_autoPauseThresholdController.text != viewModel.autoPauseThreshold) {
      _autoPauseThresholdController.text = viewModel.autoPauseThreshold;
    }
  }

  @override
  void dispose() {
    final viewModel =
        Provider.of<AdvancedSettingsViewModel>(context, listen: false);
    viewModel.removeListener(_syncControllers);
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
        // 使用 Selector 僅在 isAutoModeRunning 改變時更新最外層鎖定狀態
        child: Selector<AdvancedSettingsViewModel, bool>(
          selector: (_, vm) => vm.isAutoModeRunning,
          builder: (context, isLocked, child) {
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
                            _buildSettingItem(
                              context,
                              title: l10n.offset_settings_title,
                              subtitle: l10n.offset_settings_subtitle,
                              prefKey: 'offset',
                              controller: _offsetStepsController,
                              focusNode: _offsetStepsFocusNode,
                              label: l10n.offset_steps,
                              hint: l10n.offset_steps_hint,
                              isLocked: isLocked,
                            ),
                            _buildSettingItem(
                              context,
                              title: l10n.auto_pause_title,
                              subtitle: l10n.auto_pause_subtitle,
                              prefKey: 'autoPause',
                              controller: _autoPauseThresholdController,
                              focusNode: _autoPauseThresholdFocusNode,
                              label: l10n.auto_pause_threshold,
                              hint: l10n.auto_pause_threshold_hint,
                              isLocked: isLocked,
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

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String prefKey,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required bool isLocked,
  }) {
    return Consumer<AdvancedSettingsViewModel>(
      builder: (context, viewModel, child) {
        final bool isEnabled = prefKey == 'offset'
            ? viewModel.offsetEnabled
            : viewModel.autoPauseEnabled;

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isEnabled,
                      onChanged: isLocked
                          ? null
                          : (bool value) {
                              if (prefKey == 'offset') {
                                viewModel.setOffsetEnabled(value);
                              } else {
                                viewModel.setAutoPauseEnabled(value);
                              }
                            },
                    ),
                  ],
                ),
              ),
              // 使用 AnimatedSize 消除高度跳變造成的閃爍感
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: isEnabled
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _ParameterTextField(
                          controller: controller,
                          focusNode: focusNode,
                          label: label,
                          hint: hint,
                          enabled: !isLocked,
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 提取為獨立 Widget，避免在 build 中重複創建
class _ParameterTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final bool enabled;

  const _ParameterTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
