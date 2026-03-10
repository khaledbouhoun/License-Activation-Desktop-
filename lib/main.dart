import 'package:softel_control/core/intialbindings.dart';
import 'package:softel_control/core/services/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/view/auth/login_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowsInitialize();

  await initialServices();
  runApp(const MyApp());
}

Future<void> windowsInitialize() async {
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow(null, () async {
    await windowManager.maximize();
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.center();
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Softel Control",
      theme: AppTheme.darkTheme,
      initialBinding: InitialBindings(),
      defaultTransition: Transition.fade,
      locale: Locale('en', 'DZ'),
      home: LoginScreen(),
    );
  }
}
