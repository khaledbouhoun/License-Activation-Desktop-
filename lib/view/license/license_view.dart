import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/license_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/data/model/license_model.dart';

class LicensesView extends StatelessWidget {
  const LicensesView({super.key});

  @override
  Widget build(BuildContext context) {
    // We use Get.put here because this view might be opened via Get.to
    final controller = Get.put(LicenseController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Get.back(result: controller.licenses.length),
        ),
        title: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Managed Licenses',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Subscription: ${controller.subscription.licenseKey}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => controller.loadLicenses(),
              icon: Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBlue),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStats(controller),
              const SizedBox(height: 24),
              Expanded(child: _buildLicensesTable(controller)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStats(LicenseController controller) {
    return Row(
      children: [
        _buildStatCard(
          title: 'Online Devices',
          value: '${controller.licenses.where((e) => e.isOnline).length}',
          subtitle: 'Devices currently online',
          icon: Icons.devices,
          color: AppTheme.accentGreen,
        ),

        const SizedBox(width: 24),
        _buildStatCard(
          title: 'Devices',
          value:
              '${controller.licenses.length} / ${controller.subscription.maxDevices}',
          subtitle: 'Allowed devices',
          icon: Icons.devices,
          color: AppTheme.primaryBlue,
        ),
        const SizedBox(width: 24),
        _buildStatCard(
          title: 'Date Expiry',
          value: controller.subscription.formattedExpiryDate,
          subtitle: 'Remaining slots',
          icon: Icons.date_range,
          color: AppTheme.errorRed,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicensesTable(LicenseController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('Device ID', flex: 2),
                _buildHeaderCell('Model', flex: 2),
                _buildHeaderCell('Last Sync', flex: 2),
                _buildHeaderCell('Start Date', flex: 2),
                _buildHeaderCell('Status', flex: 1),
                _buildHeaderCell('Actions', flex: 1),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: controller.licenses.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: controller.licenses.length,
                    separatorBuilder: (context, index) => Divider(
                      color: AppTheme.dividerColor.withValues(alpha: 0.3),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final license = controller.licenses[index];
                      return _buildTableRow(license, index, controller);
                    },
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    LicenseModel license,
    int index,
    LicenseController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Device ID
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  Icons.phone_iphone_rounded,
                  size: 30,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(
                    license.deviceId ?? 'Unknown',
                    maxLines: 1,
                    style: const TextStyle(
                      overflow: TextOverflow.fade,
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),

          // Model
          Expanded(
            flex: 2,
            child: Text(
              license.deviceModel ?? '---',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ),

          // Last Sync
          Expanded(
            flex: 2,
            child: Text(
              license.formattedSyncDate,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ),

          // Start Date
          Expanded(
            flex: 2,
            child: Text(
              license.formattedStartDate,
              style: const TextStyle(color: AppTheme.accentGreen, fontSize: 16),
            ),
          ),

          // Status
          Expanded(flex: 1, child: _buildOnlineBadge(license)),

          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.delete_forever,
                  tooltip: 'Remove License',
                  color: AppTheme.errorRed,
                  onTap: () {
                    Get.defaultDialog(
                      title: "Remove License",
                      middleText:
                          "Are you sure you want to Remove this license? The device will no longer be able to sync.",
                      textConfirm: "Remove",
                      confirmTextColor: Colors.white,
                      buttonColor: AppTheme.errorRed,
                      onConfirm: () {
                        Get.back();
                        controller.removeLicense(license);
                      },
                      textCancel: "Cancel",
                      cancelTextColor: AppTheme.textPrimary,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (300 + (index * 50)).ms);
  }

  Widget _buildOnlineBadge(LicenseModel license) {
    final bool isOnline = license.isOnline;

    final Color color = isOnline ? AppTheme.accentGreen : AppTheme.errorRed;

    final String label = isOnline ? 'Online' : 'Offline';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color ?? AppTheme.primaryBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_cell_outlined, size: 100, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          const Text(
            'No active licenses for this subscription',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Devices will appear here once they activate with the license key.',
            style: TextStyle(color: AppTheme.textTertiary, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
