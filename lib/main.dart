import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/log_service.dart';
import 'package:walkgo/permission_handler_page.dart';
import 'package:walkgo/settings_page.dart';
import 'package:walkgo/theme_provider.dart';
import 'package:walkgo/welcome_page.dart';
import 'l10n/app_localizations.dart';

// --- Global Variable Keys ---
const String prefIsAuto = "is_auto_running";
const String prefBaseSteps = "base_steps";
const String prefOffset = "offset_steps";
const String prefInterval = "interval_minutes";
const String prefPermissionsGranted = "permissions_granted";
const String prefIsFirstLaunch = "is_first_launch";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// --- Background Service Setup ---

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'WalkGo Background Service', // title
    description:
        'WalkGo is simulating steps in the background...', // description
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'WalkGo',
      initialNotificationContent: 'Background service is running',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(autoStart: false, onForeground: onStart),
  );
}

// --- Background Core Logic (Separate Isolate) ---
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final Health health = Health();
  final LogService logService = LogService();
  await health.configure();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 60), (timer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(prefIsAuto) ?? false)) return;

    int intervalMins = prefs.getInt(prefInterval) ?? 15;
    int baseSteps = prefs.getInt(prefBaseSteps) ?? 500;
    int offset = prefs.getInt(prefOffset) ?? 50;

    int lastRun = prefs.getInt("last_run_timestamp") ?? 0;
    int nowMillis = DateTime.now().millisecondsSinceEpoch;

    if (nowMillis - lastRun < intervalMins * 60 * 1000) return;

    int randomJitter = Random().nextInt(offset * 2 + 1) - offset;
    int finalSteps = baseSteps + randomJitter;
    if (finalSteps < 0) finalSteps = 10;

    DateTime endTime = DateTime.now();
    DateTime startTime = endTime.subtract(Duration(minutes: intervalMins));

    try {
      bool success = await health.writeHealthData(
        value: finalSteps.toDouble(),
        type: HealthDataType.STEPS,
        startTime: startTime,
        endTime: endTime,
      );

      if (success) {
        await logService.addLog({
          'steps': finalSteps,
          'type': 'automatic', // 'automatic' or 'manual'
        });

        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        flutterLocalNotificationsPlugin.show(
          123,
          'WalkGo Steps Update',
          'Wrote $finalSteps steps',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'WalkGo Background Service',
              icon: 'ic_bg_service_small',
              ongoing: false,
            ),
          ),
        );

        await prefs.setInt("last_run_timestamp", nowMillis);
      }
    } catch (e) {
      debugPrint("[Background Error] Error writing steps: $e");
    }
  });
}


// --- UI Interface ---

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null && languageCode.isNotEmpty) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WalkGo',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.themeMode,
          locale: _locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
          routes: {
            '/': (context) => const InitialPage(),
            '/home': (context) => const HomePage(),
            '/welcome': (context) => const WelcomePage(),
            '/permission': (context) => const PermissionHandlerPage(),
          },
        );
      },
    );
  }
}

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool(prefIsFirstLaunch) ?? true;

    if (isFirstLaunch) {
      return '/welcome';
    }

    final bool permissionsGranted =
        prefs.getBool(prefPermissionsGranted) ?? false;
    if (!permissionsGranted) {
      return '/permission';
    }

    return '/home';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(snapshot.data!);
          });
        } else {
          // Handle error case, maybe navigate to a default error page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Health health = Health();
  final LogService _logService = LogService();

  bool _isAutoRunning = false;
  String _statusLog = "";

  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _offsetController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We need to update the status log here because the locale might have changed.
    _updateStatusLogText();
  }

  void _updateStatusLogText() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (_isAutoRunning) {
        _statusLog = l10n.status_running;
      } else {
        _statusLog = l10n.status_ready_to_start;
      }
    });
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _stepsController.text = (prefs.getInt(prefBaseSteps) ?? 500).toString();
      _offsetController.text = (prefs.getInt(prefOffset) ?? 50).toString();
      _intervalController.text = (prefs.getInt(prefInterval) ?? 15).toString();
      _isAutoRunning = prefs.getBool(prefIsAuto) ?? false;
    });
    _updateStatusLogText();
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      prefBaseSteps,
      int.tryParse(_stepsController.text) ?? 500,
    );
    await prefs.setInt(prefOffset, int.tryParse(_offsetController.text) ?? 50);
    await prefs.setInt(
      prefInterval,
      int.tryParse(_intervalController.text) ?? 15,
    );
  }

  void _updateStatus(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _statusLog = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).snackBarTheme.backgroundColor,
      ),
    );
  }

  Future<void> _manualAdd() async {
    final l10n = AppLocalizations.of(context)!;
    await _saveSettings();
    int steps = int.tryParse(_stepsController.text) ?? 0;
    if (steps <= 0) {
      _updateStatus(l10n.steps_gt_zero, isError: true);
      return;
    }

    DateTime now = DateTime.now();
    try {
      bool success = await health.writeHealthData(
        value: steps.toDouble(),
        type: HealthDataType.STEPS,
        startTime: now.subtract(const Duration(minutes: 5)),
        endTime: now,
      );

      if (success) {
        final successMessage = l10n.manual_write_success(steps);
        _updateStatus(successMessage);
        await _logService.addLog({
          'steps': steps,
          'type': 'manual',
        });
      } else {
        _updateStatus(l10n.write_fail_check_log);
      }
    } catch (e) {
      _updateStatus(
        l10n.write_error(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _toggleAutoMode(bool enable) async {
    final l10n = AppLocalizations.of(context)!;
    await _saveSettings();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefIsAuto, enable);

    final service = FlutterBackgroundService();

    if (enable) {
      await service.startService();
      _updateStatus(l10n.background_service_start);
    } else {
      service.invoke("stopService");
      _updateStatus(l10n.background_service_stop);
    }

    setState(() {
      _isAutoRunning = enable;
    });
    _updateStatusLogText();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.walkgo),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            tooltip: l10n.settings_tooltip,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 24),
              _buildControlPanel(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final colorScheme = Theme.of(context).colorScheme;
    Color cardColor = _isAutoRunning
        ? Colors.green.shade100
        : colorScheme.surfaceContainerHighest;
    Color contentColor = _isAutoRunning
        ? Colors.green.shade900
        : colorScheme.onSurfaceVariant;
    IconData icon = _isAutoRunning ? Icons.sync : Icons.check_circle_outline;

    return Card(
      elevation: 2.0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 50, color: contentColor),
            const SizedBox(height: 10),
            Text(
              _statusLog,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.param_settings,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _stepsController,
          l10n.base_steps,
          l10n.base_steps_hint,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _offsetController,
          l10n.offset_steps,
          l10n.offset_steps_hint,
        ),
        const SizedBox(height: 16),
        _buildTextField(_intervalController, l10n.interval, l10n.interval_hint),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.touch_app),
          label: Text(l10n.manual_write_once),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _manualAdd,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(
            _isAutoRunning
                ? Icons.stop_circle_outlined
                : Icons.play_circle_outline,
          ),
          label: Text(
            _isAutoRunning ? l10n.stop_auto_steps : l10n.start_auto_steps,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: _isAutoRunning
                ? Colors.red.shade700
                : Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _toggleAutoMode(!_isAutoRunning),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String helper,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
      ),
      onChanged: (_) => _saveSettings(),
    );
  }
}
