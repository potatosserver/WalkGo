
# Blueprint: WalkGo

This document outlines the architecture, features, and design of the WalkGo application.

## 1. Project Overview

WalkGo is a Flutter application designed to help users track and manually increase their daily step count. It integrates with the device's health services to read and write step data, offers a background service for automatic step generation, and provides a user-friendly interface for managing settings and viewing activity logs.

## 2. File Structure

The project follows a standard Flutter structure, with all core application logic located in the `lib` directory.

```
lib/
├── l10n/
│   ├── app_en.arb
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   ├── app_localizations_zh.dart
│   └── app_zh.arb
├── pages/
│   ├── advanced_parameters_page.dart
│   ├── appearance_settings_page.dart
│   ├── home_page.dart
│   ├── language_settings_page.dart
│   ├── logs_page.dart
│   └── settings_page.dart
├── router/
│   └── app_router.dart
├── viewmodels/
│   ├── advanced_settings_viewmodel.dart
│   └── home_page_viewmodel.dart
├── widgets/
│   ├── parameter_settings_card.dart
│   └── status_card.dart
├── app_theme.dart
├── app_widget.dart
├── constants.dart
├── health_service.dart
├── language_service.dart
├── log_page.dart
├── log_service.dart
├── main.dart
├── permission_handler_page.dart
├── splash_screen.dart
├── theme_provider.dart
└── welcome_page.dart
```

## 3. Core Components & Logic

### 3.1. Main Entry Point (`main.dart`)

- **Initialization**:
    - Ensures `WidgetsFlutterBinding` is initialized.
    - Initializes `SharedPreferences` to check if it's the first launch (`isFirstLaunch`).
    - Sets preferred device orientations to portrait up/down.
- **Providers**:
    - Uses `MultiProvider` to provide `ThemeProvider` and `LanguageService` to the entire application.
- **Root Widget**:
    - Runs `MyApp`, passing the `isFirstLaunch` flag.

### 3.2. Root Widget (`app_widget.dart`)

- **Stateful Widget (`MyApp`)**: Manages the `GoRouter` instance.
- **`build()` method**:
    - Watches `ThemeProvider` and `LanguageService` for changes using `context.watch`.
    - Returns a `MaterialApp.router` configured with:
        - `routerConfig`: The router instance from `AppRouter`.
        - **Theming**: Sets up light and dark themes with Material 3 enabled. The color seed is `Colors.deepPurple`.
        - **Localization**: Configures `locale`, `localizationsDelegates`, and `supportedLocales` from `LanguageService` and `AppLocalizations`.

### 3.3. Routing (`router/app_router.dart`)

- **`GoRouter`**: Manages all navigation within the app.
- **Initial Location**:
    - `/welcome` if it's the first launch.
    - `/home` for subsequent launches.
- **Routes**:
    - `/splash`: `SplashScreen`
    - `/welcome`: `WelcomePage`
    - `/permission`: `PermissionHandlerPage`
    - `/home`: `HomePage`
    - `/settings`: `SettingsPage` (parent route)
        - `appearance`: `AppearanceSettingsPage`
        - `language`: `LanguageSettingsPage`
        - `logs`: `LogsPage`
    - `/advanced_parameters`: `AdvancedParametersPage`

### 3.4. Health & Permissions

- **`health_service.dart`**:
    - A singleton service (`HealthService`) that abstracts interactions with the `health` package.
    - `getStepsToday()`: Fetches the total steps for the current day.
    - `writeSteps(int steps)`: Writes a given number of steps to the health service.
    - `requestAuthorization()`: Requests authorization for reading/writing step data.
- **`permission_handler_page.dart`**:
    - A guided, multi-page UI to request necessary permissions from the user.
    - Uses a `PageView` to walk the user through granting permissions for:
        1.  **Health/Fitness**: Access to read/write step data.
        2.  **Activity Recognition**: To detect physical activity.
        3.  **Notifications**: To show status updates.
        4.  **Ignore Battery Optimizations**: To allow the background service to run reliably.
    - Handles cases where permissions are permanently denied by showing a dialog with a link to app settings.

