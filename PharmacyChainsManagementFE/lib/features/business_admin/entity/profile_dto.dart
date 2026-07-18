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
    joinedDate,
  ];
}

class UpdateProfileRequestDto extends Equatable {
  final String fullName;
  final String? phone;

  const UpdateProfileRequestDto({required this.fullName, this.phone});

  Map<String, dynamic> toJson() => {'fullName': fullName, 'phone': phone};

  @override
  List<Object?> get props => [fullName, phone];
}
