import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/main.dart';
import 'l10n/app_localizations.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadLanguageSetting();
  }

  Future<void> _loadLanguageSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('languageCode');
      });
    }
  }

  void _onLanguageChanged(String? newLanguageCode) async {
    setState(() {
      _selectedLanguage = newLanguageCode;
    });

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final myAppState = MyApp.of(context);

    if (newLanguageCode == null || newLanguageCode.isEmpty) {
      await prefs.remove('languageCode');
      myAppState?.setLocale(null);
    } else {
      await prefs.setString('languageCode', newLanguageCode);
      myAppState?.setLocale(Locale(newLanguageCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language_settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionCard(
            context,
            children: [
              _buildLanguageOption(l10n.systemDefault, null),
              _buildLanguageOption(l10n.chinese, 'zh'),
              _buildLanguageOption(l10n.english, 'en'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String title, String? value) {
    return RadioListTile<String?>(
      title: Text(title),
      value: value,
      groupValue: _selectedLanguage,
      onChanged: _onLanguageChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSectionCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
