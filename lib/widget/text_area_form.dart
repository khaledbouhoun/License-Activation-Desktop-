import 'package:flutter/material.dart';
import 'package:softel_control/core/constant/app_theme.dart';

/// Multi-line text area for notes
class TextAreaFormWidget extends StatelessWidget {
  const TextAreaFormWidget({
    super.key,
    required this.label,
    required this.ctrl,
    this.maxLength,
    this.validator,
    this.maxLines = 5,
    this.minLines = 3,
    this.isReadOnly = false,
  });

  final String label;
  final TextEditingController ctrl;
  final int? maxLength;
  final String? Function(String?)? validator;
  final int maxLines;
  final int minLines;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      maxLength: maxLength,
      readOnly: isReadOnly,

      // Multi-line settings
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: maxLines,
      minLines: minLines,

      // Important
      expands: false,

      style: const TextStyle(color: AppTheme.textPrimary),

      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.borderColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryBlue),
        ),
      ),
    );
  }
}
