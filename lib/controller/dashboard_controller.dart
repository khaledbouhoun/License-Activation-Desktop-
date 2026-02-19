import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/client_controller.dart';
import 'package:softel_control/controller/subscription_controller.dart';
import 'package:softel_control/controller/application_controller.dart';
import 'package:softel_control/core/functions/auth_post.dart';
import 'package:softel_control/linkapi.dart';
import 'dart:convert';

class DashboardController extends GetxController {
  // Current selected navigation index
  final RxInt selectedIndex = 0.obs;

  // Dashboard statistics
  final RxInt totalActiveLicenses = 0.obs;
  final RxInt nearExpiryLicenses = 0.obs;
  final RxInt newActivations = 0.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Search query
  final RxString searchQuery = ''.obs;

  var selectedRoute = '/dashboard'.obs;

  final navigatorKey = GlobalKey<NavigatorState>();

  void changeNavigation(String route) {
    selectedRoute.value = route;
    switch (route) {
      case '/dashboard':
        selectedIndex.value = 0;
        break;
      case '/subscriptions':
        selectedIndex.value = 1;
        if (Get.isRegistered<SubscriptionController>()) {
          Get.find<SubscriptionController>().loadSubscriptions();
        }
        break;
      case '/clients':
        selectedIndex.value = 2;
        if (Get.isRegistered<ClientController>()) {
          Get.find<ClientController>().loadClients();
        }
        break;
      case '/applications':
        selectedIndex.value = 3;
        if (Get.isRegistered<ApplicationController>()) {
          Get.find<ApplicationController>().loadApplications();
        }
        break;
      case '/devices':
        selectedIndex.value = 4;
        break;
      case '/settings':
        selectedIndex.value = 5;
        break;
    }
  }

  // Change navigation
  // void changeNavigation(int index) {
  //   selectedIndex.value = index;
  // }

  // Load dashboard statistics
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Real API call
      // var response = await authGet(AppLink.dashboardStats);
      var response;
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Assuming data structure
        totalActiveLicenses.value = data['total_active'] ?? 0;
        nearExpiryLicenses.value = data['near_expiry'] ?? 0;
        newActivations.value = data['new_activations'] ?? 0;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh dashboard
  Future<void> refreshDashboard() async {
    isRefreshing.value = true;
    await loadDashboardData();
    isRefreshing.value = false;
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
