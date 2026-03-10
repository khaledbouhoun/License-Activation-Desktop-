import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:softel_control/controller/dashboard_controller.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:softel_control/view/subscription/add_subscription_dialog.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value || controller.isRefreshing.value) {
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
              _buildWelcomeHeader(),
              const SizedBox(height: 28),
              _buildQuickActions(),
              const SizedBox(height: 30),
              _buildKpiRow(),
              const SizedBox(height: 28),
              _buildChartsRow(),
              const SizedBox(height: 28),
              _buildBottomRow(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      );
    });
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 6),
              Text(
                    'Live overview of your license & subscription system',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),
            ],
          ),
        ),
        // Refresh button
        _glowButton(
          icon: Icons.refresh_rounded,
          label: 'Refresh',
          gradient: AppTheme.primaryGradient,
          onTap: controller.refreshDashboard,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _glowButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.glowShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
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
        ),
      ),
    );
  }

  // ─── KPI CARDS ROW ───────────────────────────────────────────────────────────

  Widget _buildKpiRow() {
    return Obx(() {
      final kpis = [
        _KpiData(
          title: 'Active Licenses',
          value: controller.totalActiveLicenses.value.toString(),
          sub: '+${controller.newActivations.value} this month',
          trendUp: true,
          icon: Icons.verified_rounded,
          gradient: AppTheme.primaryGradient,
          glow: AppTheme.glowShadow,
          delay: 0,
        ),
        _KpiData(
          title: 'Near Expiry',
          value: controller.nearExpiryLicenses.value.toString(),
          sub: 'Expiring within 30 days',
          trendUp: false,
          icon: Icons.warning_amber_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB800), Color(0xFFFF8000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          glow: [
            BoxShadow(
              color: AppTheme.warningOrange.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
          delay: 80,
        ),
        _KpiData(
          title: 'Expired',
          value: controller.expiredSubscriptions.value.toString(),
          sub: 'Requires action',
          trendUp: false,
          icon: Icons.cancel_outlined,
          gradient: AppTheme.redGradient,
          glow: AppTheme.redGlowShadow,
          delay: 160,
        ),
        _KpiData(
          title: 'Total Clients',
          value: controller.totalClients.value.toString(),
          sub: '${controller.totalApplications.value} applications',
          trendUp: true,
          icon: Icons.people_alt_outlined,
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          glow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
          delay: 240,
        ),
        _KpiData(
          title: 'Renewal Rate',
          value: '${controller.renewalRate.value.toStringAsFixed(1)}%',
          sub: 'Active / Total ratio',
          trendUp: controller.renewalRate.value >= 70,
          icon: Icons.autorenew_rounded,
          gradient: AppTheme.accentGradient,
          glow: AppTheme.greenGlowShadow,
          delay: 320,
        ),
      ];

      return Wrap(
        spacing: 18,
        runSpacing: 18,
        children: kpis.map((k) => _buildKpiCard(k)).toList(),
      );
    });
  }

  Widget _buildKpiCard(_KpiData k) {
    return Container(
          width: 300,
          height: 170,
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
              // Decorative blob
              Positioned(
                right: -18,
                top: -18,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: k.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (k.gradient as LinearGradient).colors.first
                            .withValues(alpha: 0.15),
                        blurRadius: 32,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ).animate().scale(delay: k.delay.ms, duration: 700.ms),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: k.gradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: k.glow,
                      ),
                      child: Icon(k.icon, color: Colors.white, size: 22),
                    ).animate().scale(delay: (k.delay + 80).ms),
                    const Spacer(),
                    Text(
                      k.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                              k.value,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (k.delay + 180).ms)
                            .slideX(begin: -0.2, end: 0),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            k.sub,
                            style: TextStyle(
                              fontSize: 10,
                              color: k.trendUp
                                  ? AppTheme.accentGreen
                                  : AppTheme.warningOrange,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: k.delay.ms, duration: 600.ms)
        .slideY(begin: 0.25, end: 0);
  }

  // ─── CHARTS ROW ──────────────────────────────────────────────────────────────

  Widget _buildChartsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line chart – 7-month trend
        Expanded(flex: 3, child: _buildLineChartCard()),
        const SizedBox(width: 20),
        // Pie chart – subscription status
        Expanded(flex: 2, child: _buildPieChartCard()),
      ],
    );
  }

  Widget _buildLineChartCard() {
    return _chartCard(
      title: 'Monthly Subscriptions',
      subtitle: 'Last 7 months',
      accentColor: AppTheme.primaryBlue,
      delay: 100,
      height: 320,
      child: Obx(() {
        final data = controller.monthlyActivations;
        if (data.isEmpty) return const SizedBox();
        final labels = controller.last7MonthLabels;
        final maxY = (data.reduce(math.max) * 1.3).ceilToDouble();

        return LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY / 4).clamp(1, double.infinity),
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFF2D3748), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (val, _) => Text(
                    val.toInt().toString(),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= labels.length) {
                      return const SizedBox();
                    }
                    return Text(
                      labels[idx],
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppTheme.surfaceLight,
                getTooltipItems: (spots) => spots
                    .map(
                      (s) => LineTooltipItem(
                        '${s.y.toInt()} subs',
                        const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  data.length,
                  (i) => FlSpot(i.toDouble(), data[i]),
                ),
                isCurved: true,
                curveSmoothness: 0.35,
                color: AppTheme.primaryBlue,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.primaryBlue,
                    strokeWidth: 2,
                    strokeColor: AppTheme.cardBackground,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.25),
                      AppTheme.primaryBlue.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 800),
        );
      }),
    );
  }

  Widget _buildPieChartCard() {
    return _chartCard(
      title: 'Status Distribution',
      subtitle: 'All subscriptions',
      accentColor: AppTheme.accentGreen,
      delay: 200,
      height: 320,
      child: Obx(() {
        final current = controller.statusCurrent.value;
        final warning = controller.statusWarning.value;
        final expired = controller.statusExpired.value;
        final total = (current + warning + expired).toDouble();
        if (total == 0) return const SizedBox();

        return Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {},
                  ),
                  sections: [
                    PieChartSectionData(
                      value: current.toDouble(),
                      color: AppTheme.accentGreen,
                      radius: 55,
                      title: '${((current / total) * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: warning.toDouble(),
                      color: AppTheme.warningOrange,
                      radius: 48,
                      title: '${((warning / total) * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: expired.toDouble(),
                      color: AppTheme.errorRed,
                      radius: 48,
                      title: '${((expired / total) * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legend('Active', AppTheme.accentGreen, current),
                const SizedBox(height: 12),
                _legend('Warning', AppTheme.warningOrange, warning),
                const SizedBox(height: 12),
                _legend('Expired', AppTheme.errorRed, expired),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _legend(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              count.toString(),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── BOTTOM ROW ──────────────────────────────────────────────────────────────

  Widget _buildBottomRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildBarChartCard()),
        const SizedBox(width: 20),
        Expanded(flex: 3, child: _buildMonthlyTrendCard()),
      ],
    );
  }

  Widget _buildBarChartCard() {
    return _chartCard(
      title: 'Subscriptions by App',
      subtitle: 'Top applications',
      accentColor: const Color(0xFF8B5CF6),
      delay: 300,
      height: 300,
      child: Obx(() {
        final counts = controller.appSubscriptionCounts;
        final names = controller.appNames;
        if (counts.isEmpty) return const SizedBox();
        final maxY = (counts.reduce(math.max) * 1.35).ceilToDouble();

        return BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY / 4).clamp(1, double.infinity),
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFF2D3748), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= names.length) {
                      return const SizedBox();
                    }
                    final name = names[idx];

                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        maxLines: 2,
                        name,
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (val, _) => Text(
                    val.toInt().toString(),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppTheme.surfaceLight,
                getTooltipItem: (group, gIdx, rod, rIdx) => BarTooltipItem(
                  '${rod.toY.toInt()} subs',
                  const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            barGroups: List.generate(counts.length, (i) {
              final gradientColors = [
                const Color(0xFF8B5CF6),
                const Color(0xFF00D9FF),
              ];
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: counts[i],
                    width: 22,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              );
            }),
          ),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
        );
      }),
    );
  }

  Widget _buildMonthlyTrendCard() {
    return _chartCard(
      title: 'Monthly Activations Licenses',
      subtitle: 'New licenses this week',
      accentColor: AppTheme.accentGreen,
      delay: 380,
      height: 300,
      child: Obx(() {
        final data = controller.monthlyActivationslicenses;
        final labels = controller.last7MonthLabels;
        if (data.isEmpty) return const SizedBox();
        final maxY = (data.reduce(math.max) * 1.3).ceilToDouble();

        return LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY / 4).clamp(1, double.infinity),
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFF2D3748), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (val, _) => Text(
                    val.toInt().toString(),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= labels.length) {
                      return const SizedBox();
                    }
                    return Text(
                      labels[idx],
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppTheme.surfaceLight,
                getTooltipItems: (spots) => spots
                    .map(
                      (s) => LineTooltipItem(
                        '${s.y.toInt()} activations',
                        const TextStyle(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  data.length,
                  (i) => FlSpot(i.toDouble(), data[i]),
                ),
                isCurved: true,
                curveSmoothness: 0.4,
                color: AppTheme.accentGreen,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.accentGreen,
                    strokeWidth: 2,
                    strokeColor: AppTheme.cardBackground,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentGreen.withValues(alpha: 0.22),
                      AppTheme.accentGreen.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 800),
        );
      }),
    );
  }

  // ─── CHART CARD SHELL ────────────────────────────────────────────────────────

  Widget _chartCard({
    required String title,
    required String subtitle,
    required Color accentColor,
    required int delay,
    required double height,
    required Widget child,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.borderColor.withValues(alpha: 0.3),
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 28,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Chart
              SizedBox(
                height: height - 80,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
                  child: child,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  // ─── QUICK ACTIONS ───────────────────────────────────────────────────────────

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
              label: 'New Subscription',
              icon: Icons.add_circle_outline,
              gradient: AppTheme.primaryGradient,
              onTap: () => Get.dialog(const AddEditSubscriptionDialog()),
            ),
            _buildActionButton(
              label: 'View Subscriptions',
              icon: Icons.list_alt_rounded,
              gradient: AppTheme.accentGradient,
              onTap: () => controller.changeNavigation('/subscriptions'),
            ),
            _buildActionButton(
              label: 'Manage Clients',
              icon: Icons.people_alt_outlined,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => controller.changeNavigation('/clients'),
            ),
            _buildActionButton(
              label: 'Manage Applications',
              icon: Icons.apps_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => controller.changeNavigation('/applications'),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
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
                    horizontal: 22,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (gradient as LinearGradient).colors.first
                            .withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
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
                .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                .shimmer(delay: 2000.ms, duration: 1500.ms),
      ),
    );
  }
}

// ─── MODEL ───────────────────────────────────────────────────────────────────

class _KpiData {
  final String title;
  final String value;
  final String sub;
  final bool trendUp;
  final IconData icon;
  final Gradient gradient;
  final List<BoxShadow> glow;
  final int delay;

  const _KpiData({
    required this.title,
    required this.value,
    required this.sub,
    required this.trendUp,
    required this.icon,
    required this.gradient,
    required this.glow,
    required this.delay,
  });
}
