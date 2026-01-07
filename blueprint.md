
# Project Blueprint

## Overview

This document outlines the plan for implementing an Android 12+ style toast notification within the Flutter application. The goal is to provide users with clear, non-intrusive feedback that aligns with modern Android UI standards.

## Style, Design, and Features

### Implemented

*   **Initial Setup:** The project is a Flutter application with background services, localization, and basic settings pages.
*   **Notifications:** The app currently uses local notifications (`flutter_local_notifications`) to inform the user about events, such as the success of a "manual write" operation.

### Current Plan

*   **Toast Notifications:**
    *   **Technology:** We will use the `fluttertoast` package to leverage native Android Toast functionality.
    *   **Styling:** Toasts will conform to the Android 12+ standard, automatically including the app icon and name. This will be achieved by setting the toast's gravity to a non-center position (e.g., `ToastGravity.BOTTOM`).
    *   **Trigger:** A toast message will be displayed upon the successful completion of the "manual write once" action. This will replace the existing local notification for this event to provide a less intrusive user experience.

## Plan and Steps for Current Request

1.  **Add Dependency:** Add the `fluttertoast` package to the `pubspec.yaml` file.
2.  **Identify Trigger Location:** Examine `lib/settings_page.dart` and `lib/main.dart` to find the code that executes the "manual write" and currently triggers a local notification.
3.  **Implement Toast:** Replace the `FlutterLocalNotificationsPlugin.show()` call with `Fluttertoast.showToast()`.
    *   The message will be sourced from the localization files (`l10n.manual_write_success(steps)`).
    *   The toast gravity will be set to `ToastGravity.BOTTOM`.
4.  **Verification:** Run the app and test the "manual write" feature to ensure the toast appears correctly with the app icon on Android 12+ devices.
