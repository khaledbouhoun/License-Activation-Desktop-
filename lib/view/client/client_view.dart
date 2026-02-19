import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/client_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/data/model/client_model.dart';
import 'package:softel_control/view/client/add_edit_client_dialog.dart';

class ClientView extends GetView<ClientController> {
  const ClientView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Clients",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddEditClientDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Client"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.clients.isEmpty) {
                return const Center(
                  child: Text(
                    "No clients found",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }

              return ListView.separated(
                itemCount: controller.clients.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final client = controller.clients[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue,
                          child: Text(client.name[0]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                client.email,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          client.phone,
                          style: const TextStyle(color: AppTheme.textTertiary),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  AddEditClientDialog(client: client),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppTheme.errorRed,
                          ),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => _dialogConfirmDelete(client),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  AlertDialog _dialogConfirmDelete(ClientModel client) {
    return AlertDialog(
      title: const Text("Delete Client"),
      content: const Text("Are you sure you want to delete this client?"),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteClient(client);
          },
          child: const Text(
            "Delete",
            style: TextStyle(color: AppTheme.errorRed),
          ),
        ),
      ],
    );
  }
}
