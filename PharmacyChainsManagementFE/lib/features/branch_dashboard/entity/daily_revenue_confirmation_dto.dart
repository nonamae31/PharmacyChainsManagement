import 'package:equatable/equatable.dart';

class ConfirmDailyRevenueRequestDto extends Equatable {
  final double actualCash;
  final double actualBankTransfer;
  final double actualOther;
  final String? differenceReason;

  const ConfirmDailyRevenueRequestDto({
    required this.actualCash,
    required this.actualBankTransfer,
    required this.actualOther,
    this.differenceReason,
  });

  factory ConfirmDailyRevenueRequestDto.fromJson(Map<String, dynamic> json) => ConfirmDailyRevenueRequestDto(
        actualCash: (json['actualCash'] as num?)?.toDouble() ?? 0,
        actualBankTransfer: (json['actualBankTransfer'] as num?)?.toDouble() ?? 0,
        actualOther: (json['actualOther'] as num?)?.toDouble() ?? 0,
        differenceReason: json['differenceReason']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'actualCash': actualCash,
        'actualBankTransfer': actualBankTransfer,
        'actualOther': actualOther,
        'differenceReason': differenceReason,
      };

  @override
  List<Object?> get props => [actualCash, actualBankTransfer, actualOther, differenceReason];
}

class DailyRevenueConfirmationDto extends Equatable {
  final String confirmationId;
  final DateTime revenueDate;
  final double systemAmount;
  final double actualAmount;
  final double difference;
  final bool isMatched;
  final DateTime confirmedAt;

  const DailyRevenueConfirmationDto({
    required this.confirmationId,
    required this.revenueDate,
    required this.systemAmount,
    required this.actualAmount,
    required this.difference,
    required this.isMatched,
    required this.confirmedAt,
  });

  factory DailyRevenueConfirmationDto.fromJson(Map<String, dynamic> json) => DailyRevenueConfirmationDto(
        confirmationId: json['confirmationId'].toString(),
        revenueDate: DateTime.parse(json['revenueDate'].toString()),
        systemAmount: (json['systemAmount'] as num?)?.toDouble() ?? 0,
        actualAmount: (json['actualAmount'] as num?)?.toDouble() ?? 0,
        difference: (json['difference'] as num?)?.toDouble() ?? 0,
        isMatched: json['isMatched'] as bool? ?? false,
        confirmedAt: DateTime.parse(json['confirmedAt'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'confirmationId': confirmationId,
        'revenueDate': revenueDate.toIso8601String(),
        'systemAmount': systemAmount,
        'actualAmount': actualAmount,
        'difference': difference,
        'isMatched': isMatched,
        'confirmedAt': confirmedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [confirmationId, revenueDate, systemAmount, actualAmount, difference, isMatched, confirmedAt];
}
