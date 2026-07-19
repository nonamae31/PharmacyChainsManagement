import 'package:equatable/equatable.dart';

class BusinessAdminEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String status;
  final String phone;

  final String? profilePhotoUri;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime? createdAt;

  const BusinessAdminEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.phone,
    this.profilePhotoUri,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.createdAt,
  });

  BusinessAdminEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? status,
    String? phone,
    String? profilePhotoUri,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    DateTime? createdAt,
  }) {
    return BusinessAdminEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      profilePhotoUri: profilePhotoUri ?? this.profilePhotoUri,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, status, phone, profilePhotoUri, address, dateOfBirth, gender, createdAt];
}
