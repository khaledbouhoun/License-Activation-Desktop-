import 'dart:convert';
import 'package:get/get.dart';
import 'package:softel_control/core/functions/auth_post.dart';
import 'package:softel_control/data/model/license_model.dart';
import 'package:softel_control/data/model/subscription_model.dart';
import 'package:softel_control/linkapi.dart';

class LicenseController extends GetxController {
  late SubscriptionModel subscription;
  final RxList<LicenseModel> licenses = <LicenseModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['subscription'] != null) {
      subscription = Get.arguments['subscription'];
      loadLicenses();
    } else {
      Get.back();
      Get.snackbar("Error", "No subscription selected");
    }
  }

  Future<void> loadLicenses() async {
    try {
      isLoading.value = true;

      // We assume the API can filter by subscription_id
      var response = await authGet(
        "${AppLink.licenses}?subscription_id=${subscription.id}",
      );

      if (response.statusCode == 200) {
        dynamic responseBody = jsonDecode(response.body);
        List<dynamic> data = [];

        if (responseBody is Map && responseBody['data'] != null) {
          data = responseBody['data'];
        } else if (responseBody is List) {
          data = responseBody;
        }

        licenses.value = data
            .map((json) => LicenseModel.fromJson(json))
            .toList();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load licenses: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error loading licenses: $e");
      Get.snackbar(
        'Error',
        'Exception loading licenses: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeLicense(LicenseModel license) async {
    try {
      // Assuming endpoint exists for revoking a specific license
      var response = await authDelete("${AppLink.licenses}/${license.id}", {});

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'License Removed successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadLicenses();
      } else {
        Get.snackbar(
          'Error',
          'Failed to Remove: ${response.body}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Exception revoking license: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
