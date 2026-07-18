import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class FinancialExportState extends Equatable {
  const FinancialExportState();

  @override
  List<Object?> get props => [];
}

class FinancialExportInitial extends FinancialExportState {
  const FinancialExportInitial();
}

class FinancialExportLoading extends FinancialExportState {
  const FinancialExportLoading();
}

class FinancialExportSuccess extends FinancialExportState {
  final Uint8List fileBytes;

  const FinancialExportSuccess(this.fileBytes);

  @override
  List<Object?> get props => [fileBytes];
}

class FinancialExportError extends FinancialExportState {
  final String message;

  const FinancialExportError(this.message);

  @override
  List<Object?> get props => [message];
}
