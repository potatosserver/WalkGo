import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @walkgo.
  ///
  /// In en, this message translates to:
  /// **'WalkGo'**
  String get walkgo;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system_theme.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get system_theme;

  /// No description provided for @light_theme.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get light_theme;

  /// No description provided for @dark_theme.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_theme;

  /// No description provided for @language_settings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_settings;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @simplified_chinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get simplified_chinese;

  /// No description provided for @traditional_chinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get traditional_chinese;

  /// No description provided for @logs_cleared.
  ///
  /// In en, this message translates to:
  /// **'Logs cleared.'**
  String get logs_cleared;

  /// No description provided for @about_walkgo.
  ///
  /// In en, this message translates to:
  /// **'About WalkGo'**
  String get about_walkgo;

  /// No description provided for @about_walkgo_content.
  ///
  /// In en, this message translates to:
  /// **'This app helps you automatically log your steps to meet your health goals.\n\nVersion: 1.0.0'**
  String get about_walkgo_content;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @write_logs.
  ///
  /// In en, this message translates to:
  /// **'Write Logs'**
  String get write_logs;

  /// No description provided for @clear_all_logs.
  ///
  /// In en, this message translates to:
  /// **'Clear All Logs'**
  String get clear_all_logs;

  /// No description provided for @no_logs.
  ///
  /// In en, this message translates to:
  /// **'No logs yet.'**
  String get no_logs;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @rerun_setup.
  ///
  /// In en, this message translates to:
  /// **'Rerun Welcome & Setup'**
  String get rerun_setup;

  /// No description provided for @rerun_setup_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get rerun_setup_confirm_title;

  /// No description provided for @rerun_setup_confirm_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to rerun the setup? This will take you to the welcome screen and require re-granting permissions.'**
  String get rerun_setup_confirm_content;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @welcome_to_walkgo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to WalkGo'**
  String get welcome_to_walkgo;

  /// No description provided for @welcome_message.
  ///
  /// In en, this message translates to:
  /// **'This app helps you automatically write your steps to your health data, so you can easily meet your daily goals.'**
  String get welcome_message;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @permission_health_title.
  ///
  /// In en, this message translates to:
  /// **'Health Data Access'**
  String get permission_health_title;

  /// No description provided for @permission_health_desc.
  ///
  /// In en, this message translates to:
  /// **'WalkGo needs access to your health data to read and write steps. This is the core function of the app.'**
  String get permission_health_desc;

  /// No description provided for @permission_activity_title.
  ///
  /// In en, this message translates to:
  /// **'Physical Activity Permission'**
  String get permission_activity_title;

  /// No description provided for @permission_activity_desc.
  ///
  /// In en, this message translates to:
  /// **'On some Android versions, this allows the app to run more accurately in the background to detect your activity.'**
  String get permission_activity_desc;

  /// No description provided for @permission_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get permission_notification_title;

  /// No description provided for @permission_notification_desc.
  ///
  /// In en, this message translates to:
  /// **'We need to show a notification to keep the background service running and to inform you when steps are successfully written.'**
  String get permission_notification_desc;

  /// No description provided for @permission_battery_title.
  ///
  /// In en, this message translates to:
  /// **'Disable Battery Optimization'**
  String get permission_battery_title;

  /// No description provided for @permission_battery_desc.
  ///
  /// In en, this message translates to:
  /// **'To ensure the app can run reliably in the background without being killed, please disable battery optimization for WalkGo.'**
  String get permission_battery_desc;

  /// No description provided for @grant_permission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grant_permission;

  /// No description provided for @next_step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next_step;

  /// No description provided for @setup_complete.
  ///
  /// In en, this message translates to:
  /// **'Setup Complete'**
  String get setup_complete;

  /// No description provided for @param_settings.
  ///
  /// In en, this message translates to:
  /// **'Parameter Settings'**
  String get param_settings;

  /// No description provided for @base_steps.
  ///
  /// In en, this message translates to:
  /// **'Base Steps'**
  String get base_steps;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval (minutes)'**
  String get interval;

  /// No description provided for @advanced_settings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advanced_settings;

  /// No description provided for @manual_write_once.
  ///
  /// In en, this message translates to:
  /// **'Manual Write Once'**
  String get manual_write_once;

  /// No description provided for @start_auto_steps.
  ///
  /// In en, this message translates to:
  /// **'Start Auto Service'**
  String get start_auto_steps;

  /// No description provided for @stop_auto_steps.
  ///
  /// In en, this message translates to:
  /// **'Stop Auto Service'**
  String get stop_auto_steps;

  /// No description provided for @status_running.
  ///
  /// In en, this message translates to:
  /// **'Service is running...'**
  String get status_running;

  /// No description provided for @status_ready_to_start.
  ///
  /// In en, this message translates to:
  /// **'Service is ready to start.'**
  String get status_ready_to_start;

  /// No description provided for @steps_gt_zero.
  ///
  /// In en, this message translates to:
  /// **'Steps must be greater than 0.'**
  String get steps_gt_zero;

  /// No description provided for @manual_write_success.
  ///
  /// In en, this message translates to:
  /// **'Successfully wrote {steps} steps.'**
  String manual_write_success(Object steps);

  /// No description provided for @write_fail_check_log.
  ///
  /// In en, this message translates to:
  /// **'Failed to write steps. Please check your health app or system settings.'**
  String get write_fail_check_log;

  /// No description provided for @write_error.
  ///
  /// In en, this message translates to:
  /// **'Error writing steps: {error}'**
  String write_error(Object error);

  /// No description provided for @background_service_start.
  ///
  /// In en, this message translates to:
  /// **'Background service started.'**
  String get background_service_start;

  /// No description provided for @background_service_stop.
  ///
  /// In en, this message translates to:
  /// **'Background service stopped.'**
  String get background_service_stop;

  /// No description provided for @notification_update_title.
  ///
  /// In en, this message translates to:
  /// **'Steps Update'**
  String get notification_update_title;

  /// No description provided for @automatic_write_success.
  ///
  /// In en, this message translates to:
  /// **'Successfully wrote {steps} steps.'**
  String automatic_write_success(Object steps);

  /// No description provided for @clear_data_button.
  ///
  /// In en, this message translates to:
  /// **'Clear All App Data'**
  String get clear_data_button;

  /// No description provided for @clear_data_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get clear_data_confirm_title;

  /// No description provided for @clear_data_confirm_content.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all app data, including your settings and logs. This action cannot be undone.'**
  String get clear_data_confirm_content;

  /// No description provided for @data_cleared_success.
  ///
  /// In en, this message translates to:
  /// **'App data cleared successfully.'**
  String get data_cleared_success;

  /// No description provided for @app_will_restart.
  ///
  /// In en, this message translates to:
  /// **'The app will now restart.'**
  String get app_will_restart;

  /// No description provided for @auto_pause_title.
  ///
  /// In en, this message translates to:
  /// **'Auto-Pause Service'**
  String get auto_pause_title;

  /// No description provided for @auto_pause_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically stop the service when a certain number of steps have been written.'**
  String get auto_pause_subtitle;

  /// No description provided for @auto_pause_steps_label.
  ///
  /// In en, this message translates to:
  /// **'Auto-Pause Step Threshold'**
  String get auto_pause_steps_label;

  /// No description provided for @auto_pause_steps_hint.
  ///
  /// In en, this message translates to:
  /// **'Service will stop after this many steps are written in one session.'**
  String get auto_pause_steps_hint;

  /// No description provided for @offset_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Randomize Steps'**
  String get offset_settings_title;

  /// No description provided for @offset_settings_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable random offset for steps'**
  String get offset_settings_subtitle;

  /// No description provided for @app_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get app_reset;

  /// No description provided for @app_reset_desc.
  ///
  /// In en, this message translates to:
  /// **'This action will clear all app data and settings, restoring the app to its initial state.'**
  String get app_reset_desc;

  /// No description provided for @offset_steps_hint.
  ///
  /// In en, this message translates to:
  /// **'Steps will be randomized within a plus/minus range of this value.'**
  String get offset_steps_hint;

  /// No description provided for @permission_denied_title.
  ///
  /// In en, this message translates to:
  /// **'Permission Permanently Denied'**
  String get permission_denied_title;

  /// No description provided for @permission_denied_content.
  ///
  /// In en, this message translates to:
  /// **'You have permanently denied a required permission. Please go to your device\'s settings page for this app and manually grant the permission to ensure it functions correctly.'**
  String get permission_denied_content;

  /// No description provided for @open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get open_settings;

  /// No description provided for @auto_pause_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Service Paused Automatically'**
  String get auto_pause_notification_title;

  /// No description provided for @auto_pause_notification_content.
  ///
  /// In en, this message translates to:
  /// **'The step writing service has been paused automatically as the session goal was reached.'**
  String get auto_pause_notification_content;

  /// No description provided for @settings_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get settings_tooltip;

  /// No description provided for @log_type_manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get log_type_manual;

  /// No description provided for @log_type_automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get log_type_automatic;

  /// No description provided for @start_service_fail.
  ///
  /// In en, this message translates to:
  /// **'Failed to start service, please try again.'**
  String get start_service_fail;

  /// No description provided for @stop_service_fail.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop service, please try again.'**
  String get stop_service_fail;

  /// No description provided for @status_stopped.
  ///
  /// In en, this message translates to:
  /// **'Service is stopped.'**
  String get status_stopped;

  /// No description provided for @next_run_pending.
  ///
  /// In en, this message translates to:
  /// **'Next run is pending.'**
  String get next_run_pending;

  /// No description provided for @next_run_at.
  ///
  /// In en, this message translates to:
  /// **'Next run at {time}'**
  String next_run_at(Object time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
