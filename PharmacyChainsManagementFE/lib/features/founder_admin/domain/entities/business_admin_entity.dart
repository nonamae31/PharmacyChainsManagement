import 'package:equatable/equatable.dart';

class BusinessAdminEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String status;

  const BusinessAdminEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, email, status];
}
