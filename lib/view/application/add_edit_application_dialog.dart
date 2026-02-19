import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/application_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/data/model/application_model.dart';
import 'package:softel_control/widget/textFeildForm.dart';

class AddEditApplicationDialog extends StatefulWidget {
  final ApplicationModel? application;

  const AddEditApplicationDialog({super.key, this.application});

  @override
  State<AddEditApplicationDialog> createState() =>
      _AddEditApplicationDialogState();
}

class _AddEditApplicationDialogState extends State<AddEditApplicationDialog> {
  final ApplicationController controller = Get.find();
  late ApplicationModel editableApplication;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    editableApplication =
        widget.application ??
        ApplicationModel(id: 0, name: '', createdAt: DateTime.now());

    nameController.text = editableApplication.name;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.application == null
                    ? 'Add Application'
                    : 'Edit Application',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextFieldFormWidget(
                label: "Application Name",
                ctrl: nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Application name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // ✅ Use copyWith instead of mutating directly
                        final updatedApplication = editableApplication.copyWith(
                          name: nameController.text,
                        );

                        if (widget.application == null) {
                          controller.addApplication(updatedApplication);
                        } else {
                          controller.editApplication(updatedApplication);
                        }
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(widget.application == null ? 'Add' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
