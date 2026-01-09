# WalkGo App Blueprint

## Overview

WalkGo is a Flutter application designed to help users track and log their walking steps. It provides both manual and automatic step recording functionalities, along with customizable settings to tailor the user experience. The app leverages a background service to ensure continuous operation and provides users with real-time updates and notifications.

## Style and Design

The application follows Material Design 3 guidelines, offering a clean and intuitive user interface. It supports both light and dark themes, and the UI is designed to be responsive and accessible. Key design elements include:

*   **Color Scheme:** A color scheme generated from a seed color, ensuring a harmonious and visually appealing look.
*   **Typography:** Consistent and readable typography using the `google_fonts` package.
*   **Component Theming:** Centralized theming for widgets like `AppBar` and `ElevatedButton` to maintain a consistent style throughout the app.
*   **Iconography:** Meaningful icons to enhance user understanding and navigation.

## Features

### 1. Step Tracking and Logging

*   **Manual Step Entry:** Users can manually input and log a specific number of steps.
*   **Automatic Step Logging:** The app can automatically log steps at regular intervals.
*   **Background Service:** A persistent background service ensures that steps are logged even when the app is not in the foreground.
*   **Health App Integration:** The app integrates with the platform's health service to write step data.

### 2. Customizable Settings

*   **Parameter Settings:**
    *   **Base Steps:** The default number of steps to be logged in each interval.
    *   **Offset Steps:** A random offset to be added or subtracted from the base steps.
    *   **Interval:** The time interval (in minutes) for automatic step logging.
*   **Advanced Parameters:**
    *   **Auto Pause:** Automatically pause the service when the step count exceeds a specified threshold.
    *   **Offset Settings:** Enable or disable the random step offset.
*   **Appearance Settings:**
    *   **Theme:** Choose between light, dark, and system default themes.
    *   **Language:** Switch between English and Chinese.

### 3. User Interface and Experience

*   **Home Page:** Displays the current status of the service, session steps, and provides controls to start or stop the automatic mode.
*   **Settings Page:** A centralized location for all customizable settings.
*   **Logs Page:** A historical view of all logged step entries.
*   **Welcome and Permissions:** A guided setup process to grant necessary permissions for the app to function correctly.
*   **Notifications:** The app provides notifications for service status, step logging, and other important events.

### 4. Technical Implementation

*   **State Management:** The app uses the `provider` package for state management, ensuring a clear and maintainable architecture.
*   **Routing:** The `go_router` package is used for declarative routing, providing a robust and flexible navigation system.
*   **Localization:** The app supports multiple languages using Flutter's built-in internationalization capabilities.
*   **Error Handling and Logging:** A comprehensive logging system is in place to track errors and important events.
*   **Permissions Handling:** The `permission_handler` package is used to manage and request necessary permissions from the user.
