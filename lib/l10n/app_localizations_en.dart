// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get walkgo => 'WalkGO';

  @override
  String get settings_tooltip => 'Settings';

  @override
  String get status_card_title => 'Status';

  @override
  String get status_running => 'Running...';

  @override
  String get status_ready_to_start => 'Ready to start';

  @override
  String get status_stopped => 'Stopped';

  @override
  String next_run_at(String time) {
    return 'Next run at $time';
  }

  @override
  String get next_run_pending => 'Next run pending...';

  @override
  String get session_steps => 'Session Steps';

  @override
  String get remaining_steps_today => 'Remaining Steps Today';

  @override
  String get parameter_settings => 'Parameter Settings';

  @override
  String get base_steps => 'Base Steps';

  @override
  String get offset_steps => 'Offset Steps';

  @override
  String get interval_minutes => 'Interval (minutes)';

  @override
  String get actions => 'Actions';

  @override
  String get start_auto_mode => 'Start Auto Mode';

  @override
  String get stop_auto_mode => 'Stop Auto Mode';

  @override
  String get settings => 'Settings';

  @override
  String get app_settings => 'App Settings';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get advanced_parameters => 'Advanced Parameters';

  @override
  String get auto_pause_title => 'Auto Pause';

  @override
  String get auto_pause_description =>
      'Automatically pause when step count exceeds a threshold.';

  @override
  String get auto_pause_steps_label => 'Auto Pause when steps exceed';

  @override
  String get write_logs => 'Write Logs';

  @override
  String get logs_cleared => 'Logs cleared.';

  @override
  String get clear_all_logs => 'Clear all logs';

  @override
  String get no_logs => 'No logs yet.';

  @override
  String get log_type_manual => 'Manual';

  @override
  String get log_type_automatic => 'Automatic';

  @override
  String get offset_settings_title => 'Offset Settings';

  @override
  String get offset_settings_subtitle => 'Enable random step offset';

  @override
  String log_write_success(String totalSteps) {
    return 'Total steps after write: $totalSteps';
  }

  @override
  String get start_auto_steps => 'Start Auto Steps';

  @override
  String get stop_auto_steps => 'Stop Auto Steps';

  @override
  String get write_fail_check_log =>
      'Failed to write steps, please check your health app or system settings.';

  @override
  String write_error(String error) {
    return 'Error writing steps: $error';
  }

  @override
  String get background_service_start => 'Background service has been started.';

  @override
  String get background_service_stop => 'Background service has been stopped.';

  @override
  String get notification_update_title => 'Steps Update';

  @override
  String automatic_write_success(String steps) {
    return 'Successfully automatically wrote $steps steps.';
  }

  @override
  String get clear_data_button => 'Clear All App Data';

  @override
  String get clear_data_confirm_title => 'Confirm Deletion';

  @override
  String get clear_data_confirm_content =>
      'This will permanently delete all app data, including your settings and logs. This action cannot be undone.';

  @override
  String get data_cleared_success => 'App data has been successfully cleared.';

  @override
  String get app_will_restart => 'The app will now restart.';

  @override
  String get auto_pause_subtitle =>
      'Automatically stop the service after writing a certain number of steps.';

  @override
  String get auto_pause_steps_hint =>
      'The service will be stopped after writing this many steps in one session.';

  @override
  String get app_reset => 'Reset App';

  @override
  String get app_reset_desc =>
      'This will clear all app data and settings, restoring the app to its initial state.';

  @override
  String get offset_steps_hint =>
      'The number of steps will be randomized within a positive and negative range of this value.';

  @override
  String get permission_denied_title => 'Permission Permanently Denied';

  @override
  String get permission_denied_content =>
      'You have permanently denied a necessary permission. Please go to the settings for this app on your device and grant the permission manually for it to function properly.';

  @override
  String get open_settings => 'Open Settings';

  @override
  String get auto_pause_notification_title => 'Service Paused Automatically';

  @override
  String auto_pause_notification_content_with_steps(String steps) {
    return 'The service has been automatically paused because the session goal of $steps steps has been reached.';
  }

  @override
  String get steps_written_this_session => 'Steps Written This Session';

  @override
  String get auto_pause_remaining => 'Auto-pause Remaining';

  @override
  String get start_service_fail => 'Failed to start service.';

  @override
  String get stop_service_fail => 'Failed to stop service.';

  @override
  String get param_settings => 'Parameter Settings';

  @override
  String get interval => 'Interval (minutes)';

  @override
  String get language_settings => 'Language Settings';

  @override
  String get about => 'About';

  @override
  String get system_theme => 'System Theme';

  @override
  String get light_theme => 'Light Theme';

  @override
  String get dark_theme => 'Dark Theme';

  @override
  String get system_language => 'System Language';

  @override
  String get traditional_chinese => 'Traditional Chinese';

  @override
  String get about_walkgo => 'About WalkGo';

  @override
  String get about_walkgo_content =>
      'This app helps you log steps to your health data.';

  @override
  String get welcome_to_walkgo => 'Welcome to WalkGo';

  @override
  String get welcome_message =>
      'Before you begin, please grant the necessary permissions.';

  @override
  String get get_started => 'Get Started';

  @override
  String get cancel => 'Cancel';

  @override
  String get permission_health_title => 'Health Permission';

  @override
  String get permission_health_desc =>
      'This permission is required to write steps to your health data.';

  @override
  String get permission_activity_title => 'Activity Recognition Permission';

  @override
  String get permission_activity_desc =>
      'This permission is required to monitor your activity and write steps.';

  @override
  String get permission_notification_title => 'Notification Permission';

  @override
  String get permission_notification_desc =>
      'This permission is required to show notifications about the service status.';

  @override
  String get permission_battery_title => 'Battery Optimization Permission';

  @override
  String get permission_battery_desc =>
      'This permission is required to allow the app to run in the background.';

  @override
  String get grant_permission => 'Grant Permission';

  @override
  String get setup_complete => 'Setup Complete';

  @override
  String get next_step => 'Next Step';

  @override
  String get rerun_setup => 'View Welcome Page';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String session_total_steps_template(Object steps) {
    return 'Total steps this session: $steps';
  }

  @override
  String get manual_steps_title => 'Manual Write Once';

  @override
  String get manual_steps_label => 'Manual Steps';

  @override
  String get manual_steps_hint => 'Manually add a specific number of steps.';

  @override
  String get auto_pause_threshold => 'Auto-pause Threshold';

  @override
  String get auto_pause_threshold_hint =>
      'The service will be stopped after writing this many steps in one session.';

  @override
  String get notification_service_running => 'Service is running';

  @override
  String notification_next_run(String time) {
    return 'Next write at: $time';
  }

  @override
  String notification_steps_written(String steps) {
    return '$steps steps written';
  }

  @override
  String get notification_channel_id => 'WalkGo Service';

  @override
  String get notification_channel_desc =>
      'Notifications for WalkGo background service';

  @override
  String get notification_service_stopped_title => 'Service Stopped';

  @override
  String get notification_service_stopped_content =>
      'Ready. Waiting for you to enable auto mode.';

  @override
  String get notification_steps_written_title => 'Steps Written Successfully';
}
