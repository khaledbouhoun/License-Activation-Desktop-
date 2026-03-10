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
import 'package:url_launcher/url_launcher.dart';

class SubscriptionController extends GetxController {
  // Subscriptions list

  ClientController clientController = Get.find<ClientController>();
  ApplicationController applicationController =
      Get.find<ApplicationController>();
  final RxList<SubscriptionModel> subscriptions = <SubscriptionModel>[].obs;
  final RxList<SubscriptionModel> filteredSubscriptions =
      <SubscriptionModel>[].obs;

  // Selection
  final RxList<int> selectedIds = <int>[].obs;

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

  // Selection Methods
  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void selectAll(bool select) {
    if (select) {
      selectedIds.assignAll(getPaginatedSubscriptions().map((sub) => sub.id));
    } else {
      selectedIds.clear();
    }
  }

  bool isSelected(int id) => selectedIds.contains(id);

  // Load subscriptions
  Future<void> loadSubscriptions() async {
    try {
      isLoading.value = true;
      selectedIds.clear();

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

    // Clear selection if current items are not in filtered list
    // (Optional: depending on desired UX)
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
      // selectedIds.clear(); // Optional: clear selection on page change
    }
  }

  // Communication Methods
  Future<void> sendWhatsAppReminder(SubscriptionModel sub) async {
    if (sub.clientPhone.isEmpty) {
      Get.snackbar('Error', 'Client has no phone number');
      return;
    }

    String message =
        "Hello ${sub.clientName}, 👋\n\n"
        "This is a friendly reminder about your *${sub.applicationName}* subscription.\n\n"
        "Status: ${sub.status == SubscriptionStatus.expired ? '❌ Expired' : '⚠️ Expiring Soon'}\n"
        "Expiry Date: ${sub.formattedExpiryDate}\n"
        "Days Remaining: ${sub.daysUntilExpiry}\n\n"
        "Please contact us to renew your subscription.\n\n"
        "Thank you! 😊";

    final Uri whatsappUri = Uri.parse(
      "whatsapp://send?phone=${sub.clientPhone}&text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      final Uri webUri = Uri.parse(
        "https://wa.me/${sub.clientPhone}?text=${Uri.encodeComponent(message)}",
      );

      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not launch WhatsApp');
      }
    }
  }

  Future<void> sendEmailReminder(SubscriptionModel sub) async {
    if (sub.clientEmail.isEmpty) {
      Get.snackbar('Error', 'Client has no email');
      return;
    }

    String subject = "🔔 Subscription Renewal - ${sub.applicationName}";

    String body =
        "Hello ${sub.clientName},\n\n"
        "We hope you're doing well! 😊\n\n"
        "This is a friendly reminder that your subscription for **${sub.applicationName}** is "
        "${sub.status == SubscriptionStatus.expired ? '❌ expired' : '⏳ expiring soon'}.\n\n"
        "📌 **Subscription Details:**\n"
        "- **Application:** ${sub.applicationName}\n"
        "- **License Key:** ${sub.licenseKey}\n"
        "- **Expiry Date:** ${sub.formattedExpiryDate}\n"
        "- **Days Remaining:** ${sub.daysUntilExpiry}\n\n"
        "To avoid any interruption in service, please renew your subscription at your earliest convenience. 🔄\n\n"
        "Thank you for choosing Softel! 🙏\n\n"
        "Best regards,\n"
        "💼 Softel Support Team";

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: sub.clientEmail,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      Get.snackbar('Error', 'Could not launch Email client');
    }
  }

  Future<void> sendBulkWhatsApp() async {
    List<SubscriptionModel> targets = [];

    if (selectedIds.isNotEmpty) {
      targets = subscriptions.where((s) => selectedIds.contains(s.id)).toList();
    } else {
      // If none selected, target all in 'warning' or 'expired' status from filtered list
      targets = filteredSubscriptions
          .where(
            (s) =>
                s.status == SubscriptionStatus.warning ||
                s.status == SubscriptionStatus.expired,
          )
          .toList();
    }

    if (targets.isEmpty) {
      Get.snackbar('Info', 'No subscriptions identified for reminder');
      return;
    }

    // Since launching many URLs at once is problematic, we'll suggest processing one by one or confirm
    Get.defaultDialog(
      title: "Send WhatsApp Reminders",
      middleText: "Send reminders to ${targets.length} clients?",
      textConfirm: "Yes",
      textCancel: "Cancel",
      onConfirm: () async {
        Get.back();
        for (var sub in targets) {
          await sendWhatsAppReminder(sub);
          // Small delay to allow browser/app to breathe
          await Future.delayed(Duration(milliseconds: 1500));
        }
      },
    );
  }

  Future<void> sendBulkEmail() async {
    List<SubscriptionModel> targets = [];

    if (selectedIds.isNotEmpty) {
      targets = subscriptions.where((s) => selectedIds.contains(s.id)).toList();
    } else {
      targets = filteredSubscriptions
          .where(
            (s) =>
                s.status == SubscriptionStatus.warning ||
                s.status == SubscriptionStatus.expired,
          )
          .toList();
    }

    if (targets.isEmpty) {
      Get.snackbar('Info', 'No subscriptions identified for reminder');
      return;
    }

    Get.defaultDialog(
      title: "Send Email Reminders",
      middleText: "Send reminders to ${targets.length} clients?",
      textConfirm: "Yes",
      textCancel: "Cancel",
      onConfirm: () async {
        Get.back();
        for (var sub in targets) {
          await sendEmailReminder(sub);
          await Future.delayed(Duration(milliseconds: 1000));
        }
      },
    );
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

  void openLicenses(SubscriptionModel subscription) async {
    int licenceCount = await Get.to(
      () => LicensesView(),
      arguments: {"subscription": subscription},
      transition: Transition.rightToLeftWithFade,

      duration: Duration(milliseconds: 300),
    );

    subscription.licensesCount.value = licenceCount;
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
