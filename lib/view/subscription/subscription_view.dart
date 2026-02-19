import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:softel_control/controller/subscription_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/data/model/application_model.dart';
import 'package:softel_control/data/model/client_model.dart';
import 'package:softel_control/data/model/subscription_model.dart';
import 'package:softel_control/view/subscription/add_subscription_dialog.dart';
import 'package:softel_control/view/subscription/edit_subscription_dialog.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SubscriptionController());
    return Obx(() {
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
            // Header
            _buildHeader(),

            const SizedBox(height: 24),

            // Filters
            _buildFilters(),

            const SizedBox(height: 24),

            // Data Table
            Expanded(child: _buildDataTable()),

            const SizedBox(height: 16),

            // Pagination
            _buildPagination(),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscriptions',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),

            const SizedBox(height: 4),

            Obx(
              () => Text(
                '${controller.filteredSubscriptions.length} total subscriptions',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),

        const Spacer(),

        // Add New Button
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Get.dialog(const AddEditSubscriptionDialog());
            },
            child:
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.glowShadow,
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Add Subscription',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                    .shimmer(delay: 2000.ms, duration: 1500.ms),
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Status Filter
                Obx(
                  () => _buildFilterChip(
                    label: 'All',
                    isSelected: controller.filterStatus.value == 'All',
                    onTap: () => controller.changeFilterStatus('All'),
                  ),
                ),

                const SizedBox(width: 12),

                Obx(
                  () => _buildFilterChip(
                    label: 'Current',
                    isSelected: controller.filterStatus.value == 'current',
                    onTap: () => controller.changeFilterStatus('current'),
                    color: AppTheme.accentGreen,
                  ),
                ),

                const SizedBox(width: 12),

                Obx(
                  () => _buildFilterChip(
                    label: 'Warning',
                    isSelected: controller.filterStatus.value == 'warning',
                    onTap: () => controller.changeFilterStatus('warning'),
                    color: AppTheme.warningOrange,
                  ),
                ),

                const SizedBox(width: 12),

                Obx(
                  () => _buildFilterChip(
                    label: 'Expired',
                    isSelected: controller.filterStatus.value == 'expired',
                    onTap: () => controller.changeFilterStatus('expired'),
                    color: AppTheme.errorRed,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Row(
              spacing: 30,
              children: [
                _buildFilterDropDownClients(),
                _buildFilterDropDownApplication(),
              ],
            ),
          ),

          Expanded(flex: 1, child: _buildFilterDropDownDate()),

          // Sort Dropdown
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (color ?? AppTheme.primaryBlue).withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? (color ?? AppTheme.primaryBlue)
                  : AppTheme.borderColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? (color ?? AppTheme.primaryBlue)
                  : AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropDownDate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
      ),
      child: Obx(
        () => DropdownButton<String>(
          value: controller.sortBy.value,
          underline: const SizedBox(),
          dropdownColor: AppTheme.surfaceLight,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppTheme.textSecondary,
          ),
          items: const [
            DropdownMenuItem(value: 'date', child: Text('Sort by Date')),
            DropdownMenuItem(value: 'expiry', child: Text('Sort by Expiry')),
            DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.changeSortBy(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterDropDownClients() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
      ),
      child: Obx(
        () => DropdownButton<ClientModel?>(
          value:
              controller.clientController.clients.contains(
                controller.clientSelcted.value,
              )
              ? controller.clientSelcted.value
              : null,
          hint: const Text("All Clients"),
          underline: const SizedBox(),
          dropdownColor: AppTheme.surfaceLight,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppTheme.textSecondary,
          ),
          items: [
            const DropdownMenuItem<ClientModel?>(
              value: null,
              child: Text("All Clients"),
            ),
            ...controller.clientController.clients.map((client) {
              return DropdownMenuItem<ClientModel?>(
                value: client,
                child: Text(client.name),
              );
            }),
          ],
          onChanged: (value) {
            controller.clientSelcted.value = value;
          },
        ),
      ),
    );
  }

  Widget _buildFilterDropDownApplication() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.3)),
      ),
      child: Obx(
        () => DropdownButton<ApplicationModel?>(
          value:
              controller.applicationController.applications.contains(
                controller.applicationSelcted.value,
              )
              ? controller.applicationSelcted.value
              : null,
          hint: const Text("All Apps"),
          underline: const SizedBox(),
          dropdownColor: AppTheme.surfaceLight,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppTheme.textSecondary,
          ),
          items: [
            const DropdownMenuItem<ApplicationModel?>(
              value: null,
              child: Text("All Apps"),
            ),
            ...controller.applicationController.applications.map((application) {
              return DropdownMenuItem<ApplicationModel?>(
                value: application,
                child: Text(application.name),
              );
            }),
          ],
          onChanged: (value) {
            controller.applicationSelcted.value = value;
          },
        ),
      ),
    );
  }

  Widget _buildDataTable() {
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
                _buildHeaderCell('Client', flex: 2),
                _buildHeaderCell('License Key', flex: 2),
                _buildHeaderCell('Devices', flex: 1),
                _buildHeaderCell('Date Expiry', flex: 2),
                _buildHeaderCell('Is Active', flex: 1),
                _buildHeaderCell('Status', flex: 1),
                _buildHeaderCell('Actions', flex: 1),
                SizedBox(width: 20),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: Obx(() {
              final subscriptions = controller.getPaginatedSubscriptions();

              if (subscriptions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No subscriptions found',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: subscriptions.length,
                separatorBuilder: (context, index) => Divider(
                  color: AppTheme.dividerColor.withValues(alpha: 0.3),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final subscription = subscriptions[index];
                  return _buildTableRow(subscription, index);
                },
              );
            }),
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
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTableRow(SubscriptionModel subscription, int index) {
    final color = subscription.status == SubscriptionStatus.current
        ? AppTheme.successGreen
        : subscription.status == SubscriptionStatus.expired
        ? AppTheme.errorRed
        : AppTheme.warningOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        spacing: 10,
        children: [
          // Client Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.clientName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subscription.applicationName,
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // License Key
          Expanded(
            flex: 2,
            child: Row(
              spacing: 20,
              children: [
                Text(
                  subscription.licenseKey,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 20,
                    color: AppTheme.textTertiary,
                  ),
                  onPressed: () {
                    controller.copyLicenseKey(subscription.licenseKey);
                  },
                  tooltip: 'Copy License Key',
                ),
              ],
            ),
          ),

          // Devices
          Expanded(
            flex: 1,
            child: Text(
              '${subscription.licensesCount} / ${subscription.maxDevices}',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          ),

          // Expiry Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.expiryDate != null
                      ? DateFormat(
                          'MMM dd, yyyy',
                        ).format(subscription.expiryDate!)
                      : '-- -- , ----',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
                if (subscription.expiryDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subscription.daysUntilExpiry > 0
                        ? '${subscription.daysUntilExpiry} days left'
                        : 'Expired',
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // Active
          Expanded(flex: 1, child: _buildActiveSwitch(subscription)),

          // Status
          Expanded(flex: 1, child: _buildStatusBadge(subscription.status)),

          // Actions
          Expanded(
            flex: 1,
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.subdirectory_arrow_left_rounded,
                  tooltip: 'Edit',
                  onTap: () {
                    Get.dialog(
                      EditSubscriptionDialog(subscription: subscription),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  color: AppTheme.errorRed,
                  onTap: () => controller.deleteSubscription(subscription),
                ),
              ],
            ),
          ),

          _buildActionButton(
            icon: Icons.arrow_forward_ios_outlined,
            tooltip: 'Open Licenses',
            color: subscription.licensesCount != 0
                ? AppTheme.primaryBlue
                : AppTheme.textSecondary,
            onTap: () => subscription.licensesCount != 0
                ? controller.openLicenses(subscription)
                : null,
          ),
        ],
      ),
    ).animate().fadeIn(delay: (300 + (index * 50)).ms);
  }

  Widget _buildStatusBadge(SubscriptionStatus status) {
    Color color;

    switch (status) {
      case SubscriptionStatus.current:
        color = AppTheme.accentGreen;

        break;
      case SubscriptionStatus.warning:
        color = AppTheme.warningOrange;

        break;
      case SubscriptionStatus.expired:
        color = AppTheme.errorRed;

        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: status == SubscriptionStatus.current
                  ? AppTheme.greenGlowShadow
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSwitch(SubscriptionModel subscription) {
    RxBool isActive = (subscription.isActive == SubscriptionActive.active).obs;

    return Obx(
      () => Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          Text(
            isActive.value ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive.value ? AppTheme.accentGreen : AppTheme.errorRed,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: isActive.value,
              onChanged: (value) {
                isActive.value = !isActive.value;
                controller.editSubscription(
                  subscription.copyWith(
                    isActive: value
                        ? SubscriptionActive.active
                        : SubscriptionActive.inactive,
                  ),
                  loadSubscription: false,
                );
              },
              activeThumbColor: Colors.white,
              activeTrackColor: AppTheme.accentGreen,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppTheme.errorRed.withValues(alpha: 0.5),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
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
              color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color ?? AppTheme.primaryBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(() {
      if (controller.totalPages.value <= 1) {
        return const SizedBox();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          IconButton(
            onPressed: controller.currentPage.value > 1
                ? () => controller.changePage(controller.currentPage.value - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: AppTheme.textPrimary,
            disabledColor: AppTheme.textTertiary,
          ),

          const SizedBox(width: 16),

          // Page Numbers
          ...List.generate(controller.totalPages.value.clamp(0, 5), (index) {
            final pageNum = index + 1;
            final isSelected = controller.currentPage.value == pageNum;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => controller.changePage(pageNum),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : AppTheme.borderColor.withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      pageNum.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(width: 16),

          // Next Button
          IconButton(
            onPressed:
                controller.currentPage.value < controller.totalPages.value
                ? () => controller.changePage(controller.currentPage.value + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            color: AppTheme.textPrimary,
            disabledColor: AppTheme.textTertiary,
          ),
        ],
      );
    }).animate().fadeIn(delay: 400.ms);
  }
}
