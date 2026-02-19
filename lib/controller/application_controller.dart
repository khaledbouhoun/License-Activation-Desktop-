import 'package:get/get.dart';
import 'package:softel_control/core/functions/auth_post.dart';
import 'package:softel_control/linkapi.dart';
import 'package:softel_control/data/model/application_model.dart';
import 'dart:convert';

class ApplicationController extends GetxController {
  final RxList<ApplicationModel> applications = <ApplicationModel>[].obs;
  final RxList<ApplicationModel> filteredApplications =
      <ApplicationModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  @override
  void onClose() {
    super.onClose();
    applications.close();
    filteredApplications.close();
    isLoading.close();
    searchQuery.close();
  }

  Future<void> loadApplications() async {
    try {
      isLoading.value = true;
      var response = await authGet(AppLink.applications);

      if (response.statusCode == 200) {
        dynamic responseBody = jsonDecode(response.body);
        List<dynamic> data = [];
        if (responseBody is Map && responseBody['data'] != null) {
          data = responseBody['data'];
        } else if (responseBody is List) {
          data = responseBody;
        }

        applications.value = data
            .map((e) => ApplicationModel.fromJson(e))
            .toList();
        filterApplications();
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

  void filterApplications() {
    if (searchQuery.value.isEmpty) {
      filteredApplications.value = applications;
    } else {
      filteredApplications.value = applications
          .where(
            (c) => (c.name).toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterApplications();
  }

  Future<void> addApplication(ApplicationModel application) async {
    try {
      var response = await authPost(AppLink.applications, application.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Application added");
        await loadApplications();
      } else {
        Get.snackbar("Error", "Failed to add application: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }

  Future<void> editApplication(ApplicationModel application) async {
    try {
      var response = await authPut(
        "${AppLink.applications}/${application.id}",
        application.toJson(),
      );
      if (response.statusCode == 200) {
        Get.snackbar("Success", "Application updated");
        await loadApplications();
      } else {
        Get.snackbar("Error", "Failed to update application: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }

  Future<void> deleteApplication(ApplicationModel application) async {
    try {
      var response = await authDelete(
        "${AppLink.applications}/${application.id}",
        {},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar("Success", "Application deleted");
        applications.removeWhere((c) => c.id == application.id);
        filterApplications();
      } else {
        Get.snackbar("Error", "Failed to delete application: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }
}
