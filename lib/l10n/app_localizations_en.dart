// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get walkgo => 'WalkGo';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get system_theme => 'Follow System';

  @override
  String get light_theme => 'Light Mode';

  @override
  String get dark_theme => 'Dark Mode';

  @override
  String get language_settings => 'Language';

  @override
  String get english => 'English';

  @override
  String get simplified_chinese => 'Simplified Chinese';

  @override
  String get traditional_chinese => 'Traditional Chinese';

  @override
  String get logs_cleared => 'Logs cleared.';

  @override
  String get about_walkgo => 'About WalkGo';

  @override
  String get about_walkgo_content =>
      'This app helps you automatically log your steps to meet your health goals.\n\nVersion: 1.0.0';

  @override
  String get close => 'Close';

  @override
  String get write_logs => 'Write Logs';

  @override
  String get clear_all_logs => 'Clear All Logs';

  @override
  String get no_logs => 'No logs yet.';

  @override
  String get about => 'About';

  @override
  String get rerun_setup => 'Rerun Welcome & Setup';

  @override
  String get rerun_setup_confirm_title => 'Confirm Action';

  @override
  String get rerun_setup_confirm_content =>
      'Are you sure you want to rerun the setup? This will take you to the welcome screen and require re-granting permissions.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get welcome_to_walkgo => 'Welcome to WalkGo';

  @override
  String get welcome_message =>
      'This app helps you automatically write your steps to your health data, so you can easily meet your daily goals.';

  @override
  String get get_started => 'Get Started';

  @override
  String get permission_health_title => 'Health Data Access';

  @override
  String get permission_health_desc =>
      'WalkGo needs access to your health data to read and write steps. This is the core function of the app.';

  @override
  String get permission_activity_title => 'Physical Activity Permission';

  @override
  String get permission_activity_desc =>
      'On some Android versions, this allows the app to run more accurately in the background to detect your activity.';

  @override
  String get permission_notification_title => 'Notification Permission';

  @override
  String get permission_notification_desc =>
      'We need to show a notification to keep the background service running and to inform you when steps are successfully written.';

  @override
  String get permission_battery_title => 'Disable Battery Optimization';

  @override
  String get permission_battery_desc =>
      'To ensure the app can run reliably in the background without being killed, please disable battery optimization for WalkGo.';

  @override
  String get grant_permission => 'Grant Permission';

  @override
  String get next_step => 'Next';

  @override
  String get setup_complete => 'Setup Complete';

  @override
  String get param_settings => 'Parameter Settings';

  @override
  String get base_steps => 'Base Steps';

  @override
  String get interval => 'Interval (minutes)';

  @override
  String get advanced_settings => 'Advanced Settings';

  @override
  String get manual_write_once => 'Manual Write Once';

  @override
  String get start_auto_steps => 'Start Auto Service';

  @override
  String get stop_auto_steps => 'Stop Auto Service';

  @override
  String get status_running => 'Service is running...';

  @override
  String get status_ready_to_start => 'Service is ready to start.';

  @override
  String get steps_gt_zero => 'Steps must be greater than 0.';

  @override
  String manual_write_success(Object steps) {
    return 'Successfully wrote $steps steps.';
  }

  @override
  String get write_fail_check_log =>
      'Failed to write steps. Please check your health app or system settings.';

  @override
  String write_error(Object error) {
    return 'Error writing steps: $error';
  }

  @override
  String get background_service_start => 'Background service started.';

  @override
  String get background_service_stop => 'Background service stopped.';

  @override
  String get notification_update_title => 'Steps Update';

  @override
  String automatic_write_success(Object steps) {
    return 'Successfully wrote $steps steps.';
  }

  @override
  String get clear_data_button => 'Clear All App Data';

  @override
  String get clear_data_confirm_title => 'Confirm Deletion';

  @override
  String get clear_data_confirm_content =>
      'This will permanently delete all app data, including your settings and logs. This action cannot be undone.';

  @override
  String get data_cleared_success => 'App data cleared successfully.';

  @override
  String get app_will_restart => 'The app will now restart.';

  @override
  String get auto_pause_title => 'Auto-Pause Service';

  @override
  String get auto_pause_subtitle =>
      'Automatically stop the service when a certain number of steps have been written.';

  @override
  String get auto_pause_steps_label => 'Auto-Pause Step Threshold';

  @override
  String get auto_pause_steps_hint =>
      'Service will stop after this many steps are written in one session.';

  @override
  String get offset_settings_title => 'Randomize Steps';

  @override
  String get offset_settings_subtitle => 'Enable random offset for steps';

  @override
  String get app_reset => 'Reset App';

  @override
  String get app_reset_desc =>
      'This action will clear all app data and settings, restoring the app to its initial state.';

  @override
  String get offset_steps_hint =>
      'Steps will be randomized within a plus/minus range of this value.';

  @override
  String get permission_denied_title => 'Permission Permanently Denied';

  @override
  String get permission_denied_content =>
      'You have permanently denied a required permission. Please go to your device\'s settings page for this app and manually grant the permission to ensure it functions correctly.';

  @override
  String get open_settings => 'Open Settings';

  @override
  String get auto_pause_notification_title => 'Service Paused Automatically';

  @override
  String get auto_pause_notification_content =>
      'The step writing service has been paused automatically as the session goal was reached.';

  @override
  String get settings_tooltip => 'Open Settings';

  @override
  String get log_type_manual => 'Manual';

  @override
  String get log_type_automatic => 'Automatic';

  @override
  String get start_service_fail => 'Failed to start service, please try again.';

  @override
  String get stop_service_fail => 'Failed to stop service, please try again.';

  @override
  String get status_stopped => 'Service is stopped.';

  @override
  String get next_run_pending => 'Next run is pending.';

  @override
  String next_run_at(Object time) {
    return 'Next run at $time';
  }
}
