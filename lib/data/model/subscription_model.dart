import 'package:intl/intl.dart';

class SubscriptionModel {
  final int id;
  final int clientId;
  final String clientName;
  final int applicationId;
  final String applicationName;
  final String licenseKey;
  final int maxDevices;
  final int duration;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final SubscriptionActive isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int licensesCount;

  SubscriptionModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.applicationId,
    required this.applicationName,
    required this.licenseKey,
    required this.maxDevices,
    required this.duration,
    this.startDate,
    this.expiryDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.licensesCount,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    int isActiveVar = json['is_active'];
    return SubscriptionModel(
      id: json['id'],
      clientId: json['client_id'],
      clientName: json['client']?['name'] ?? '',
      applicationId: json['application_id'],
      applicationName: json['application']?['name'] ?? '',
      licenseKey: json['license_key'],
      maxDevices: json['max_devices'],
      duration: json['duration'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      isActive: isActiveVar == 1
          ? SubscriptionActive.active
          : SubscriptionActive.inactive,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      licensesCount: json['licenses_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'application_id': applicationId,
      'max_devices': maxDevices,
      'duration': duration,
      'is_active': isActive == SubscriptionActive.active ? 1 : 0,
    };
  }

  // copywith
  SubscriptionModel copyWith({
    int? id,
    int? clientId,
    String? clientName,
    int? applicationId,
    String? applicationName,
    String? licenseKey,
    int? maxDevices,
    int? duration,
    DateTime? startDate,
    DateTime? expiryDate,
    SubscriptionActive? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      applicationId: applicationId ?? this.applicationId,
      applicationName: applicationName ?? this.applicationName,
      licenseKey: licenseKey ?? this.licenseKey,
      maxDevices: maxDevices ?? this.maxDevices,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      licensesCount: licensesCount,
    );
  }

  /// ⭐ Computed status

  String get formattedExpiryDate {
    if (expiryDate == null) return 'Never';
    return DateFormat('dd MMM yyyy').format(expiryDate!);
  }

  SubscriptionStatus get status {
    if (expiryDate == null) return SubscriptionStatus.current;

    final days = expiryDate!.difference(DateTime.now()).inDays;

    if (days <= 0) return SubscriptionStatus.expired;
    if (days <= 30) return SubscriptionStatus.warning;

    return SubscriptionStatus.current;
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return 9999;
    int days = expiryDate!.difference(DateTime.now()).inDays;
    return days.isNegative ? 0 : days;
  }
}

enum SubscriptionStatus { current, warning, expired }

enum SubscriptionActive { active, inactive }
