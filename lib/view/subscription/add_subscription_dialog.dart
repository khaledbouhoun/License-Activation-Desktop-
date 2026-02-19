import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/application_controller.dart';
import 'package:softel_control/controller/client_controller.dart';
import 'package:softel_control/controller/subscription_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/data/model/client_model.dart';
import 'package:softel_control/data/model/subscription_model.dart';
import 'package:softel_control/data/model/application_model.dart';
import 'package:softel_control/widget/durationselector.dart';
import 'package:softel_control/widget/textFeildForm.dart';

class AddEditSubscriptionDialog extends StatefulWidget {
  const AddEditSubscriptionDialog({super.key});

  @override
  State<AddEditSubscriptionDialog> createState() =>
      _AddEditSubscriptionDialogState();
}

class _AddEditSubscriptionDialogState extends State<AddEditSubscriptionDialog> {
  final SubscriptionController controller = Get.find();
  final ClientController clientController = Get.find();
  final ApplicationController applicationController = Get.find();
  SubscriptionModel? editableSubscription;
  ClientModel? selectedClient;
  ApplicationModel? selectedApplication;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController maxDevicesController = TextEditingController();
  int initialDurationMonths = 6;
  SubscriptionStatus status = SubscriptionStatus.current;
  SubscriptionActive isActive = SubscriptionActive.active;

  @override
  void initState() {
    super.initState();

    editableSubscription = SubscriptionModel(
      id: 0,
      clientId: 0,
      clientName: '',
      applicationId: 0,
      applicationName: '',
      licenseKey: '',
      maxDevices: 0,
      duration: 0,
      startDate: DateTime.now(),
      expiryDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: SubscriptionActive.active,
      licensesCount: 0,
    );
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
          key: _formKey,
          child: Column(
            spacing: 22,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Subscription',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              _buildClientDropdown(),
              _buildApplicationDropdown(),
              TextFieldFormWidget(
                label: "Max Devices",
                ctrl: maxDevicesController,
                isNumeric: true,
              ),
              DurationSelector(
                initialMonths: initialDurationMonths,
                onChanged: (months) {
                  initialDurationMonths = months;
                },
              ),

              const SizedBox(height: 16),

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
                      if (_formKey.currentState!.validate()) {
                        final subscription = editableSubscription!.copyWith(
                          clientId: selectedClient!.id,
                          applicationId: selectedApplication!.id,
                          maxDevices:
                              int.tryParse(maxDevicesController.text) ?? 5,
                          duration: initialDurationMonths,
                          isActive: isActive,
                        );

                        controller.addSubscription(subscription);
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
                    child: Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientDropdown() {
    return DropdownButtonFormField<ClientModel>(
      decoration: InputDecoration(
        labelText: "Client",
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      dropdownColor: AppTheme.surfaceLight,
      style: const TextStyle(color: AppTheme.textPrimary),
      items: clientController.clients.map((client) {
        return DropdownMenuItem(value: client, child: Text(client.name));
      }).toList(),
      onChanged: (val) => setState(() => selectedClient = val!),
    );
  }

  Widget _buildApplicationDropdown() {
    return DropdownButtonFormField<ApplicationModel>(
      decoration: InputDecoration(
        labelText: "Application",
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      dropdownColor: AppTheme.surfaceLight,
      style: const TextStyle(color: AppTheme.textPrimary),
      items: applicationController.applications.map((app) {
        return DropdownMenuItem(value: app, child: Text(app.name));
      }).toList(),
      onChanged: (val) => setState(() => selectedApplication = val!),
    );
  }
}
