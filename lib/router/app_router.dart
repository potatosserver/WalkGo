import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/pages/home_page.dart';
import 'package:walkgo/pages/settings_page.dart';
import 'package:walkgo/permission_handler_page.dart';
import 'package:walkgo/welcome_page.dart';

class AppRouter {
  static const String homeRoute = '/home';
  static const String welcomeRoute = '/welcome';
  static const String permissionRoute = '/permission';
  static const String settingsRoute = '/settings';

  static Future<String> getInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstLaunch = prefs.getBool(prefIsFirstLaunch) ?? true;
      if (isFirstLaunch) {
        return welcomeRoute;
      }
      final bool permissionsGranted =
          prefs.getBool(prefPermissionsGranted) ?? false;
      if (!permissionsGranted) {
        return permissionRoute;
      }
      return homeRoute;
    } catch (e) {
      // If anything goes wrong, default to the welcome page
      return welcomeRoute;
    }
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcomeRoute:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case permissionRoute:
        return MaterialPageRoute(builder: (_) => const PermissionHandlerPage());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
    }
  }
}
