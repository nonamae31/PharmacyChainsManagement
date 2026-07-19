import 'package:equatable/equatable.dart';

sealed class PrescriptionEvent extends Equatable {
  const PrescriptionEvent();
  @override
  List<Object?> get props => [];
}

final class PrescriptionListRequested extends PrescriptionEvent {}

final class PrescriptionDetailRequested extends PrescriptionEvent {
  final String prescriptionId;
  const PrescriptionDetailRequested(this.prescriptionId);
  @override
  List<Object?> get props => [prescriptionId];
}
