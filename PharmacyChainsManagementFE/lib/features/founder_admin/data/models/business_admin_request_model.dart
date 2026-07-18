import 'package:equatable/equatable.dart';

class BusinessAdminRequestModel extends Equatable {
  final String fullName;
  final String email;
  final String phone;

  const BusinessAdminRequestModel({
    required this.fullName,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [fullName, email, phone];
}
