import 'package:equatable/equatable.dart';

class ProfileDto extends Equatable {
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String status;
  final String? phone;
  final String? branchName;
  final String? profilePhotoUri;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime? joinedDate;

  const ProfileDto({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    this.phone,
    this.branchName,
    this.profilePhotoUri,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.joinedDate,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) => ProfileDto(
    userId: json['userId'].toString(),
    fullName: json['fullName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    role: json['role']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    phone: json['phone']?.toString(),
    branchName: json['branchName']?.toString(),
    profilePhotoUri: json['profilePhotoUri']?.toString(),
    address: json['address']?.toString(),
    dateOfBirth: DateTime.tryParse(json['dateOfBirth']?.toString() ?? ''),
    gender: json['gender']?.toString(),
    joinedDate: DateTime.tryParse(json['joinedDate']?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'email': email,
    'role': role,
    'status': status,
    'phone': phone,
    'branchName': branchName,
    'profilePhotoUri': profilePhotoUri,
    'address': address,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'gender': gender,
    'joinedDate': joinedDate?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    role,
    status,
    phone,
    branchName,
    profilePhotoUri,
    address,
    dateOfBirth,
    gender,
    joinedDate,
  ];
}

class UpdateProfileRequestDto extends Equatable {
  final String fullName;
  final String? phone;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;

  const UpdateProfileRequestDto({
    required this.fullName,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.gender,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': phone,
    'address': address,
    'dateOfBirth': dateOfBirth == null
        ? null
        : DateTime.utc(
            dateOfBirth!.year,
            dateOfBirth!.month,
            dateOfBirth!.day,
          ).toIso8601String(),
    'gender': gender,
  };

  @override
  List<Object?> get props => [fullName, phone, address, dateOfBirth, gender];
}

class ChangePasswordRequestDto extends Equatable {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequestDto({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
