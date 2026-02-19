import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/auth_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';

class SettingsView extends GetView<AuthController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure AuthController is available (it is because we injected it)
    // Actually MainScreen binds DashboardController. AuthController might need to be retrieved or put.
    // We put AuthController in LoginScreen, but if we refresh on Dashboard, it might be missing?
    // We should put AuthController in MainBinding.
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              children: [
                _buildSection("Profile", [_buildMyProfileCard()]),
                const SizedBox(height: 24),
                _buildSection("System", [
                  _buildSettingItem(
                    Icons.language,
                    "Language",
                    "English",
                    () {},
                  ),
                  _buildSettingItem(
                    Icons.notifications,
                    "Notifications",
                    "On",
                    () {},
                  ),
                  _buildSettingItem(
                    Icons.dark_mode,
                    "Theme",
                    "Dark Glass",
                    () {},
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection("Account", [
                  _buildSettingItem(
                    Icons.lock_reset,
                    "Change Password",
                    "",
                    () {},
                  ),
                  _buildSettingItem(Icons.logout, "Logout", "", () {
                    controller.logout();
                  }, color: AppTheme.errorRed),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMyProfileCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 30,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Admin User",
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "admin@softel.com",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text("Edit"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.textSecondary),
      title: Text(
        title,
        style: TextStyle(color: color ?? AppTheme.textPrimary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            Text(value, style: const TextStyle(color: AppTheme.textSecondary)),
          if (value.isNotEmpty) const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: color ?? AppTheme.textTertiary),
        ],
      ),
      onTap: onTap,
    );
  }
}
