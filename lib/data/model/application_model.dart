class ApplicationModel {
  int id;
  String name;
  DateTime createdAt;

  ApplicationModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      name: json['name'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  // copywith
  ApplicationModel copyWith({int? id, String? name, DateTime? createdAt}) {
    return ApplicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
