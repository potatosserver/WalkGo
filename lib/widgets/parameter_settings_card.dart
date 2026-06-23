import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkgo/l10n/app_localizations.dart';
import 'package:walkgo/viewmodels/home_page_viewmodel.dart';
import 'package:walkgo/pages/advanced_parameters_page.dart';

class ParameterSettingsCard extends StatefulWidget {
  const ParameterSettingsCard({super.key});

  @override
  State<ParameterSettingsCard> createState() => _ParameterSettingsCardState();
}

class _ParameterSettingsCardState extends State<ParameterSettingsCard> {
  late TextEditingController _baseStepsController;
  late TextEditingController _intervalController;
  HomePageViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _baseStepsController = TextEditingController();
    _intervalController = TextEditingController();
  }

  @override
  void dispose() {
    _baseStepsController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = Provider.of<HomePageViewModel>(context);
    if (_viewModel != viewModel) {
      _viewModel = viewModel;
      // Initialize or update controllers when the ViewModel is first available/changed
      _updateControllers();
    }
  }

  void _updateControllers() {
    if (_viewModel == null) return;

    // Only update if the text is different to avoid cursor jumping
    if (_baseStepsController.text != _viewModel!.baseSteps) {
      _baseStepsController.text = _viewModel!.baseSteps;
    }
    if (_intervalController.text != _viewModel!.interval) {
      _intervalController.text = _viewModel!.interval;
    }
  }

  @override
  Widget build(BuildContext context) {
    // We still want to listen to changes, but we manage the controllers manually.
    final viewModel = Provider.of<HomePageViewModel>(context);
    _viewModel = viewModel;
    _updateControllers();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bool isEnabled = !viewModel.isAutoRunning;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.param_settings,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _baseStepsController,
              label: l10n.base_steps,
              icon: Icons.filter_1,
              onChanged: (value) => viewModel.saveBaseSteps(value),
              enabled: isEnabled,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _intervalController,
              label: l10n.interval,
              icon: Icons.timer_outlined,
              onChanged: (value) => viewModel.saveInterval(value),
              enabled: isEnabled,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                label: Text(l10n.advanced_parameters),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withAlpha(26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdvancedParametersPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
      ),
      onChanged: onChanged,
    );
  }
}
