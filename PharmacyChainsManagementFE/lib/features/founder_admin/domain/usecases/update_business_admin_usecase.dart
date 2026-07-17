import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/business_admin_repository.dart';
import '../../data/models/business_admin_request_model.dart';
import 'package:equatable/equatable.dart';

class UpdateBusinessAdminUseCase {
  final BusinessAdminRepository repository;

  UpdateBusinessAdminUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateBusinessAdminParams params) async {
    return await repository.updateBusinessAdmin(
      params.id,
      BusinessAdminRequestModel(
        fullName: params.name,
        email: params.email ?? '',
        phone: params.phone,
      ),
    );
  }
}

class UpdateBusinessAdminParams extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;

  const UpdateBusinessAdminParams({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  @override
  List<Object?> get props => [id, name, phone, email];
}
