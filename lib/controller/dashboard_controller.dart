import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/client_controller.dart';
import 'package:softel_control/controller/subscription_controller.dart';
import 'package:softel_control/controller/application_controller.dart';
import 'package:softel_control/core/functions/auth_post.dart';
import 'package:softel_control/data/model/license_model.dart';
import 'package:softel_control/linkapi.dart';

class DashboardController extends GetxController {
  // Current selected navigation index
  final RxInt selectedIndex = 0.obs;

  // Dashboard statistics
  final RxInt totalActiveLicenses = 0.obs;
  final RxInt nearExpiryLicenses = 0.obs;
  final RxInt newActivations = 0.obs;
  final RxInt totalClients = 0.obs;
  final RxInt totalApplications = 0.obs;
  final RxInt expiredSubscriptions = 0.obs;
  final RxDouble renewalRate = 0.0.obs;

  // Chart data - Monthly license activations (last 7 months)
  final RxList<double> monthlyActivations = <double>[].obs;
  // Chart data - subscriptions by app
  final RxList<double> appSubscriptionCounts = <double>[].obs;
  final RxList<String> appNames = <String>[].obs;
  // Subscription status distribution
  final RxInt statusCurrent = 0.obs;
  final RxInt statusWarning = 0.obs;
  final RxInt statusExpired = 0.obs;
  // Weekly activations (last 7 month)
  final RxList<double> monthlyActivationslicenses = <double>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Search query
  final RxString searchQuery = ''.obs;

  // Licencs
  final RxList<LicenseModel> licenses = <LicenseModel>[].obs;
  var selectedRoute = '/dashboard'.obs;

  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void onReady() {
    super.onReady();
    _loadDerivedStats();

    // Set up listeners for data changes in other controllers
    _setupDataListeners();
  }

  void _setupDataListeners() {
    final subCtrl = Get.isRegistered<SubscriptionController>()
        ? Get.find<SubscriptionController>()
        : null;
    final clientCtrl = Get.isRegistered<ClientController>()
        ? Get.find<ClientController>()
        : null;
    final appCtrl = Get.isRegistered<ApplicationController>()
        ? Get.find<ApplicationController>()
        : null;

    if (subCtrl != null) {
      ever(subCtrl.subscriptions, (_) => _loadDerivedStats());
    }
    if (clientCtrl != null) {
      ever(clientCtrl.clients, (_) => _loadDerivedStats());
    }
    if (appCtrl != null) {
      ever(appCtrl.applications, (_) => _loadDerivedStats());
    }
  }

