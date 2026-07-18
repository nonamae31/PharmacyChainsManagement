import 'package:equatable/equatable.dart';

sealed class InventoryDashboardEvent extends Equatable {
  const InventoryDashboardEvent();

  @override
  List<Object?> get props => [];
}

final class InventoryDashboardFetchRequested extends InventoryDashboardEvent {
  final String branchId;
  const InventoryDashboardFetchRequested(this.branchId);

  @override
  List<Object?> get props => [branchId];
}
