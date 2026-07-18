import 'package:equatable/equatable.dart';

class BatchTraceHistoryItemDto extends Equatable {
  final String timestamp; // ISO8601 string
  final String actionType;
  final String description;
  final String? locationId;
  final String? locationName;

  const BatchTraceHistoryItemDto({
    required this.timestamp,
    required this.actionType,
    required this.description,
    this.locationId,
    this.locationName,
  });

  factory BatchTraceHistoryItemDto.fromJson(Map<String, dynamic> json) =>
      BatchTraceHistoryItemDto(
        timestamp: json['timestamp'] as String,
        actionType: json['actionType'] as String,
        description: json['description'] as String,
        locationId: json['locationId'] as String?,
        locationName: json['locationName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'actionType': actionType,
        'description': description,
        'locationId': locationId,
        'locationName': locationName,
      };

  @override
  List<Object?> get props => [
        timestamp,
        actionType,
        description,
        locationId,
        locationName,
      ];
}

class BatchTraceabilityResponseDto extends Equatable {
  final String batchId;
  final String batchNumber;
  final String currentStatus;
  final List<BatchTraceHistoryItemDto> history;

  const BatchTraceabilityResponseDto({
    required this.batchId,
    required this.batchNumber,
    required this.currentStatus,
    required this.history,
  });

  factory BatchTraceabilityResponseDto.fromJson(Map<String, dynamic> json) {
    return BatchTraceabilityResponseDto(
      batchId: json['batchId'] as String,
      batchNumber: json['batchNumber'] as String,
      currentStatus: json['currentStatus'] as String,
      history: (json['history'] as List)
          .map((item) => BatchTraceHistoryItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'batchId': batchId,
        'batchNumber': batchNumber,
        'currentStatus': currentStatus,
        'history': history.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [batchId, batchNumber, currentStatus, history];
}
