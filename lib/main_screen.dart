import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/dashboard_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/view/dashboard/dashboard_view.dart';
import 'package:softel_control/view/settings/settings_view.dart';

import 'package:softel_control/view/subscription/subscription_view.dart';
import 'package:softel_control/view/client/client_view.dart';
import 'package:softel_control/view/application/application_view.dart';

class MainScreen extends GetView<DashboardController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Row(
          children: [
            // Sidebar Navigation
            _buildSidebar(),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  _buildTopBar(),

                  // Content
                  Expanded(
                    child: Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        child: KeyedSubtree(
                          key: ValueKey<int>(controller.selectedIndex.value),
                          child: _getSelectedView(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar with NavigationRail
  Widget _buildSidebar() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            height: 80,
            alignment: Alignment.center,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.glowShadow,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),

          const SizedBox(height: 24),

          // Navigation Items
          Expanded(
            child: Obx(
              () => ListView(
                children: [
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    route: '/dashboard',
                  ),
                  _buildNavItem(
                    icon: Icons.card_membership_outlined,
                    label: 'Subscriptions',
                    route: '/subscriptions',
                  ),
                  _buildNavItem(
                    icon: Icons.people_outline,
                    label: 'Clients',
                    route: '/clients',
                  ),
                  _buildNavItem(
                    icon: Icons.apps_outlined,
                    label: 'Applications',
                    route: '/applications',
                  ),

                  _buildNavItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    route: '/settings',
                  ),
                ],
              ),
            ),
          ),

          // User Profile
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppTheme.primaryBlue,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
  }) {
    bool isSelected = controller.selectedRoute.value == route;
    return Tooltip(
      message: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: InkWell(
          onTap: () => controller.changeNavigation(route),
          borderRadius: BorderRadius.circular(12),
          child:
              // Obx(() {
              AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue.withAlpha(40)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.textSecondary,
                      size: 28,
                    ),
                  )
                  .animate(target: isSelected ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 200.ms,
                  ),
          // }),
        ),
      ),
    );
  }

  // Top Bar
  Widget _buildTopBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Breadcrumbs
            Obx(() => _buildBreadcrumbs()),

            const Spacer(),

            // Search Bar
            Container(
              width: 300,
              height: 45,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderColor.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                onChanged: controller.updateSearchQuery,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: AppTheme.textTertiary),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(width: 16),

            // Notifications
            IconButton(
              onPressed: () {},
              icon: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.errorRed.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    final List<String> breadcrumbs = [
      'Dashboard',
      'Subscriptions',
      'Clients',
      'Applications',
      'Settings',
    ];

    return Row(
      children: [
        const Icon(Icons.home_outlined, color: AppTheme.textTertiary, size: 20),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 16),
        const SizedBox(width: 8),
        Text(
          breadcrumbs[controller.selectedIndex.value],
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _getSelectedView() {
    switch (controller.selectedIndex.value) {
      case 0:
        return const DashboardView();
      case 1:
        return const SubscriptionView();
      case 2:
        return const ClientView();
      case 3:
        return const ApplicationView();
      case 5:
        return const SettingsView();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 64,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Coming Soon',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    }
  }
}
