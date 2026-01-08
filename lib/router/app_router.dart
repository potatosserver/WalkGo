import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/constants.dart';
import 'package:walkgo/pages/advanced_parameters_page.dart';
import 'package:walkgo/pages/appearance_settings_page.dart';
import 'package:walkgo/pages/home_page.dart';
import 'package:walkgo/pages/language_settings_page.dart';
import 'package:walkgo/pages/logs_page.dart';
import 'package:walkgo/pages/settings_page.dart';
import 'package:walkgo/permission_handler_page.dart';
import 'package:walkgo/splash_screen.dart';
import 'package:walkgo/welcome_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/permission',
        builder: (context, state) => const PermissionHandlerPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
          routes: [
            GoRoute(
              path: 'appearance',
              builder: (context, state) => const AppearanceSettingsPage(),
            ),
            GoRoute(
              path: 'language',
              builder: (context, state) => const LanguageSettingsPage(),
            ),
            GoRoute(
              path: 'logs',
              builder: (context, state) => const LogsPage(),
            ),
          ]),
      GoRoute(
        path: '/advanced_parameters',
        builder: (context, state) => const AdvancedParametersPage(),
      ),
    ],
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool(prefIsFirstLaunch) ?? true;

      if (state.uri.toString() == '/splash') {
        return isFirstLaunch ? '/welcome' : '/home';
      }

      return null;
    },
  );
}
