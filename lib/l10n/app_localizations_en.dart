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
  String get status_running =>
      'Background service is running, automatically writing steps...';

  @override
  String get status_ready_to_start => 'Ready to start automatic step writing.';

  @override
  String manual_write_success(Object steps) {
    return 'Manual write success: $steps steps';
  }

  @override
  String automatic_write_success(Object steps) {
    return 'Automatic write success: $steps steps';
  }

  @override
  String get steps_gt_zero => 'Steps must be greater than 0.';

  @override
  String get write_fail_check_log =>
      'Write failed. Check the logs for more details.';

  @override
  String write_error(Object error) {
    return 'An error occurred while writing: $error';
  }

  @override
  String get background_service_start => 'Background service started.';

  @override
  String get background_service_stop => 'Background service stopped.';

  @override
  String get param_settings => 'Parameter Settings';

  @override
  String get base_steps => 'Base Steps';

  @override
  String get base_steps_hint =>
      'The base number of steps for each automatic write.';

  @override
  String get offset_steps => 'Offset Steps';

  @override
  String get offset_steps_hint =>
      'A random value between -offset and +offset will be added.';

  @override
  String get interval => 'Interval (minutes)';

  @override
  String get interval_hint => 'The interval for automatic step writing.';

  @override
  String get manual_write_once => 'Manual Write Once (Test)';

  @override
  String get stop_auto_steps => 'Stop Auto Steps';

  @override
  String get start_auto_steps => 'Start Background Auto Steps';

  @override
  String get notification_channel_name => 'WalkGo Background Service';

  @override
  String get notification_channel_description =>
      'WalkGo is simulating steps in the background...';

  @override
  String get notification_title => 'WalkGo';

  @override
  String get notification_content => 'Background service is running';

  @override
  String get notification_update_title => 'WalkGo Steps Update';

  @override
  String get theme => 'Appearance';

  @override
  String get system_theme => 'System Default';

  @override
  String get light_theme => 'Light Mode';

  @override
  String get dark_theme => 'Dark Mode';

  @override
  String get logs_cleared => 'Logs cleared.';

  @override
  String get about_walkgo => 'About WalkGo';

  @override
  String get about_walkgo_content =>
      'This application helps users automatically log steps to achieve their health goals.\n\nVersion: 1.0.0';

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
  String get rerun_setup => 'Rerun Welcome & Setup Process';

  @override
  String get rerun_setup_confirm_title => 'Confirm Action';

  @override
  String get rerun_setup_confirm_content =>
      'Are you sure you want to rerun the setup process? This will return you to the welcome screen and require you to grant permissions again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get welcome_to_walkgo => 'Welcome to WalkGo';

  @override
  String get welcome_message =>
      'This app helps you automatically write steps to your health data, making it easy to reach your daily goals.';

  @override
  String get get_started => 'Get Started';

  @override
  String get permission_health_title => 'Health Data Access';

  @override
  String get permission_health_desc =>
      'WalkGo needs to access your health data to read and write steps, which is the core function of the app.';

  @override
  String get permission_activity_title => 'Physical Activity Permission';

  @override
  String get permission_activity_desc =>
      'On some Android versions, this permission allows the app to run more accurately in the background to detect your activity.';

  @override
  String get permission_notification_title => 'Notification Permission';

  @override
  String get permission_notification_desc =>
      'We need to show notifications to keep the background service running and to inform you when steps are successfully written.';

  @override
  String get permission_battery_title => 'Disable Battery Optimization';

  @override
  String get permission_battery_desc =>
      'To ensure WalkGo can run stably in the background without being shut down by the OS, please disable battery optimization for this app.';

  @override
  String get grant_permission => 'Grant Permission';

  @override
  String get setup_complete => 'Finish Setup';

  @override
  String get next_step => 'Next';

  @override
  String get clear_data_button => 'Clear Permissions & Data';

  @override
  String get clear_data_confirm_title => 'Confirm Data Deletion';

  @override
  String get clear_data_confirm_content =>
      'This will clear all permissions and saved data (including step settings and logs), and stop all background services. The app will be restored to its initial state. Are you sure you want to continue?';

  @override
  String get clear_data_success_toast =>
      'Data has been cleared. The app will now restart.';

  @override
  String get language => 'Language';

  @override
  String get chinese => 'Chinese';

  @override
  String get english => 'English';

  @override
  String get systemDefault => 'System Default';

  @override
  String get settings => 'Settings';

  @override
  String get settings_tooltip => 'Settings';

  @override
  String get manage_permissions => 'Manage App Permissions';

  @override
  String get manage_permissions_desc =>
      'Opens system settings to manually grant or revoke all app permissions.';

  @override
  String get language_settings => 'Language Settings';

  @override
  String get log_type_manual => 'Manual';

  @override
  String get log_type_automatic => 'Automatic';

  @override
  String get status_initializing => 'Initializing...';
}
