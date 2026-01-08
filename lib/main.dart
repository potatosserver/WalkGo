import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkgo/app_widget.dart';
import 'package:walkgo/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool(prefIsFirstLaunch) ?? true;

  if (isFirstLaunch) {
    await prefs.setBool(prefIsFirstLaunch, false);
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}
