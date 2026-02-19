import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:softel_control/core/constant/app_theme.dart';

class TextFieldFormWidget extends StatelessWidget {
  const TextFieldFormWidget({
    super.key,
    required this.label,
    required this.ctrl,
    this.isNumeric = false,
    this.validator,
    this.maxLength,
    this.isReadOnly = false,
  });
  final String label;
  final TextEditingController ctrl;
  final bool isNumeric;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      maxLength: maxLength,
      readOnly: isReadOnly,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        isNumeric
            ? FilteringTextInputFormatter.digitsOnly
            : FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z0-9@. ]')),
      ],
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryBlue),
        ),
      ),
    );
  }
}
