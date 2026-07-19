import 'package:equatable/equatable.dart';
import '../entity/prescription_dto.dart';

sealed class PrescriptionState extends Equatable {
  const PrescriptionState();
  @override
  List<Object?> get props => [];
}

final class PrescriptionInitial extends PrescriptionState {}

final class PrescriptionLoading extends PrescriptionState {}

final class PrescriptionListLoadSuccess extends PrescriptionState {
  final List<PrescriptionListItemDto> prescriptions;
  const PrescriptionListLoadSuccess(this.prescriptions);
  @override
  List<Object?> get props => [prescriptions];
}

final class PrescriptionDetailLoadSuccess extends PrescriptionState {
  final PrescriptionDto prescription;
  const PrescriptionDetailLoadSuccess(this.prescription);
  @override
  List<Object?> get props => [prescription];
}

final class PrescriptionLoadFailure extends PrescriptionState {
  final String message;
  const PrescriptionLoadFailure(this.message);
  @override
  List<Object?> get props => [message];
}
