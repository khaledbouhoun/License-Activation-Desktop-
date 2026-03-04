import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/auth_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui'; // For ImageFilter

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(AuthController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.borderColor.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                          ).animate().scale(
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),

                          const SizedBox(height: 24),

                          // Title
                          Text(
                                'Softel Control',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: 1.5,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .moveY(begin: 10, end: 0),

                          const SizedBox(height: 8),

                          Text(
                            'Admin Authentication',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ).animate().fadeIn(delay: 300.ms),

                          const SizedBox(height: 40),

                          // Password Field
                          Obx(
                                () => _buildTextField(
                                  controllerText: controller.passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: controller.hidePassword.value,
                                  onToggleVisibility: controller.showPassword,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 500.ms)
                              .moveX(begin: -20, end: 0),

                          // Obx(
                          //       () => _buildTextField(
                          //         controller: controller.passwordController,
                          //         label: 'Password',
                          //         icon: Icons.lock_outline,
                          //         isPassword: true,
                          //         obscureText: controller.hidePassword.value,
                          //         onToggleVisibility: controller.showPassword,
                          //       ),
                          //     )
                          //     .animate()
                          //     .fadeIn(delay: 500.ms)
                          //     .moveX(begin: -20, end: 0),
                          const SizedBox(height: 40),

                          // Login Button
                          Obx(
                                () => InkWell(
                                  onTap: controller.isLoading.value
                                      ? null
                                      : () => controller.login(),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: controller.isLoading.value
                                          ? LinearGradient(
                                              colors: [
                                                Colors.grey,
                                                Colors.grey.shade700,
                                              ],
                                            )
                                          : AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryBlue
                                              .withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'LOGIN',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 600.ms)
                              .moveY(begin: 20, end: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controllerText,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.toLowerCase() != "softel2026") {
            return 'Incorrect password';
          }
          return null;
        },
        onFieldSubmitted: (value) {
          controllerText.text = value;
        },
        controller: controllerText,
        obscureText: obscureText,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textTertiary),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
