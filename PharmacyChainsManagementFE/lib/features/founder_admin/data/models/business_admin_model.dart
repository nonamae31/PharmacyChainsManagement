import '../../domain/entities/business_admin_entity.dart';

class BusinessAdminModel extends BusinessAdminEntity {
  const BusinessAdminModel({
    required super.id,
    required super.name,
    required super.email,
    required super.status,
    required super.phone,
    super.profilePhotoUri,
    super.address,
    super.dateOfBirth,
    super.gender,
    super.createdAt,
  });

  factory BusinessAdminModel.fromJson(Map<String, dynamic> json) {
    return BusinessAdminModel(
      id: (json['userId'] ?? json['id'])?.toString() ?? '',
      name: (json['fullName'] ?? json['name'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Inactive',
      phone: json['phone']?.toString() ?? '',
      profilePhotoUri: json['profilePhotoUri']?.toString(),
      address: json['address']?.toString(),
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth'].toString()) : null,
      gender: json['gender']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
      'phone': phone,
      'profilePhotoUri': profilePhotoUri,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
