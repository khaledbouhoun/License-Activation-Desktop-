import 'package:get/get.dart';
import 'package:softel_control/core/functions/auth_post.dart';
import 'package:softel_control/linkapi.dart';
import 'package:softel_control/data/model/client_model.dart';
import 'dart:convert';

class ClientController extends GetxController {
  final RxList<ClientModel> clients = <ClientModel>[].obs;
  final RxList<ClientModel> filteredClients = <ClientModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 10;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  @override
  void onClose() {
    super.onClose();

    clients.close();
    filteredClients.close();
    isLoading.close();
    searchQuery.close();
    currentPage.close();
    totalPages.close();
  }

  Future<void> loadClients() async {
    try {
      isLoading.value = true;
      var response = await authGet(AppLink.clients);

      if (response.statusCode == 200) {
        dynamic responseBody = jsonDecode(response.body);
        List<dynamic> data = [];
        if (responseBody is Map && responseBody['data'] != null) {
          data = responseBody['data'];
        } else if (responseBody is List) {
          data = responseBody;
        }

        clients.value = data.map((e) => ClientModel.fromJson(e)).toList();
        filterClients();
      } else {
        Get.snackbar("Error", "Failed to load clients: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception loading clients: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterClients() {
    if (searchQuery.value.isEmpty) {
      filteredClients.value = clients;
    } else {
      filteredClients.value = clients
          .where(
            (c) => (c.id.toString() + c.name + c.phone).toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }
    totalPages.value = (filteredClients.length / itemsPerPage).ceil();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterClients();
  }

  List<ClientModel> getPaginatedClients() {
    int start = (currentPage.value - 1) * itemsPerPage;
    int end = (start + itemsPerPage).clamp(0, filteredClients.length);
    if (start >= filteredClients.length) return [];
    return filteredClients.sublist(start, end);
  }

  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  }

  Future<void> addClient(ClientModel client) async {
    try {
      var response = await authPost(AppLink.clients, client.toJson());
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Client added");
        await loadClients();
      } else {
        Get.snackbar("Error", "Failed to add client: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }

  Future<void> editClient(ClientModel client) async {
    try {
      var response = await authPut(
        "${AppLink.clients}/${client.id}",
        client.toJson(),
      );
      if (response.statusCode == 200) {
        Get.snackbar("Success", "Client updated");
        await loadClients();
      } else {
        Get.snackbar("Error", "Failed to update client: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }

  Future<void> deleteClient(ClientModel client) async {
    try {
      var response = await authDelete("${AppLink.clients}/${client.id}", {});
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar("Success", "Client deleted");
        clients.removeWhere((c) => c.id == client.id);
        filterClients();
      } else {
        Get.snackbar("Error", "Failed to delete client: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }
}
