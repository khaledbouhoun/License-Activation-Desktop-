import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/client_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/data/model/client_model.dart';
import 'package:softel_control/widget/textFeildForm.dart';

class AddEditClientDialog extends StatefulWidget {
  final ClientModel? client;

  const AddEditClientDialog({super.key, this.client});

  @override
  State<AddEditClientDialog> createState() => _AddEditClientDialogState();
}

class _AddEditClientDialogState extends State<AddEditClientDialog> {
  final ClientController controller = Get.find();
  late ClientModel editableClient;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // If editing, use existing client; otherwise create new one
    editableClient =
        widget.client ??
        ClientModel(
          id: 0,
          name: '',
          email: '',
          phone: '',
          address: '',
          createdAt: DateTime.now(),
        );

    // Populate text fields
    clientNameController.text = editableClient.name;
    emailController.text = editableClient.email;
    phoneController.text = editableClient.phone;
    addressController.text = editableClient.address;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
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
                widget.client == null ? 'Add Client' : 'Edit Client',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextFieldFormWidget(
                label: "Client Name",
                ctrl: clientNameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Client name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFieldFormWidget(label: "Email", ctrl: emailController),
              const SizedBox(height: 20),
              TextFieldFormWidget(
                label: "Phone",
                ctrl: phoneController,
                validator: (value) {
                  if (value!.length > 15) {
                    return 'Phone number must be less than 15 characters';
                  }
                  return null;
                },
                isNumeric: true,
              ),
              const SizedBox(height: 20),
              TextFieldFormWidget(label: "Address", ctrl: addressController),
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
                        final updatedClient = editableClient.copyWith(
                          name: clientNameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          address: addressController.text,
                        );

                        if (widget.client == null) {
                          controller.addClient(updatedClient);
                        } else {
                          controller.editClient(updatedClient);
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
                    child: Text(widget.client == null ? 'Add' : 'Save'),
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
