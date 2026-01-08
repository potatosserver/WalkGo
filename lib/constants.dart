import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// --- Method Channel ---
const String channelName = 'com.walkgo/health';

// --- Global Variable Keys ---
const String prefIsAuto = "is_auto_running";
const String prefBaseSteps = "base_steps";
const String prefInterval = "interval_minutes";
const String prefPermissionsGranted = "permissions_granted";
const String prefIsFirstLaunch = "is_first_launch";
const String prefLanguageCode = "languageCode";
const String prefSessionTotalSteps = "session_total_steps"; // For auto-pause
const String prefOffsetEnabled = "offset_enabled";
const String prefOffset = "offset_steps";
const String prefAutoPauseEnabled = "auto_pause_enabled";
const String prefAutoPauseSteps = "auto_pause_steps";
const String prefNextRunTime = "next_run_time";

// --- Notification Channels & IDs ---
const AndroidNotificationChannel foregroundChannel = AndroidNotificationChannel(
  'my_foreground',
  'WalkGo Background Service',
  description: 'This channel is used for the persistent service notification.',
  importance: Importance.low, // To be non-intrusive
);

const AndroidNotificationChannel stepsUpdateChannel =
    AndroidNotificationChannel(
  'steps_update',
  'Steps Write Updates',
  description: 'Shows the result of each automatic step write.',
  importance: Importance.defaultImportance, // Make it visible
);

const int foregroundNotificationId = 888;
const int stepsUpdateNotificationId = 999;
