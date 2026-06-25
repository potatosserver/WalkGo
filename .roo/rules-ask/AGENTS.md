# Project Documentation Rules (Non-Obvious Only)
- **Background Service Logic**: The core business logic for step simulation and health integration is located in `lib/services/background_service.dart`'s `onStart` function, not in a standard class.
- **L10n Architecture**: Localization for the background service is handled via `Map<String, String>` passed from the UI, as the background isolate cannot access `AppLocalizations`.
- **Health Integration**: The `HealthService` is a singleton, but it internally instantiates `Health()` on every method call to prevent isolate-related crashes.
- **Persistence Pattern**: `SharedPreferences` is used as the primary communication/state bridge between the UI isolate and the background isolate.
