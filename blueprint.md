# Project Blueprint: WalkGo

## Overview

WalkGo is a Flutter application that allows users to log steps to their health data. The app provides both manual and automatic step-logging functionalities. It runs a background service to periodically write steps, and it is localized in English and Traditional Chinese.

## Implemented Features

### Style and Design

*   **Theme:** Light and dark theme support using the `provider` package.
*   **Localization:** English and Traditional Chinese language support.
*   **UI:** Basic UI with buttons to start/stop the service and manually write steps.

### Features

*   **Manual Step Logging:** Users can manually write a specific number of steps.
*   **Automatic Step Logging:** A background service periodically writes a random number of steps.
*   **Step Randomization:** The number of steps can be randomized.
*   **Auto-Pause:** The service can be configured to automatically pause after a certain number of steps.
*   **Settings:**
    *   Base steps
    *   Interval
    *   Random offset
    *   Auto-pause threshold
*   **Logging:** The app logs all step-writing activities.
*   **Permissions:** The app handles permissions for health data, activity recognition, notifications, and battery optimization.

## Current Goal: UI/UX Revamp and Code Refactoring

The current goal is to improve the user interface and user experience of the app, as well as refactor the code for better readability and maintainability.

### Plan

1.  **UI Overhaul:**
    *   Redesign the main screen for a more modern and intuitive look.
    *   Use cards to display key information like service status, total steps, and session steps.
    *   Incorporate more visually appealing elements like icons and charts.
    *   Improve the layout and spacing for better readability.
2.  **Code Refactoring:**
    *   Move business logic out of the `main.dart` file and into separate service classes.
    *   Use a more robust state management solution (like `provider` with `ChangeNotifier`) for managing the app's state, instead of relying solely on `SharedPreferences` for UI updates.
    *   Improve the error handling and logging mechanisms.
3.  **New Features:**
    *   Add a chart to visualize the user's step history.
    *   Implement a more user-friendly way to configure the settings.
