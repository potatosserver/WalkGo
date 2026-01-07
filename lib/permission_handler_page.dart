import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/main.dart';
import 'l10n/app_localizations.dart';

class PermissionHandlerPage extends StatefulWidget {
  const PermissionHandlerPage({super.key});

  @override
  State<PermissionHandlerPage> createState() => _PermissionHandlerPageState();
}

class _PermissionHandlerPageState extends State<PermissionHandlerPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _pageCount = 4;

  Future<void> _setPermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefPermissionsGranted, true);
  }

  Future<bool> _checkSimplePermission(Permission permission) async {
    return await permission.isGranted;
  }

  Future<void> _requestSimplePermission(Permission permission) async {
    await permission.request();
    _updatePageState();
  }

  Future<bool> _checkHealthPermission() async {
    return await Health().hasPermissions(
          [HealthDataType.STEPS],
          permissions: [HealthDataAccess.READ_WRITE],
        ) ??
        false;
  }

  Future<void> _requestHealthPermission() async {
    await Health().requestAuthorization(
      [HealthDataType.STEPS],
      permissions: [HealthDataAccess.READ_WRITE],
    );
    _updatePageState();
  }

  void _updatePageState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _goToNextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _setPermissionsGranted().then((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pageCount,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          if (mounted) {
            setState(() {
              _currentPage = page;
            });
          }
        },
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildPermissionPage(
                icon: Icons.favorite,
                title: l10n.permission_health_title,
                description: l10n.permission_health_desc,
                requestPermission: _requestHealthPermission,
                checkPermission: _checkHealthPermission,
              );
            case 1:
              return _buildPermissionPage(
                icon: Icons.directions_run,
                title: l10n.permission_activity_title,
                description: l10n.permission_activity_desc,
                requestPermission: () =>
                    _requestSimplePermission(Permission.activityRecognition),
                checkPermission: () =>
                    _checkSimplePermission(Permission.activityRecognition),
              );
            case 2:
              return _buildPermissionPage(
                icon: Icons.notifications,
                title: l10n.permission_notification_title,
                description: l10n.permission_notification_desc,
                requestPermission: () =>
                    _requestSimplePermission(Permission.notification),
                checkPermission: () =>
                    _checkSimplePermission(Permission.notification),
              );
            case 3:
              return _buildPermissionPage(
                icon: Icons.battery_charging_full,
                title: l10n.permission_battery_title,
                description: l10n.permission_battery_desc,
                requestPermission: () => _requestSimplePermission(
                    Permission.ignoreBatteryOptimizations),
                checkPermission: () => _checkSimplePermission(
                    Permission.ignoreBatteryOptimizations),
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildPermissionPage({
    required IconData icon,
    required String title,
    required String description,
    required Future<void> Function() requestPermission,
    required Future<bool> Function() checkPermission,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<bool>(
      future: checkPermission(),
      builder: (context, snapshot) {
        final bool isGranted = snapshot.data ?? false;

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 60, color: colorScheme.primary),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    if (!isGranted)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.shield),
                        label: Text(l10n.grant_permission),
                        onPressed: requestPermission,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isGranted ? _goToNextPage : null,
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      shape: MaterialStateProperty.all(const StadiumBorder()),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return colorScheme.onSurface.withOpacity(0.12);
                        }
                        // Use green for the final step button, otherwise primary color
                        if (_currentPage == _pageCount - 1) {
                          return Colors.green.shade600;
                        }
                        return colorScheme.primary;
                      }),
                      foregroundColor:
                          MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.disabled)) {
                          return colorScheme.onSurface.withOpacity(0.38);
                        }
                        return colorScheme.onPrimary;
                      })),
                  child: Text(
                    _currentPage == _pageCount - 1
                        ? l10n.setup_complete
                        : l10n.next_step,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
