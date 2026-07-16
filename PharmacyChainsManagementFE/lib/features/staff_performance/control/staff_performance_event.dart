import 'package:equatable/equatable.dart';

sealed class StaffPerformanceEvent extends Equatable {
  const StaffPerformanceEvent();

  @override
  List<Object?> get props => [];
}

final class StaffPerformanceFetchRequested extends StaffPerformanceEvent {
  final String? search;

  const StaffPerformanceFetchRequested({this.search});

  @override
  List<Object?> get props => [search];
}
