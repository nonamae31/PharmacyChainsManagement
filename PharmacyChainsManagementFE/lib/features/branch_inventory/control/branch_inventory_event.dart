import 'package:equatable/equatable.dart';

import '../entity/shipment_dto.dart';

sealed class BranchInventoryEvent extends Equatable {
  const BranchInventoryEvent();

  @override
  List<Object?> get props => [];
}

final class BranchInventoryFetchRequested extends BranchInventoryEvent {
  final String? search;
  final String? category;
  final String? status;
  final int page;

  const BranchInventoryFetchRequested({
    this.search,
    this.category,
    this.status,
    this.page = 1,
  });

  @override
  List<Object?> get props => [search, category, status, page];
}

final class BranchInventoryExportRequested extends BranchInventoryEvent {
  const BranchInventoryExportRequested();
}

final class BranchInventoryShipmentOptionsRequested
    extends BranchInventoryEvent {
  const BranchInventoryShipmentOptionsRequested();
}

final class BranchInventoryShipmentCreateRequested
    extends BranchInventoryEvent {
  final CreateShipmentRequestDto request;

  const BranchInventoryShipmentCreateRequested(this.request);

  @override
  List<Object?> get props => [request];
}