  void _loadDerivedStats() {
    try {
      isLoading.value = true;

      // Derive from existing controllers instead of extra API call
      final subCtrl = Get.isRegistered<SubscriptionController>()
          ? Get.find<SubscriptionController>()
          : null;
      final clientCtrl = Get.isRegistered<ClientController>()
          ? Get.find<ClientController>()
          : null;
      final appCtrl = Get.isRegistered<ApplicationController>()
          ? Get.find<ApplicationController>()
          : null;

      if (subCtrl != null) {
        final subs = subCtrl.subscriptions;

        // Count by status using the model's status getter
        int current = 0, warning = 0, expired = 0;
        Map<String, int> appCounts = {};

        for (final sub in subs) {
          final statusName = sub.status.name;
          if (statusName == 'current') {
            current++;
          } else if (statusName == 'warning') {
            warning++;
          } else if (statusName == 'expired') {
            expired++;
          }

          appCounts[sub.applicationName] =
              (appCounts[sub.applicationName] ?? 0) + 1;
        }

        totalActiveLicenses.value = current;
        nearExpiryLicenses.value = warning;
        expiredSubscriptions.value = expired;
        statusCurrent.value = current;
        statusWarning.value = warning;
        statusExpired.value = expired;

        // Renewal rate
        final total = subs.length;
        renewalRate.value = total > 0 ? (current / total) * 100 : 0;

        // New activations (subscriptions created in last 30 days)
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        newActivations.value = subs
            .where((s) => s.createdAt.isAfter(thirtyDaysAgo))
            .length;

        // Top apps for bar chart (top 6)
        final sorted = appCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top = sorted.take(6).toList();
        appNames.value = top.map((e) => e.key).toList();
        appSubscriptionCounts.value = top
            .map((e) => e.value.toDouble())
            .toList();

        // Monthly line chart: group createdAt by month for last 7 months
        final now = DateTime.now();
        final monthly = List<double>.filled(7, 0);
        for (final sub in subs) {
          for (int i = 0; i < 7; i++) {
            final monthStart = DateTime(now.year, now.month - (6 - i), 1);
            final monthEnd = DateTime(now.year, now.month - (6 - i - 1), 1);
            if (sub.createdAt.isAfter(monthStart) &&
                sub.createdAt.isBefore(monthEnd)) {
              monthly[i]++;
              break;
            }
          }
        }
        monthlyActivations.value = monthly;
      } else {
        // Demo data if no subs loaded yet
        _applyDemoData();
      }

      totalClients.value = clientCtrl?.clients.length ?? 0;
      totalApplications.value = appCtrl?.applications.length ?? 0;

      // Weekly activations - simulate 7 month
      _computeMonthlyActivations();
    } catch (_) {
      _applyDemoData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLicence() async {
    try {
      isLoading.value = true;
      var response = await authGet(AppLink.licenses);

      if (response.statusCode == 200) {
        dynamic responseBody = jsonDecode(response.body);
        List<dynamic> data = [];
        if (responseBody is Map && responseBody['data'] != null) {
          data = responseBody['data'];
        } else if (responseBody is List) {
          data = responseBody;
        }

        licenses.value = data.map((e) => LicenseModel.fromJson(e)).toList();
      } else {
        Get.snackbar(
          "Error",
          "Failed to load applications: ${response.statusCode}",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Exception loading applications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _computeMonthlyActivations() async {
    await loadLicence();
    final now = DateTime.now();

    // Last 7 months
    final last7Months = List.generate(7, (i) {
      final date = DateTime(now.year, now.month - 6 + i, 1);
      return date;
    });

    // Count licenses per month
    monthlyActivationslicenses.value = last7Months.map((monthStart) {
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
      return licenses
          .where(
            (lic) =>
                lic.startDate != null &&
                lic.startDate!.isAfter(
                  monthStart.subtract(const Duration(seconds: 1)),
                ) &&
                lic.startDate!.isBefore(monthEnd.add(const Duration(days: 1))),
          )
          .length
          .toDouble();
    }).toList();
  }

  void _applyDemoData() {
    monthlyActivations.value = [12, 18, 14, 25, 22, 30, 27];
    appSubscriptionCounts.value = [15, 12, 9, 7, 5, 3];
    appNames.value = ['App A', 'App B', 'App C', 'App D', 'App E', 'App F'];
    monthlyActivationslicenses.value = [3, 7, 5, 9, 6, 11, 8];
    totalActiveLicenses.value = 87;
    nearExpiryLicenses.value = 14;
    newActivations.value = 23;
    totalClients.value = 42;
    totalApplications.value = 8;
    expiredSubscriptions.value = 5;
    statusCurrent.value = 87;
    statusWarning.value = 14;
    statusExpired.value = 5;
    renewalRate.value = 82.5;
  }

  List<String> get last7MonthLabels {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return List.generate(7, (i) {
      final m = DateTime(now.year, now.month - (6 - i), 1);
      return months[m.month - 1];
    });
  }

  List<String> get last7DayLabels {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return List.generate(7, (i) => days[(now.weekday - 7 + i) % 7]);
  }

  void changeNavigation(String route) {
    selectedRoute.value = route;
    switch (route) {
      case '/dashboard':
        selectedIndex.value = 0;
        // _loadDerivedStats();
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

  Future<void> refreshDashboard() async {
    isRefreshing.value = true;
    // Re-load subscriptions first so derived data is fresh
    if (Get.isRegistered<SubscriptionController>()) {
      await Get.find<SubscriptionController>().loadSubscriptions();
    }
    _loadDerivedStats();
    isRefreshing.value = false;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
