import 'package:equatable/equatable.dart';

class BusinessAdminEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String status;
  final String phone;

  const BusinessAdminEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.phone,
  });

  BusinessAdminEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? status,
    String? phone,
  }) {
    return BusinessAdminEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [id, name, email, status, phone];
}
