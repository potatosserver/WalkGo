import 'package:go_router/go_router.dart';
import 'pages/advanced_parameters_page.dart';
import 'pages/appearance_settings_page.dart';
import 'pages/home_page.dart';
import 'pages/language_settings_page.dart';
import 'pages/log_page.dart';
import 'pages/settings_page.dart';
import 'pages/permission_handler_page.dart';
import 'pages/splash_screen.dart';
import 'pages/welcome_page.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
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
                builder: (context, state) => const LogPage(),
              ),
            ]),
        GoRoute(
          path: '/advanced_parameters',
          builder: (context, state) => const AdvancedParametersPage(),
        ),
      ],
    );
  }
}
