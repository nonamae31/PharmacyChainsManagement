import 'package:equatable/equatable.dart';

class BranchDto extends Equatable {
  final String branchId;
  final String branchName;
  final String address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String status;
  final String? managerName;
  final String? managerEmail;
  final DateTime? managerJoinedDate;
  final double? dailyRevenue;
  final int? staffCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BranchDto({
    required this.branchId,
    required this.branchName,
    required this.address,
    required this.status,
    this.phone,
    this.latitude,
    this.longitude,
    this.managerName,
    this.managerEmail,
    this.managerJoinedDate,
    this.dailyRevenue,
    this.staffCount,
    this.createdAt,
    this.updatedAt,
  });

  factory BranchDto.fromJson(Map<String, dynamic> json) => BranchDto(
    branchId: json['branchId'].toString(),
    branchName: json['branchName']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
    phone: json['phone']?.toString(),
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    status: json['status']?.toString() ?? '',
    managerName: json['managerName']?.toString(),
    managerEmail: json['managerEmail']?.toString(),
    managerJoinedDate: DateTime.tryParse(
      json['managerJoinedDate']?.toString() ?? '',
    ),
    dailyRevenue: (json['dailyRevenue'] as num?)?.toDouble(),
    staffCount: json['staffCount'] as int?,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'branchName': branchName,
    'address': address,
    'phone': phone,
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
    'managerName': managerName,
    'managerEmail': managerEmail,
    'managerJoinedDate': managerJoinedDate?.toIso8601String(),
    'dailyRevenue': dailyRevenue,
    'staffCount': staffCount,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    branchId,
    branchName,
    address,
    phone,
    latitude,
    longitude,
    status,
    managerName,
    managerEmail,
    managerJoinedDate,
    dailyRevenue,
    staffCount,
    createdAt,
    updatedAt,
  ];
}

class BranchRequestDto extends Equatable {
  final String branchName;
  final String address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String status;

  const BranchRequestDto({
    required this.branchName,
    required this.address,
    required this.status,
    this.phone,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'branchName': branchName,
    'address': address,
    'phone': phone,
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
  };

  @override
  List<Object?> get props => [
    branchName,
    address,
    phone,
    latitude,
    longitude,
    status,
  ];
}
