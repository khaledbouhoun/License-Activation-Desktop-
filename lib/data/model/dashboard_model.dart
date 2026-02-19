class DashboardResponse {
  final int totalActiveSubscriptions;
  final int nearExpirySubscriptions;
  final int newActivations;
  final List<DashboardStats>? stats;

  DashboardResponse({
    required this.totalActiveSubscriptions,
    required this.nearExpirySubscriptions,
    required this.newActivations,
    this.stats,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      totalActiveSubscriptions: json['total_active'] ?? 0,
      nearExpirySubscriptions: json['near_expiry'] ?? 0,
      newActivations: json['new_activations'] ?? 0,
      stats: json['stats'] != null
          ? (json['stats'] as List)
                .map((i) => DashboardStats.fromJson(i))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_active': totalActiveSubscriptions,
      'near_expiry': nearExpirySubscriptions,
      'new_activations': newActivations,
      'stats': stats?.map((i) => i.toJson()).toList(),
    };
  }
}

class DashboardStats {
  final String label;
  final double value;
  final String? trend;

  DashboardStats({required this.label, required this.value, this.trend});

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      trend: json['trend'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value, 'trend': trend};
  }
}
