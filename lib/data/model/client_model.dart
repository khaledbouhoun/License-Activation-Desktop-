class ClientModel {
  int id;
  String name;
  String email;
  String phone;
  String address;
  DateTime createdAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone, 'address': address};
  }

  // copywith
  ClientModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    DateTime? createdAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
