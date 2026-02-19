import 'package:flutter/material.dart';
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

class EditSubscriptionDialog extends StatefulWidget {
  final SubscriptionModel subscription;

  const EditSubscriptionDialog({super.key, required this.subscription});

  @override
  State<EditSubscriptionDialog> createState() => _EditSubscriptionDialogState();
}

class _EditSubscriptionDialogState extends State<EditSubscriptionDialog> {
  final SubscriptionController controller = Get.find();
  final ClientController clientController = Get.find();
  final ApplicationController applicationController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController maxDevicesController = TextEditingController();
  int initialDurationMonths = 6;
  SubscriptionStatus status = SubscriptionStatus.current;
  SubscriptionActive isActive = SubscriptionActive.active;

  @override
  void initState() {
    super.initState();
    status = widget.subscription.status;
    isActive = widget.subscription.isActive;
    maxDevicesController.text = widget.subscription.maxDevices.toString();
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
                'Renew Subscription',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              TextFieldFormWidget(
                label: "Client",
                ctrl: TextEditingController(
                  text: widget.subscription.clientName,
                ),
                isNumeric: true,
                isReadOnly: true,
              ),
              TextFieldFormWidget(
                label: "Application",
                ctrl: TextEditingController(
                  text: widget.subscription.applicationName,
                ),
                isNumeric: true,
                isReadOnly: true,
              ),
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
              // active checkbox
              SwitchListTile(
                title: const Text("Active"),
                value: isActive == SubscriptionActive.active,
                onChanged: (val) => setState(
                  () => isActive = val
                      ? SubscriptionActive.active
                      : SubscriptionActive.inactive,
                ),
                activeThumbColor: Colors.white,
                activeTrackColor: AppTheme.accentGreen,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppTheme.errorRed.withValues(alpha: 0.5),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),

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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final subscription = widget.subscription.copyWith(
                          clientId: widget.subscription.clientId,
                          applicationId: widget.subscription.applicationId,
                          maxDevices:
                              int.tryParse(maxDevicesController.text) ?? 1,
                          duration: initialDurationMonths,
                          isActive: isActive,
                        );

                        Get.back();
                        await controller.addSubscription(subscription);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text('Save'),
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
