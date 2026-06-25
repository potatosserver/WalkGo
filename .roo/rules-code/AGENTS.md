# Project Coding Rules (Non-Obvious Only)
- **Background Isolate Communication**: Always use `service.invoke('event', data)` to send and `service.on('event').listen(...)` to receive data when interacting with the background service.
- **Health SDK Workaround**: Do NOT store a `Health` instance as a member variable. Always create a new `Health()` instance inside every method call (e.g., `getStepsToday`, `writeSteps`) to prevent crashes in background isolates.
- **SharedPreferences Sync**: In background isolates, you MUST call `await prefs.reload()` before reading any value to ensure you are not using stale data cached by the isolate.
- **Background Localization**: The background isolate cannot access `AppLocalizations`. You must pass localized strings as a `Map<String, String>` from the UI isolate via events (e.g., during `startService` or `update_localization`).
- **Step Simulation**: When implementing step logic, follow the pattern in `background_service.dart`: combine a base step count with a random offset and check against the `autoPauseThreshold`.
