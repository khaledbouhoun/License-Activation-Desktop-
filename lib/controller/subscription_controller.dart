import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/application_controller.dart';
import 'package:softel_control/controller/client_controller.dart';
import 'package:softel_control/data/model/application_model.dart';
import 'package:softel_control/data/model/client_model.dart';
import 'package:softel_control/data/model/subscription_model.dart';
import 'package:softel_control/core/functions/auth_post.dart';
import 'package:softel_control/linkapi.dart';
import 'package:softel_control/view/license/license_view.dart';
import 'dart:convert';

class SubscriptionController extends GetxController {
  // Subscriptions list

  ClientController clientController = Get.find<ClientController>();
  ApplicationController applicationController =
      Get.find<ApplicationController>();
  final RxList<SubscriptionModel> subscriptions = <SubscriptionModel>[].obs;
  final RxList<SubscriptionModel> filteredSubscriptions =
      <SubscriptionModel>[].obs;

  // Client
  Rx<ClientModel?> clientSelcted = Rx<ClientModel?>(null);
  Rx<ApplicationModel?> applicationSelcted = Rx<ApplicationModel?>(null);

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 10;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  // Filter and sort
  final RxString filterStatus = 'All'.obs;
  final RxString sortBy = 'date'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubscriptions();

    // Add workers to apply filters when selection changes
    ever(clientSelcted, (_) => applyFilters());
    ever(applicationSelcted, (_) => applyFilters());
    ever(filterStatus, (_) => applyFilters());
    ever(sortBy, (_) => applyFilters());
  }

  // Load subscriptions
  Future<void> loadSubscriptions() async {
    try {
      isLoading.value = true;

      // Real API call
      var response = await authGet(AppLink.subscriptions);

      if (response.statusCode == 200) {
        dynamic responseBody = jsonDecode(response.body);
        // Assuming Laravel returns { "success": true, "data": [...] } or just [...]
        // Adjust based on typical Laravel resource response.

        List<dynamic> data = [];
        if (responseBody is Map && responseBody['data'] != null) {
          data = responseBody['data'];
        } else if (responseBody is List) {
          data = responseBody;
        }

        subscriptions.value = data
            .map((json) => SubscriptionModel.fromJson(json))
            .toList();
        applyFilters();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load subscriptions: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error loading subscriptions: $e");
      Get.snackbar(
        'Error',
        'Exception loading subscriptions: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filters
  void applyFilters() {
    var filtered = subscriptions.toList();

    // Filter by status
    if (filterStatus.value != 'All') {
      filtered = filtered
          .where((sub) => sub.status.name == filterStatus.value)
          .toList();
    }

    // Filter by client
    if (clientSelcted.value != null) {
      filtered = filtered
          .where((sub) => sub.clientId == clientSelcted.value!.id)
          .toList();
    }

    // Filter by application
    if (applicationSelcted.value != null) {
      filtered = filtered
          .where((sub) => sub.applicationId == applicationSelcted.value!.id)
          .toList();
    }

    // Sort
    if (sortBy.value == 'date') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortBy.value == 'expiry') {
      filtered
          .where((sub) => sub.expiryDate != null)
          .toList()
          .sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
    } else if (sortBy.value == 'name') {
      filtered.sort((a, b) => a.clientName.compareTo(b.clientName));
    }

    filteredSubscriptions.value = filtered;
    totalPages.value = (filtered.length / itemsPerPage).ceil();
  }

  // Change filter status
  void changeFilterStatus(String status) {
    filterStatus.value = status;
    applyFilters();
  }

  // Change sort
  void changeSortBy(String sort) {
    sortBy.value = sort;
    applyFilters();
  }

  // Get paginated subscriptions
  List<SubscriptionModel> getPaginatedSubscriptions() {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(
      0,
      filteredSubscriptions.length,
    );

    if (startIndex >= filteredSubscriptions.length) {
      return [];
    }

    return filteredSubscriptions.sublist(startIndex, endIndex);
  }

  // Change page
  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  }

  // Generate license key
  Future<void> generateLicenseKey(SubscriptionModel subscription) async {
    try {
      // API call to generate license
      var response = await authPost(AppLink.subscriptionGenerateLicense, {
        "subscription_id": subscription.id,
      });

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'License key generated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadSubscriptions();
      } else {
        Get.snackbar(
          'Error',
          'Failed to generate: ${response.body}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Exception generating license key: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Copy license key
  void copyLicenseKey(String licenseKey) {
    Clipboard.setData(ClipboardData(text: licenseKey));
    Get.snackbar(
      'Success',
      'License key copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openLicenses(SubscriptionModel subscription) {
    Get.to(LicensesView(), arguments: {"subscription": subscription});
  }

  // Add Subscription
  Future<void> addSubscription(SubscriptionModel subscription) async {
    try {
      var response = await authPost(
        AppLink.subscriptions,
        subscription.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Subscription added",
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadSubscriptions();
      } else {
        Get.snackbar(
          "Error",
          "Failed to add: ${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Exception: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Edit Subscription
  Future<void> editSubscription(
    SubscriptionModel subscription, {
    bool loadSubscription = true,
  }) async {
    try {
      var response = await authPut(
        "${AppLink.subscriptions}/${subscription.id}",
        subscription.toJson(),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Subscription updated",
          snackPosition: SnackPosition.BOTTOM,
        );
        if (loadSubscription) await loadSubscriptions();
      } else {
        Get.snackbar(
          "Error",
          "Failed to update: ${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Exception: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {}
  }

  // Delete subscription
  Future<void> deleteSubscription(SubscriptionModel subscription) async {
    try {
      // API Call
      var response = await authDelete(
        "${AppLink.subscriptions}/${subscription.id}",
        {},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        subscriptions.removeWhere((sub) => sub.id == subscription.id);
        applyFilters();

        Get.snackbar(
          'Success',
          'Subscription deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Exception deleting subscription: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
