import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';

class PermissionHandlerPage extends StatefulWidget {
  const PermissionHandlerPage({super.key});

  @override
  State<PermissionHandlerPage> createState() => _PermissionHandlerPageState();
}

class _PermissionHandlerPageState extends State<PermissionHandlerPage>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _pageCount = 3; // Updated from 4 to 3
  final _health = Health();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updatePageState();
    }
  }

  Future<PermissionStatus> _checkSimplePermission(Permission permission) async {
    return await permission.status;
  }

  Future<void> _requestSimplePermission(Permission permission) async {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog();
    }
    _updatePageState();
  }

  Future<bool> _checkHealthPermission() async {
    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ_WRITE];
    final granted =
        await _health.hasPermissions(types, permissions: permissions) ?? false;
    return granted;
  }

  Future<void> _requestHealthPermission() async {
    final granted = await _health.requestAuthorization(
      [HealthDataType.STEPS],
      permissions: [HealthDataAccess.READ_WRITE],
    );
    if (!granted) {}
    _updatePageState();
  }

  void _showPermanentlyDeniedDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permission_denied_title),
        content: Text(l10n.permission_denied_content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text(l10n.open_settings),
          ),
        ],
      ),
    );
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
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    final systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLightMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.colorScheme.surface,
      systemNavigationBarIconBrightness:
          isLightMode ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          child: PageView.builder(
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
                    icon: Icons.notifications,
                    title: l10n.permission_notification_title,
                    description: l10n.permission_notification_desc,
                    requestPermission: () =>
                        _requestSimplePermission(Permission.notification),
                    checkPermission: () async => (await _checkSimplePermission(
                      Permission.notification,
                    ))
                        .isGranted,
                  );
                case 2:
                  return _buildPermissionPage(
                    icon: Icons.battery_charging_full,
                    title: l10n.permission_battery_title,
                    description: l10n.permission_battery_desc,
                    requestPermission: () => _requestSimplePermission(
                      Permission.ignoreBatteryOptimizations,
                    ),
                    checkPermission: () async => (await _checkSimplePermission(
                      Permission.ignoreBatteryOptimizations,
                    ))
                        .isGranted,
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                    backgroundColor: _currentPage == _pageCount - 1 
                        ? Colors.green.shade600 
                        : colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: colorScheme.onSurface.withAlpha(30),
                    disabledForegroundColor: colorScheme.onSurface.withAlpha(97),
                  ),
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
