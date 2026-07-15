import 'package:equatable/equatable.dart';

sealed class IssueStockState extends Equatable {
  const IssueStockState();
  
  @override
  List<Object?> get props => [];
}

final class IssueStockInitial extends IssueStockState {}

final class IssueStockLoading extends IssueStockState {}

final class IssueStockSuccess extends IssueStockState {}

final class IssueStockFailure extends IssueStockState {
  final String message;

  const IssueStockFailure(this.message);

  @override
  List<Object?> get props => [message];
}
