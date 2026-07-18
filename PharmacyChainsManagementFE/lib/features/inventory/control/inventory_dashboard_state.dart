import 'package:equatable/equatable.dart';
import '../entity/inventory_valuation_response_dto.dart';

sealed class InventoryDashboardState extends Equatable {
  const InventoryDashboardState();
  
  @override
  List<Object?> get props => [];
}

final class InventoryDashboardInitial extends InventoryDashboardState {}

final class InventoryDashboardLoading extends InventoryDashboardState {}

final class InventoryDashboardLoadSuccess extends InventoryDashboardState {
  final InventoryValuationResponseDto valuation;

  const InventoryDashboardLoadSuccess(this.valuation);

  @override
  List<Object?> get props => [valuation];
}

final class InventoryDashboardLoadFailure extends InventoryDashboardState {
  final String message;

  const InventoryDashboardLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
