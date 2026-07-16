import 'package:equatable/equatable.dart';

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

  const BranchInventoryFetchRequested({this.search, this.category, this.status, this.page = 1});

  @override
  List<Object?> get props => [search, category, status, page];
}

final class BranchInventoryExportRequested extends BranchInventoryEvent {
  const BranchInventoryExportRequested();
}
