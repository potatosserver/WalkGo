# Project Blueprint

## Overview

This document outlines the development and design of a Flutter application called WalkGo. The primary goal of WalkGo is to help users automatically log steps to their health data, making it easier to achieve daily fitness goals. The app features background services, localization, and a range of customizable settings.

## Style, Design, and Features

### Implemented

*   **Core Functionality:**
    *   **Automatic Step Writing:** A background service automatically writes a configurable number of steps at a set interval.
    *   **Manual Step Writing:** Users can manually trigger a step write for testing or immediate logging.
    *   **Localization:** The app supports English and Chinese, with language selection available in the settings.
*   **User Interface & Experience:**
    *   **Modern Theming:** The app uses Material 3 design, with support for light, dark, and system default themes.
    *   **Welcome & Setup Flow:** A guided, one-time setup process for new users to grant necessary permissions (Health, Activity, Notifications, Battery Optimization).
    *   **Settings Management:** A dedicated settings page allows users to manage themes, languages, logs, and application data.
    *   **Toast Notifications:** The app uses `fluttertoast` to provide non-intrusive feedback for actions like manual step writing, aligning with modern Android UI standards.
*   **Advanced Features:**
    *   **Random Step Offset:** The number of steps written can be randomized by adding or subtracting a configurable offset, making the data appear more natural. This feature is enabled by default.
    *   **Auto-Pause:** The background service can be configured to automatically stop for the day once a specified total number of steps has been logged.

### Current UI/UX Enhancements

*   **Relocated Advanced Settings Button:** The entry point for "Advanced Settings" has been moved from the general settings page directly to the main home screen, placing it below the primary parameter inputs for better visibility and access.
*   **Intuitive Settings Interaction:** On the "Advanced Settings" page, when a feature (like "Random Step Offset" or "Auto-Pause") is disabled via its switch:
    *   The corresponding input fields (e.g., offset amount, auto-pause step count) become visually disabled (grayed out) but remain visible.
    *   The switch for enabling/disabling a feature has been moved to the main title of the setting card, creating a cleaner and more standard `Row` layout.

## Plan and Steps for Current Request

1.  **Enable Offset by Default:** Modify `advanced_settings_page.dart` to set the `_offsetEnabled` state to `true` by default when settings are first loaded.
2.  **Refactor UI in `advanced_settings_page.dart`:**
    *   Create a reusable `_buildSettingCard` widget to encapsulate the UI for each setting option.
    *   Use a `Row` within the card to place the setting's title and its `Switch` on the same line for a more compact layout.
    *   Bind the `enabled` property of the `TextField` widgets to the state of their respective switches (`_offsetEnabled`, `_autoPauseEnabled`).
    *   Adjust the visual appearance of disabled `TextField`s to have a grayed-out background, indicating they are inactive.
3.  **Update Localization Files:** Add new keys and translations for the improved UI elements in `app_en.arb` and `app_zh.arb`.
4.  **Update Blueprint:** Document the new design decisions and implementation details in `blueprint.md`.
