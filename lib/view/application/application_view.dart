import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/application_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/data/model/application_model.dart';
import 'package:softel_control/view/application/add_edit_application_dialog.dart';

class ApplicationView extends GetView<ApplicationController> {
  const ApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized if not already found (optional if using bindings)
    // Get.put(ApplicationController());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Applications",
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
                    builder: (_) => const AddEditApplicationDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Application"),
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
              if (controller.applications.isEmpty) {
                return const Center(
                  child: Text(
                    "No applications found",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }

              return ListView.separated(
                itemCount: controller.applications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final application = controller.applications[index];
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
                          child: Text(
                            application.name.isNotEmpty
                                ? application.name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
                              builder: (_) => AddEditApplicationDialog(
                                application: application,
                              ),
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
                            builder: (_) => _dialogConfirmDelete(application),
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

  AlertDialog _dialogConfirmDelete(ApplicationModel application) {
    return AlertDialog(
      title: const Text("Delete Application"),
      content: const Text("Are you sure you want to delete this application?"),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            controller.deleteApplication(application);
            Get.back();
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
