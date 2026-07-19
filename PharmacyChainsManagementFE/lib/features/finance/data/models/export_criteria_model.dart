import 'package:equatable/equatable.dart';

class ExportCriteriaModel extends Equatable {
  final String branchId;
  final DateTime startDate;
  final DateTime endDate;
  final String format;

  const ExportCriteriaModel({
    required this.branchId,
    required this.startDate,
    required this.endDate,
    required this.format,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'format': format.toUpperCase(),
    };
  }

  factory ExportCriteriaModel.fromJson(Map<String, dynamic> json) {
    return ExportCriteriaModel(
      branchId: json['branchId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      format: json['format'] as String,
    );
  }

  @override
  List<Object?> get props => [branchId, startDate, endDate, format];
}
