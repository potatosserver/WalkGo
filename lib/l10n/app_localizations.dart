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
  /// **'WalkGO'**
  String get walkgo;

  /// No description provided for @settings_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_tooltip;

  /// No description provided for @status_card_title.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status_card_title;

  /// No description provided for @status_running.
  ///
  /// In en, this message translates to:
  /// **'Running...'**
  String get status_running;

  /// No description provided for @status_ready_to_start.
  ///
  /// In en, this message translates to:
  /// **'Ready to start'**
  String get status_ready_to_start;

  /// No description provided for @status_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get status_stopped;

  /// No description provided for @next_run_at.
  ///
  /// In en, this message translates to:
  /// **'Next run at {time}'**
  String next_run_at(String time);

  /// No description provided for @next_run_title.
  ///
  /// In en, this message translates to:
  /// **'Next run at'**
  String get next_run_title;

  /// No description provided for @next_run_pending.
  ///
  /// In en, this message translates to:
  /// **'Next run pending...'**
  String get next_run_pending;

  /// No description provided for @this_run.
  ///
  /// In en, this message translates to:
  /// **'This Run'**
  String get this_run;

  /// No description provided for @session_steps.
  ///
  /// In en, this message translates to:
  /// **'Session Steps'**
  String get session_steps;

  /// No description provided for @remaining_steps_today.
  ///
  /// In en, this message translates to:
  /// **'Remaining Steps Today'**
  String get remaining_steps_today;

  /// No description provided for @parameter_settings.
  ///
  /// In en, this message translates to:
  /// **'Parameter Settings'**
  String get parameter_settings;

  /// No description provided for @base_steps.
  ///
  /// In en, this message translates to:
  /// **'Base Steps'**
  String get base_steps;

  /// No description provided for @offset_steps.
  ///
  /// In en, this message translates to:
  /// **'Offset Steps'**
  String get offset_steps;

  /// No description provided for @interval_minutes.
  ///
  /// In en, this message translates to:
  /// **'Interval (minutes)'**
  String get interval_minutes;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @start_auto_mode.
  ///
  /// In en, this message translates to:
  /// **'Start Auto Mode'**
  String get start_auto_mode;

  /// No description provided for @stop_auto_mode.
  ///
  /// In en, this message translates to:
  /// **'Stop Auto Mode'**
  String get stop_auto_mode;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @app_settings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get app_settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @advanced_parameters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Parameters'**
  String get advanced_parameters;

  /// No description provided for @auto_pause_title.
  ///
  /// In en, this message translates to:
  /// **'Auto Pause'**
  String get auto_pause_title;

  /// No description provided for @auto_pause_description.
  ///
  /// In en, this message translates to:
  /// **'Automatically pause when step count exceeds a threshold.'**
  String get auto_pause_description;

  /// No description provided for @auto_pause_steps_label.
  ///
  /// In en, this message translates to:
  /// **'Auto Pause when steps exceed'**
  String get auto_pause_steps_label;

  /// No description provided for @write_logs.
  ///
  /// In en, this message translates to:
  /// **'Write Logs'**
  String get write_logs;

  /// No description provided for @logs_cleared.
  ///
  /// In en, this message translates to:
  /// **'Logs cleared.'**
  String get logs_cleared;

  /// No description provided for @clear_all_logs.
  ///
  /// In en, this message translates to:
  /// **'Clear all logs'**
  String get clear_all_logs;

  /// No description provided for @no_logs.
  ///
  /// In en, this message translates to:
  /// **'No logs yet.'**
  String get no_logs;

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

  /// No description provided for @offset_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Offset Settings'**
  String get offset_settings_title;

  /// No description provided for @offset_settings_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable random step offset'**
  String get offset_settings_subtitle;

  /// No description provided for @log_write_success.
  ///
  /// In en, this message translates to:
  /// **'Total steps after write: {totalSteps}'**
  String log_write_success(String totalSteps);

  /// No description provided for @log_write_success_auto.
  ///
  /// In en, this message translates to:
  /// **'Automatically wrote {steps} steps.'**
  String log_write_success_auto(String steps);

  /// No description provided for @log_write_success_manual.
  ///
  /// In en, this message translates to:
  /// **'Manually wrote {steps} steps.'**
  String log_write_success_manual(String steps);

  /// No description provided for @start_auto_steps.
  ///
  /// In en, this message translates to:
  /// **'Start Auto Steps'**
  String get start_auto_steps;

  /// No description provided for @stop_auto_steps.
  ///
  /// In en, this message translates to:
  /// **'Stop Auto Steps'**
  String get stop_auto_steps;

  /// No description provided for @write_fail_check_log.
  ///
  /// In en, this message translates to:
  /// **'Failed to write steps, please check your health app or system settings.'**
  String get write_fail_check_log;

  /// No description provided for @write_error.
  ///
  /// In en, this message translates to:
  /// **'Error writing steps: {error}'**
  String write_error(String error);

  /// No description provided for @background_service_start.
  ///
  /// In en, this message translates to:
  /// **'Background service has been started.'**
  String get background_service_start;

  /// No description provided for @background_service_stop.
  ///
  /// In en, this message translates to:
  /// **'Background service has been stopped.'**
  String get background_service_stop;

  /// No description provided for @notification_update_title.
  ///
  /// In en, this message translates to:
  /// **'Steps Update'**
  String get notification_update_title;

  /// No description provided for @automatic_write_success.
  ///
  /// In en, this message translates to:
  /// **'Successfully automatically wrote {steps} steps.'**
  String automatic_write_success(String steps);

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
  /// **'App data has been successfully cleared.'**
  String get data_cleared_success;

  /// No description provided for @app_will_restart.
  ///
  /// In en, this message translates to:
  /// **'The app will now restart.'**
  String get app_will_restart;

  /// No description provided for @auto_pause_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically stop the service after writing a certain number of steps.'**
  String get auto_pause_subtitle;

  /// No description provided for @auto_pause_steps_hint.
  ///
  /// In en, this message translates to:
  /// **'The service will be stopped after writing this many steps in one session.'**
  String get auto_pause_steps_hint;

  /// No description provided for @app_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get app_reset;

  /// No description provided for @app_reset_desc.
  ///
  /// In en, this message translates to:
  /// **'This will clear all app data and settings, restoring the app to its initial state.'**
  String get app_reset_desc;

  /// No description provided for @offset_steps_hint.
  ///
  /// In en, this message translates to:
  /// **'The number of steps will be randomized within a positive and negative range of this value.'**
  String get offset_steps_hint;

  /// No description provided for @permission_denied_title.
  ///
  /// In en, this message translates to:
  /// **'Permission Permanently Denied'**
  String get permission_denied_title;

  /// No description provided for @permission_denied_content.
  ///
  /// In en, this message translates to:
  /// **'You have permanently denied a necessary permission. Please go to the settings for this app on your device and grant the permission manually for it to function properly.'**
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

  /// No description provided for @auto_pause_notification_content_with_steps.
  ///
  /// In en, this message translates to:
  /// **'The service has been automatically paused because the session goal of {steps} steps has been reached.'**
  String auto_pause_notification_content_with_steps(String steps);

  /// No description provided for @steps_written_this_session.
  ///
  /// In en, this message translates to:
  /// **'Steps Written This Session'**
  String get steps_written_this_session;

  /// No description provided for @auto_pause_remaining.
  ///
  /// In en, this message translates to:
  /// **'Auto-pause Remaining'**
  String get auto_pause_remaining;

  /// No description provided for @start_service_fail.
  ///
  /// In en, this message translates to:
  /// **'Failed to start service.'**
  String get start_service_fail;

  /// No description provided for @stop_service_fail.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop service.'**
  String get stop_service_fail;

  /// No description provided for @param_settings.
  ///
  /// In en, this message translates to:
  /// **'Parameter Settings'**
  String get param_settings;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval (minutes)'**
  String get interval;

  /// No description provided for @language_settings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get language_settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @system_theme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get system_theme;

  /// No description provided for @light_theme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get light_theme;

  /// No description provided for @dark_theme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get dark_theme;

  /// No description provided for @system_language.
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get system_language;

  /// No description provided for @traditional_chinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get traditional_chinese;

  /// No description provided for @about_walkgo.
  ///
  /// In en, this message translates to:
  /// **'About WalkGo'**
  String get about_walkgo;

  /// No description provided for @about_walkgo_content.
  ///
  /// In en, this message translates to:
  /// **'This app helps you log steps to your health data.'**
  String get about_walkgo_content;

  /// No description provided for @welcome_to_walkgo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to WalkGo'**
  String get welcome_to_walkgo;

  /// No description provided for @welcome_message.
  ///
  /// In en, this message translates to:
  /// **'Before you begin, please grant the necessary permissions.'**
  String get welcome_message;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @permission_health_title.
  ///
  /// In en, this message translates to:
  /// **'Health Permission'**
  String get permission_health_title;

  /// No description provided for @permission_health_desc.
  ///
  /// In en, this message translates to:
  /// **'This permission is required to write steps to your health data.'**
  String get permission_health_desc;

  /// No description provided for @permission_activity_title.
  ///
  /// In en, this message translates to:
  /// **'Activity Recognition Permission'**
  String get permission_activity_title;

  /// No description provided for @permission_activity_desc.
  ///
  /// In en, this message translates to:
  /// **'This permission is required to recognize your physical activity and accurately record steps.'**
  String get permission_activity_desc;

  /// No description provided for @permission_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get permission_notification_title;

  /// No description provided for @permission_notification_desc.
  ///
  /// In en, this message translates to:
  /// **'This permission is required to send you notifications about your progress and app status.'**
  String get permission_notification_desc;

  /// No description provided for @permission_battery_title.
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization Permission'**
  String get permission_battery_title;

  /// No description provided for @permission_battery_desc.
  ///
  /// In en, this message translates to:
  /// **'This permission is required to allow the app to run in the background.'**
  String get permission_battery_desc;

  /// No description provided for @grant_permission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grant_permission;

  /// No description provided for @setup_complete.
  ///
  /// In en, this message translates to:
  /// **'Setup Complete'**
  String get setup_complete;

  /// No description provided for @next_step.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get next_step;

  /// No description provided for @rerun_setup.
  ///
  /// In en, this message translates to:
  /// **'View Welcome Page'**
  String get rerun_setup;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @session_total_steps_template.
  ///
  /// In en, this message translates to:
  /// **'Total steps this session: {steps}'**
  String session_total_steps_template(Object steps);

  /// No description provided for @manual_steps_title.
  ///
  /// In en, this message translates to:
  /// **'Manual Write Once'**
  String get manual_steps_title;

  /// No description provided for @manual_steps_label.
  ///
  /// In en, this message translates to:
  /// **'Manual Steps'**
  String get manual_steps_label;

  /// No description provided for @manual_steps_hint.
  ///
  /// In en, this message translates to:
  /// **'Manually add a specific number of steps.'**
  String get manual_steps_hint;

  /// No description provided for @auto_pause_threshold.
  ///
  /// In en, this message translates to:
  /// **'Auto-pause Threshold'**
  String get auto_pause_threshold;

  /// No description provided for @auto_pause_threshold_hint.
  ///
  /// In en, this message translates to:
  /// **'The service will be stopped after writing this many steps in one session.'**
  String get auto_pause_threshold_hint;

  /// No description provided for @notification_service_running.
  ///
  /// In en, this message translates to:
  /// **'Service is running'**
  String get notification_service_running;

  /// No description provided for @notification_next_run.
  ///
  /// In en, this message translates to:
  /// **'Next write at: {time}'**
  String notification_next_run(String time);

  /// No description provided for @notification_steps_written.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps written'**
  String notification_steps_written(String steps);

  /// No description provided for @notification_channel_id.
  ///
  /// In en, this message translates to:
  /// **'WalkGo Service'**
  String get notification_channel_id;

  /// No description provided for @notification_channel_desc.
  ///
  /// In en, this message translates to:
  /// **'Notifications for WalkGo background service'**
  String get notification_channel_desc;

  /// No description provided for @notification_service_stopped_title.
  ///
  /// In en, this message translates to:
  /// **'Service Stopped'**
  String get notification_service_stopped_title;

  /// No description provided for @notification_service_stopped_content.
  ///
  /// In en, this message translates to:
  /// **'Ready. Waiting for you to enable auto mode.'**
  String get notification_service_stopped_content;

  /// No description provided for @notification_steps_written_title.
  ///
  /// In en, this message translates to:
  /// **'Steps Written Successfully'**
  String get notification_steps_written_title;

  /// No description provided for @manual_write_initiated.
  ///
  /// In en, this message translates to:
  /// **'Manual write initiated.'**
  String get manual_write_initiated;

  /// No description provided for @manual_write_button_text.
  ///
  /// In en, this message translates to:
  /// **'Write Once'**
  String get manual_write_button_text;

  /// No description provided for @manual_write_success_feedback.
  ///
  /// In en, this message translates to:
  /// **'Manually wrote {steps} steps'**
  String manual_write_success_feedback(String steps);

  /// No description provided for @auto_service_started.
  ///
  /// In en, this message translates to:
  /// **'Auto service started'**
  String get auto_service_started;

  /// No description provided for @auto_service_stopped.
  ///
  /// In en, this message translates to:
  /// **'Auto service stopped'**
  String get auto_service_stopped;

  /// No description provided for @auto_mode_running_lock_warning.
  ///
  /// In en, this message translates to:
  /// **'Auto mode is running. Parameters cannot be modified.'**
  String get auto_mode_running_lock_warning;

  /// No description provided for @error_base_less_than_offset.
  ///
  /// In en, this message translates to:
  /// **'Base steps must be greater than random offset steps.'**
  String get error_base_less_than_offset;

  /// No description provided for @error_threshold_too_low.
  ///
  /// In en, this message translates to:
  /// **'Auto-pause threshold must be greater than maximum single write (base + offset).'**
  String get error_threshold_too_low;

  /// No description provided for @today_steps_total.
  ///
  /// In en, this message translates to:
  /// **'Today Total: {steps} steps'**
  String today_steps_total(String steps);

  /// No description provided for @developer_label.
  ///
  /// In en, this message translates to:
  /// **'Author: Andrew Cho (卓稟鈞)'**
  String get developer_label;

  /// No description provided for @github_source_code.
  ///
  /// In en, this message translates to:
  /// **'GitHub Source Code'**
  String get github_source_code;

  /// No description provided for @version_label.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String version_label(String version);

  /// No description provided for @check_for_updates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get check_for_updates;

  /// No description provided for @update_available.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get update_available;

  /// No description provided for @update_available_desc.
  ///
  /// In en, this message translates to:
  /// **'A new version {version} is available. Would you like to update now?'**
  String update_available_desc(String version);

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @downloading_apk.
  ///
  /// In en, this message translates to:
  /// **'Downloading APK...'**
  String get downloading_apk;

  /// No description provided for @verifying_integrity.
  ///
  /// In en, this message translates to:
  /// **'Verifying file integrity...'**
  String get verifying_integrity;

  /// No description provided for @installing.
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get installing;

  /// No description provided for @update_failed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String update_failed(String error);

  /// No description provided for @latest_version_installed.
  ///
  /// In en, this message translates to:
  /// **'You are already using the latest version.'**
  String get latest_version_installed;

  /// No description provided for @invalid_architecture.
  ///
  /// In en, this message translates to:
  /// **'Could not find a suitable update for your device\'s architecture.'**
  String get invalid_architecture;

  /// No description provided for @hash_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Hash verification failed. The download might be corrupted.'**
  String get hash_mismatch;

  /// No description provided for @checking_for_updates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checking_for_updates;

  /// No description provided for @update_check_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates. Please check your network connection.'**
  String get update_check_failed;

  /// No description provided for @manual_download.
  ///
  /// In en, this message translates to:
  /// **'Manual Download'**
  String get manual_download;

  /// No description provided for @auto_update.
  ///
  /// In en, this message translates to:
  /// **'Auto Update'**
  String get auto_update;

  /// No description provided for @manual_download_title.
  ///
  /// In en, this message translates to:
  /// **'Manual Download Instructions'**
  String get manual_download_title;

  /// No description provided for @manual_download_description.
  ///
  /// In en, this message translates to:
  /// **'Your device architecture is: {architecture}. Please download the file named:'**
  String manual_download_description(String architecture);

  /// No description provided for @manual_download_filename.
  ///
  /// In en, this message translates to:
  /// **'Filename: {filename}'**
  String manual_download_filename(String filename);

  /// No description provided for @copy_link.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get copy_link;

  /// No description provided for @go_to_download.
  ///
  /// In en, this message translates to:
  /// **'Go to Download Page'**
  String get go_to_download;

  /// No description provided for @link_copied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get link_copied;

  /// No description provided for @view_release_notes.
  ///
  /// In en, this message translates to:
  /// **'View Version Information'**
  String get view_release_notes;

  /// No description provided for @release_notes.
  ///
  /// In en, this message translates to:
  /// **'Version Information'**
  String get release_notes;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @install_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to launch installer: {error}'**
  String install_failed(String error);

  /// No description provided for @reinstall_app.
  ///
  /// In en, this message translates to:
  /// **'Reinstall App'**
  String get reinstall_app;

  /// No description provided for @reinstall_app_desc.
  ///
  /// In en, this message translates to:
  /// **'Manual installation: Please uninstall the app first, then download and install the latest version.'**
  String get reinstall_app_desc;

  /// No description provided for @getting_latest_version_info.
  ///
  /// In en, this message translates to:
  /// **'Getting latest version information...'**
  String get getting_latest_version_info;

  /// No description provided for @manual_download_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please download the file named: {filename}'**
  String manual_download_prompt(String filename);

  /// No description provided for @apk_not_found_for_arch.
  ///
  /// In en, this message translates to:
  /// **'No APK found for your device architecture: {architecture}'**
  String apk_not_found_for_arch(String architecture);
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
