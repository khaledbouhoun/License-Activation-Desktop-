import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/dashboard_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshDashboard,
        color: AppTheme.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(),

              const SizedBox(height: 32),

              // Stats Cards
              _buildStatsCards(),

              const SizedBox(height: 32),

              // Quick Actions
              _buildQuickActions(),

              const SizedBox(height: 32),

              // Recent Activity
              _buildRecentActivity(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, Admin',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),

        const SizedBox(height: 8),

        Text(
              'Here\'s what\'s happening with your licenses today',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: 300,
              child: _buildStatCard(
                title: 'Total Active Licenses',
                value: controller.totalActiveLicenses.value.toString(),
                icon: Icons.verified_outlined,
                gradient: AppTheme.primaryGradient,
                trend: '+12.5%',
                trendUp: true,
                delay: 0,
              ),
            ),
            SizedBox(
              width: 300,
              child: _buildStatCard(
                title: 'Near Expiry',
                value: controller.nearExpiryLicenses.value.toString(),
                icon: Icons.warning_amber_outlined,
                gradient: const LinearGradient(
                  colors: [AppTheme.warningOrange, Color(0xFFFF9500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                trend: '+3',
                trendUp: true,
                delay: 100,
              ),
            ),
            SizedBox(
              width: 300,
              child: _buildStatCard(
                title: 'New Activations',
                value: controller.newActivations.value.toString(),
                icon: Icons.add_circle_outline,
                gradient: AppTheme.accentGradient,
                trend: '+23.1%',
                trendUp: true,
                delay: 200,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
    required String trend,
    required bool trendUp,
    required int delay,
  }) {
    return Container(
          height: 200,
          width: 300,
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.borderColor.withValues(alpha: 0.3),
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Stack(
            children: [
              // Background gradient overlay
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ).animate().scale(delay: delay.ms, duration: 800.ms),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ).animate().scale(delay: (delay + 100).ms),

                    const Spacer(),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Value and Trend
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                              value,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (delay + 200).ms)
                            .slideX(begin: -0.3, end: 0),

                        const SizedBox(width: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: trendUp
                                ? AppTheme.accentGreen.withValues(alpha: 0.15)
                                : AppTheme.errorRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                trendUp
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 12,
                                color: trendUp
                                    ? AppTheme.accentGreen
                                    : AppTheme.errorRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trend,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: trendUp
                                      ? AppTheme.accentGreen
                                      : AppTheme.errorRed,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (delay + 300).ms),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildActionButton(
              label: 'Generate License Key',
              icon: Icons.key_outlined,
              gradient: AppTheme.primaryGradient,
              onTap: () {},
            ),
            _buildActionButton(
              label: 'Add New Client',
              icon: Icons.person_add_outlined,
              gradient: AppTheme.accentGradient,
              onTap: () {},
            ),
            _buildActionButton(
              label: 'View Reports',
              icon: Icons.analytics_outlined,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {},
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child:
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .shimmer(delay: 2000.ms, duration: 1500.ms),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(
              color: AppTheme.dividerColor.withValues(alpha: 0.3),
              height: 1,
            ),
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  'License activated for Client ${index + 1}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${index + 1} hours ago',
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ).animate().fadeIn(delay: (500 + (index * 50)).ms);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }
}