### 3.5. State Management

- **Provider**: The primary state management solution.
    - **`ThemeProvider`**: Manages the application's theme (`ThemeMode.light`, `ThemeMode.dark`, `ThemeMode.system`).
    - **`LanguageService`**: Manages the application's locale.
    - **`HomePageViewModel`**: Manages the state and business logic for the `HomePage`.
    - **`AdvancedSettingsViewModel`**: Manages the state for the `AdvancedParametersPage`.

## 4. User Interface (Pages & Widgets)

### 4.1. Onboarding

- **`welcome_page.dart`**: The first screen new users see. It introduces the app and prompts the user to proceed to the permission setup.
- **`permission_handler_page.dart`**: Guides the user through the required permission grants.

### 4.2. Home Page (`pages/home_page.dart`)

- **ViewModel**: `HomePageViewModel`
- **UI Components**:
    - **`StatusCard`**: Displays the current status of the background service (e.g., "Running", "Stopped"), total steps generated in the session, and remaining steps until the auto-pause threshold is met.
    - **`ParameterSettingsCard`**: Allows the user to configure:
        - **Base Steps**: The number of steps to generate in each cycle.
        - **Interval**: The time (in minutes) between each step generation cycle.
    - **Manual Steps Button**: A button to manually write the "Base Steps" value to the health service.
    - **Start/Stop Auto Steps Button**: Toggles the background service for automatic step generation. The button's text and color change based on the service's running state.
- **Functionality**:
    - Fetches and displays step data.
    - Allows manual and automatic step generation.
    - Navigates to the `SettingsPage`.

### 4.3. Settings (`pages/settings_page.dart`)

- **Structure**: A `ListView` of `Card`s, grouping related settings.
- **Navigation**: Provides navigation to:
    - **Appearance Settings**: For changing the theme.
    - **Language Settings**: For changing the app language.
    - **Write Logs**: To view activity logs.
- **Actions**:
    - **About Dialog**: Shows information about the app.
    - **Re-run Setup**: Navigates the user back to the `/welcome` screen.
    - **Clear Data**: A dangerous action that:
        - Stops the background service.
        - Clears all `SharedPreferences` data.
        - Clears all stored logs.
        - Navigates the user to the root of the app, effectively resetting it.

### 4.4. Other Pages

- **`appearance_settings_page.dart`**: Allows the user to select between Light, Dark, and System default themes.
- **`language_settings_page.dart`**: Allows the user to select the app's language.
- **`logs_page.dart`**: Displays a list of all logs captured by the `LogService`.
- **`advanced_parameters_page.dart`**: Provides settings for more advanced features, such as the auto-pause threshold.

## 5. Background Service

- **Implementation**: Uses the `flutter_background_service` package. The service logic is not directly visible in the provided file list but is controlled via the `HomePageViewModel`.
- **Functionality**:
    - Runs periodically in the background.
    - Generates a random number of steps based on the user-configured "Base Steps".
    - Writes the generated steps to the health service.
    - Communicates with the UI via `_service.on('update_ui')` to update status, total steps, etc.
- **Control**:
    - Can be started, stopped, and updated from the `HomePageViewModel`.
    - Automatically stops if it reaches the `autoPauseThreshold`.

## 6. Design & Style

- **Theme**:
    - **Material 3**: Enabled (`useMaterial3: true`).
    - **Color**: Based on a `colorSchemeSeed` of `Colors.deepPurple`.
    - **Modes**: Supports both light and dark modes.
- **System UI**:
    - A transparent `AppBar` on the `HomePage` with the status bar icons adapting to the theme.
    - System navigation bar color matches the app's surface color.
- **Widgets**:
    - Uses standard Material components like `Card`, `ListTile`, `ElevatedButton`, and `FilledButton`.
    - Custom widgets like `StatusCard` and `ParameterSettingsCard` encapsulate specific UI sections for reusability and clarity.
    - Toasts (`fluttertoast`) are used to provide feedback for actions like successfully writing steps or clearing data.
