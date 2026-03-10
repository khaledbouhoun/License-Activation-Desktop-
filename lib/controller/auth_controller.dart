// lib/controllers/auth_controller.dart
import 'package:softel_control/core/services/services.dart';
import 'package:softel_control/core/constant/routesstr.dart';
import 'package:softel_control/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:softel_control/main_screen.dart';

class AuthController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool hidePassword = true.obs;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  MyServices myServices = Get.find();

  // Show/Hide Password
  void showPassword() {
    hidePassword.value = !hidePassword.value;
  }

  // Login
  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      Get.offAll(MainScreen());
    }
  }

  // Logout
  Future<void> logout() async {
    isLoading.value = true;
    try {
      String? token = myServices.sharedPreferences.getString("token");
      if (token != null) {
        await http.post(
          Uri.parse(AppLink.logout),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'X-DESKTOP-APP-KEY': AppLink.desktopAppKey,
          },
        );
      }

      await myServices.sharedPreferences.remove("token");
      await myServices.sharedPreferences.remove("user");
      Get.offAllNamed(AppRoute.login);
    } catch (e) {
      print("Logout error: $e");
      // Force logout anyway
      await myServices.sharedPreferences.remove("token");
      Get.offAllNamed(AppRoute.login);
    } finally {
      isLoading.value = false;
    }
  }
}
