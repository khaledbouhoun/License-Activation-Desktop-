import 'package:intl/intl.dart';

class LicenseModel {
  final int id;
  final int subscriptionId;
  final String? deviceId;
  final String? deviceModel;
  final DateTime? lastSyncDate;
  final DateTime? startDate;
  final DateTime? expiryDate;

  LicenseModel({
    required this.id,
    required this.subscriptionId,
    this.deviceId,
    this.deviceModel,
    this.lastSyncDate,
    this.startDate,
    this.expiryDate,
  });

  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    print(json['last_sync_date']);
    return LicenseModel(
      id: json['id'] ?? 0,
      subscriptionId: json['subscription_id'] ?? 0,
      deviceId: json['device_id'],
      deviceModel: json['device_model'],
      lastSyncDate: json['last_sync_date'] != null
          ? DateTime.parse(json['last_sync_date']).toLocal()
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date']).toLocal()
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscription_id': subscriptionId,
      'device_id': deviceId,
      'device_model': deviceModel,
      'last_sync_date': lastSyncDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }

  String get formattedStartDate =>
      startDate != null ? DateFormat('MMM dd, yyyy').format(startDate!) : 'N/A';

  String get formattedExpiryDate => expiryDate != null
      ? DateFormat('MMM dd, yyyy').format(expiryDate!)
      : 'N/A';

  String get formattedSyncDate => lastSyncDate != null
      ? DateFormat('MMM dd, yyyy HH:mm').format(lastSyncDate!)
      : 'Never';

  bool get isOnline =>
      lastSyncDate != null &&
      !isExpired &&
      DateTime.now().difference(lastSyncDate!).inHours < 24;

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
}
