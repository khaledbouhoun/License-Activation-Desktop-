import 'package:softel_control/core/intialbindings.dart';
import 'package:softel_control/core/services/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MainScreen(),
    );
  }
}
