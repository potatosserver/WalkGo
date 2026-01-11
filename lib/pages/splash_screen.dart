
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../services/permission_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissionsAndNavigate();
  }

  Future<void> _checkPermissionsAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(prefIsFirstLaunch) ?? true;

    if (isFirstLaunch) {
      await prefs.setBool(prefIsFirstLaunch, false);
      if (mounted) context.go('/welcome');
    } else {
      final hasPermissions = await PermissionService().hasAllPermissions();
      if (mounted) {
        if (hasPermissions) {
          context.go('/home');
        } else {
          context.go('/permission');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
