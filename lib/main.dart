import 'package:softel_control/core/intialbindings.dart';
import 'package:softel_control/core/services/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/view/auth/login_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize the plugin first
  await windowManager.ensureInitialized();

  // 3. Set options WITHOUT complex alignments first,
  // or handle the window manually to avoid the Null subtype error.
  windowManager.waitUntilReadyToShow(null, () async {
    // 1. Maximize first
    await windowManager.maximize();
    // 2. Hide the default system title bar to allow custom coloring
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    // 3. Prevent the user from resizing it back down
    // await windowManager.setResizable(false);

    await windowManager.center();
    await windowManager.show();
    await windowManager.focus();
  });
  await initialServices();
  runApp(const MyApp());
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
