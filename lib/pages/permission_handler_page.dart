import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../services/preference_service.dart';

class PermissionHandlerPage extends StatefulWidget {
  const PermissionHandlerPage({super.key});

  @override
  State<PermissionHandlerPage> createState() => _PermissionHandlerPageState();
}

class _PermissionHandlerPageState extends State<PermissionHandlerPage>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _pageCount = 3;
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

  Future<bool> _checkHealthPermission() async {
    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ_WRITE];
    return await _health.hasPermissions(types, permissions: permissions) ??
        false;
  }

  Future<void> _requestHealthPermission() async {
    await _health.requestAuthorization(
      [HealthDataType.STEPS],
      permissions: [HealthDataAccess.READ_WRITE],
    );
    _updatePageState();
  }

  Future<bool> _checkSimplePermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      await PreferenceService().setSkipNotification(false);
    }
    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog();
    }
    _updatePageState();
  }

  Future<void> _requestBatteryPermission() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    if (status.isGranted) {
      await PreferenceService().setSkipBattery(false);
    }
    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog();
    }
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

  void _showSkipWarningDialog(
      {required String title,
      required String description,
      required Future<void> Function() onConfirm}) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            child: Text(l10n.skip_permission_confirm,
                style: const TextStyle(color: Colors.red)),
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
                    index: index,
                    icon: Icons.favorite,
                    title: l10n.permission_health_title,
                    description: l10n.permission_health_desc,
                    requestPermission: _requestHealthPermission,
                    checkPermission: _checkHealthPermission,
                    canSkip: false,
                  );
                case 1:
                  return _buildPermissionPage(
                    index: index,
                    icon: Icons.notifications,
                    title: l10n.permission_notification_title,
                    description: l10n.permission_notification_desc,
                    requestPermission: _requestNotificationPermission,
                    checkPermission: () =>
                        _checkSimplePermission(Permission.notification),
                    canSkip: true,
                    skipTitle: l10n.skip_notification_warning,
                    skipDesc: l10n.skip_notification_desc,
                  );
                case 2:
                  return _buildPermissionPage(
                    index: index,
                    icon: Icons.battery_charging_full,
                    title: l10n.permission_battery_title,
                    description: l10n.permission_battery_desc,
                    requestPermission: _requestBatteryPermission,
                    checkPermission: () => _checkSimplePermission(
                        Permission.ignoreBatteryOptimizations),
                    canSkip: true,
                    skipTitle: l10n.skip_battery_warning,
                    skipDesc: l10n.skip_battery_desc,
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

  Widget _buildPermissionPage(
      {required int index,
      required IconData icon,
      required String title,
      required String description,
      required Future<void> Function() requestPermission,
      required Future<bool> Function() checkPermission,
      bool canSkip = false,
      String? skipTitle,
      String? skipDesc}) {
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
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    if (!isGranted) ...[
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
                      if (canSkip)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextButton(
                            onPressed: () {
                              Future<void> performSkip() async {
                                if (index == 1) {
                                  await PreferenceService()
                                      .setSkipNotification(true);
                                } else if (index == 2) {
                                  await PreferenceService()
                                      .setSkipBattery(true);
                                }
                                _updatePageState();
                                _goToNextPage();
                              }

                              _showSkipWarningDialog(
                                title: skipTitle ?? l10n.skip_permission_title,
                                description: skipDesc ??
                                    l10n.skip_permission_description,
                                onConfirm: performSkip,
                              );
                            },
                            child: Text(l10n.skip_permission_label,
                                style: const TextStyle(color: Colors.grey)),
                          ),
                        ),
                    ],
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
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      shape: WidgetStateProperty.all(const StadiumBorder()),
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return colorScheme.onSurface.withAlpha(30);
                        }
                        if (_currentPage == _pageCount - 1) {
                          return Colors.green.shade600;
                        }
                        return colorScheme.primary;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return colorScheme.onSurface.withAlpha(97);
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
