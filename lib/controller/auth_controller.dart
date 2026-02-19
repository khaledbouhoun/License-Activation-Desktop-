// lib/controllers/auth_controller.dart
import 'package:softel_control/core/services/services.dart';
import 'package:softel_control/core/constant/routesstr.dart';
import 'package:softel_control/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class AuthController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool hidePassword = true.obs;

  MyServices myServices = Get.find();

  // Show/Hide Password
  void showPassword() {
    hidePassword.value = !hidePassword.value;
  }

  // Login
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      var response = await http.post(
        Uri.parse(AppLink.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-DESKTOP-APP-KEY':
              AppLink.desktopAppKey, // If required for login too
        },
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['token'] != null) {
          String token = body['token'];
          // Save token
          await myServices.sharedPreferences.setString("token", token);
          // Save user info if needed
          if (body['user'] != null) {
            await myServices.sharedPreferences.setString(
              "user",
              jsonEncode(body['user']),
            );
          }

          Get.offAllNamed(AppRoute.mainScreen);
        } else {
          Get.snackbar(
            "Error",
            "Login failed: No token returned",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Login failed: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Exception: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
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
