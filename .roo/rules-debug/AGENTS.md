# Project Debug Rules (Non-Obvious Only)
- **Isolate Crashes**: Failures in `background_service.dart` often leave no trace in the main console. Check `ErrorLogService` and the custom logs written via `LogUtils` in `SharedPreferences` to diagnose background failures.
- **State Mismatch**: If the UI shows outdated data while the service is running, verify that `service.invoke('update_ui', ...)` is being called and that the UI isolate is listening correctly.
- **ADB in Proot**: `adb` binaries from the Android SDK are x86-64 and will fail on ARM64. Use the system-installed `adb` (via `apt install adb`) and symlink it to the SDK path.
- **Health SDK Failures**: `Health` package errors in background isolates are almost always due to persistent instance usage; verify that a new `Health()` instance is created per-call.
