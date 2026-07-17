import 'package:equatable/equatable.dart';

import '../entity/branch_inventory_dto.dart';
import '../entity/shipment_dto.dart';

sealed class BranchInventoryState extends Equatable {
  const BranchInventoryState();

  @override
  List<Object?> get props => [];
}

final class BranchInventoryInitial extends BranchInventoryState {
  const BranchInventoryInitial();
}

final class BranchInventoryLoading extends BranchInventoryState {
  const BranchInventoryLoading();
}

class BranchInventoryLoadSuccess extends BranchInventoryState {
  final BranchInventoryDto inventory;
  final String search;
  final String category;
  final String status;

  const BranchInventoryLoadSuccess({
    required this.inventory,
    this.search = '',
    this.category = 'all',
    this.status = 'all',
  });

  @override
  List<Object?> get props => [inventory, search, category, status];
}

final class BranchInventoryExportSuccess extends BranchInventoryLoadSuccess {
  final List<int> bytes;

  const BranchInventoryExportSuccess({
    required super.inventory,
    required super.search,
    required super.category,
    required super.status,
    required this.bytes,
  });

  @override
  List<Object?> get props => [...super.props, bytes];
}

final class BranchInventoryShipmentOptionsReady
    extends BranchInventoryLoadSuccess {
  final ShipmentOptionsDto options;

  const BranchInventoryShipmentOptionsReady({
    required super.inventory,
    required super.search,
    required super.category,
    required super.status,
    required this.options,
  });

  @override
  List<Object?> get props => [...super.props, options];
}

final class BranchInventoryOperationSuccess extends BranchInventoryLoadSuccess {
  final String message;

  const BranchInventoryOperationSuccess({
    required super.inventory,
    required super.search,
    required super.category,
    required super.status,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

final class BranchInventoryLoadFailure extends BranchInventoryState {
  final String message;

  const BranchInventoryLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
