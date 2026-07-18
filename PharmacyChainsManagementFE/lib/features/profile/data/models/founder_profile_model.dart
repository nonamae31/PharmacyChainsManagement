import '../../domain/entities/founder_profile.dart';

class FounderProfileModel extends FounderProfile {
  const FounderProfileModel({
    required super.userId,
    required super.fullName,
    required super.email,
    super.phone,
    super.profilePhotoUri,
    super.address,
    super.dateOfBirth,
    super.gender,
  });

  factory FounderProfileModel.fromJson(Map<String, dynamic> json) {
    return FounderProfileModel(
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      profilePhotoUri: json['profile_photo_uri']?.toString() ?? json['profilePhotoUri']?.toString(),
      address: json['address']?.toString(),
      dateOfBirth: (json['date_of_birth'] ?? json['dateOfBirth']) != null 
          ? DateTime.tryParse((json['date_of_birth'] ?? json['dateOfBirth']).toString()) 
          : null,
      gender: json['gender']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phone,
      'profilePhotoUri': profilePhotoUri,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
    };
  }

  factory FounderProfileModel.fromEntity(FounderProfile entity) {
    return FounderProfileModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      profilePhotoUri: entity.profilePhotoUri,
      address: entity.address,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
    );
  }
}
