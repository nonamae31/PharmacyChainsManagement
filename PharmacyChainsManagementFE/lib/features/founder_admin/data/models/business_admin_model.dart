import '../../domain/entities/business_admin_entity.dart';

class BusinessAdminModel extends BusinessAdminEntity {
  const BusinessAdminModel({
    required super.id,
    required super.name,
    required super.email,
    required super.status,
    required super.phone,
  });

  factory BusinessAdminModel.fromJson(Map<String, dynamic> json) {
    return BusinessAdminModel(
      id: (json['userId'] ?? json['id'])?.toString() ?? '',
      name: (json['fullName'] ?? json['name'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Inactive',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
      'phone': phone,
    };
  }
}
