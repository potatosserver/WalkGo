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
    Locale('zh'),
  ];

  /// No description provided for @walkgo.
  ///
  /// In en, this message translates to:
  /// **'WalkGo'**
  String get walkgo;

  /// No description provided for @status_running.
  ///
  /// In en, this message translates to:
  /// **'Background service is running, automatically writing steps...'**
  String get status_running;

  /// No description provided for @status_ready_to_start.
  ///
  /// In en, this message translates to:
  /// **'Ready to start automatic step writing.'**
  String get status_ready_to_start;

  /// No description provided for @manual_write_success.
  ///
  /// In en, this message translates to:
  /// **'Manual write success: {steps} steps'**
  String manual_write_success(Object steps);

  /// No description provided for @steps_gt_zero.
  ///
  /// In en, this message translates to:
  /// **'Steps must be greater than 0.'**
  String get steps_gt_zero;

  /// No description provided for @write_fail_check_log.
  ///
  /// In en, this message translates to:
  /// **'Write failed. Check the logs for more details.'**
  String get write_fail_check_log;

  /// No description provided for @write_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while writing: {error}'**
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

  /// No description provided for @base_steps_hint.
  ///
  /// In en, this message translates to:
  /// **'The base number of steps for each automatic write.'**
  String get base_steps_hint;

  /// No description provided for @offset_steps.
  ///
  /// In en, this message translates to:
  /// **'Offset Steps'**
  String get offset_steps;

  /// No description provided for @offset_steps_hint.
  ///
  /// In en, this message translates to:
  /// **'A random value between -offset and +offset will be added.'**
  String get offset_steps_hint;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval (minutes)'**
  String get interval;

  /// No description provided for @interval_hint.
  ///
  /// In en, this message translates to:
  /// **'The interval for automatic step writing.'**
  String get interval_hint;

  /// No description provided for @manual_write_once.
  ///
  /// In en, this message translates to:
  /// **'Manual Write Once (Test)'**
  String get manual_write_once;

  /// No description provided for @stop_auto_steps.
  ///
  /// In en, this message translates to:
  /// **'Stop Auto Steps'**
  String get stop_auto_steps;

  /// No description provided for @start_auto_steps.
  ///
  /// In en, this message translates to:
  /// **'Start Background Auto Steps'**
  String get start_auto_steps;

  /// No description provided for @notification_channel_name.
  ///
  /// In en, this message translates to:
  /// **'WalkGo Background Service'**
  String get notification_channel_name;

  /// No description provided for @notification_channel_description.
  ///
  /// In en, this message translates to:
  /// **'WalkGo is simulating steps in the background...'**
  String get notification_channel_description;

  /// No description provided for @notification_title.
  ///
  /// In en, this message translates to:
  /// **'WalkGo'**
  String get notification_title;

  /// No description provided for @notification_content.
  ///
  /// In en, this message translates to:
  /// **'Background service is running'**
  String get notification_content;

  /// No description provided for @notification_update_title.
  ///
  /// In en, this message translates to:
  /// **'WalkGo Steps Update'**
  String get notification_update_title;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @system_theme.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
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
  /// **'This application helps users automatically log steps to achieve their health goals.\n\nVersion: 1.0.0'**
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
  /// **'Rerun Welcome & Setup Process'**
  String get rerun_setup;

  /// No description provided for @rerun_setup_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get rerun_setup_confirm_title;

  /// No description provided for @rerun_setup_confirm_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to rerun the setup process? This will return you to the welcome screen and require you to grant permissions again.'**
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
  /// **'This app helps you automatically write steps to your health data, making it easy to reach your daily goals.'**
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
  /// **'WalkGo needs to access your health data to read and write steps, which is the core function of the app.'**
  String get permission_health_desc;

  /// No description provided for @permission_activity_title.
  ///
  /// In en, this message translates to:
  /// **'Physical Activity Permission'**
  String get permission_activity_title;

  /// No description provided for @permission_activity_desc.
  ///
  /// In en, this message translates to:
  /// **'On some Android versions, this permission allows the app to run more accurately in the background to detect your activity.'**
  String get permission_activity_desc;

  /// No description provided for @permission_notification_title.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get permission_notification_title;

  /// No description provided for @permission_notification_desc.
  ///
  /// In en, this message translates to:
  /// **'We need to show notifications to keep the background service running and to inform you when steps are successfully written.'**
  String get permission_notification_desc;

  /// No description provided for @permission_battery_title.
  ///
  /// In en, this message translates to:
  /// **'Disable Battery Optimization'**
  String get permission_battery_title;

  /// No description provided for @permission_battery_desc.
  ///
  /// In en, this message translates to:
  /// **'To ensure WalkGo can run stably in the background without being shut down by the OS, please disable battery optimization for this app.'**
  String get permission_battery_desc;

  /// No description provided for @grant_permission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grant_permission;

  /// No description provided for @setup_complete.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get setup_complete;

  /// No description provided for @next_step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next_step;

  /// No description provided for @clear_data_button.
  ///
  /// In en, this message translates to:
  /// **'Clear Permissions & Data'**
  String get clear_data_button;

  /// No description provided for @clear_data_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Data Deletion'**
  String get clear_data_confirm_title;

  /// No description provided for @clear_data_confirm_content.
  ///
  /// In en, this message translates to:
  /// **'This will clear all permissions and saved data (including step settings and logs), and stop all background services. The app will be restored to its initial state. Are you sure you want to continue?'**
  String get clear_data_confirm_content;

  /// No description provided for @clear_data_success_toast.
  ///
  /// In en, this message translates to:
  /// **'Data has been cleared. The app will now restart.'**
  String get clear_data_success_toast;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settings_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_tooltip;

  /// No description provided for @manage_permissions.
  ///
  /// In en, this message translates to:
  /// **'Manage App Permissions'**
  String get manage_permissions;

  /// No description provided for @manage_permissions_desc.
  ///
  /// In en, this message translates to:
  /// **'Opens system settings to manually grant or revoke all app permissions.'**
  String get manage_permissions_desc;

  /// No description provided for @language_settings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get language_settings;

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
    'that was used.',
  );
}
