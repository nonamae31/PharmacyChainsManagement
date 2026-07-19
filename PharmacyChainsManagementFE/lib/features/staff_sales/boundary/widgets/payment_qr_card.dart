import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../entity/staff_sales_dto.dart';

class PaymentQrCard extends StatefulWidget {
  final PaymentDto payment;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onRegenerate;

  const PaymentQrCard({
    super.key,
    required this.payment,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onRegenerate,
  });

  @override
  State<PaymentQrCard> createState() => _PaymentQrCardState();
}

class _PaymentQrCardState extends State<PaymentQrCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  int _secondsUntilRefresh = 5;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
      _refreshStatusWhenDue();
    });
  }

  @override
  void didUpdateWidget(covariant PaymentQrCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payment.expiresAt != widget.payment.expiresAt) {
      _updateRemaining();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final expiresAt = widget.payment.expiresAt;
    final remaining = expiresAt?.difference(DateTime.now()) ?? Duration.zero;
    if (mounted) {
      setState(
        () => _remaining = remaining.isNegative ? Duration.zero : remaining,
      );
    } else {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    }
  }

  void _refreshStatusWhenDue() {
    if (!const {
          'PENDING',
          'AMOUNT_MISMATCH',
        }.contains(widget.payment.paymentStatus) ||
        widget.isRefreshing ||
        _remaining == Duration.zero) {
      return;
    }
    _secondsUntilRefresh -= 1;
    if (_secondsUntilRefresh <= 0) {
      _secondsUntilRefresh = 5;
      widget.onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QrHeader(paymentStatus: widget.payment.paymentStatus),
          const SizedBox(height: AppSpacing.md),
          _QrImage(url: widget.payment.qrCodeUrl),
          const SizedBox(height: AppSpacing.md),
          _PaymentDetails(payment: widget.payment),
          const SizedBox(height: AppSpacing.md),
          _ExpirationLabel(remaining: _remaining),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.isRefreshing
                ? AppStrings.checkingPaymentStatus
                : AppStrings.qrAutomaticVerification,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          _QrActions(
            payment: widget.payment,
            isRefreshing: widget.isRefreshing,
            onRefresh: widget.onRefresh,
            onRegenerate: widget.onRegenerate,
          ),
        ],
      ),
    ),
  );
}

class _QrHeader extends StatelessWidget {
  final String paymentStatus;

  const _QrHeader({required this.paymentStatus});

  @override
  Widget build(BuildContext context) {
    final isPaid = paymentStatus == 'PAID';
    final isExpired = paymentStatus == 'EXPIRED';
    final isAmountMismatch = paymentStatus == 'AMOUNT_MISMATCH';
    return Row(
      children: [
        Icon(
          isPaid ? Icons.check_circle : Icons.qr_code_2,
          color: isPaid ? AppColors.success : AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            AppStrings.paymentQrTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Chip(
          label: Text(
            isPaid
                ? AppStrings.paymentPaid
                : isExpired
                ? AppStrings.paymentExpired
                : isAmountMismatch
                ? AppStrings.paymentAmountMismatch
                : AppStrings.waitingForPayment,
          ),
        ),
      ],
    );
  }
}

class _QrImage extends StatelessWidget {
  final String? url;

  const _QrImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const Center(child: Text(AppStrings.qrLoadFailure));
    }
    return Center(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 280,
        height: 280,
        fit: BoxFit.contain,
        placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, _, _) =>
            const Center(child: Text(AppStrings.qrLoadFailure)),
      ),
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  final PaymentDto payment;

  const _PaymentDetails({required this.payment});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _DetailRow(label: AppStrings.bank, value: payment.bankName),
      _DetailRow(label: AppStrings.accountName, value: payment.accountName),
      _DetailRow(label: AppStrings.accountNumber, value: payment.accountNumber),
      _DetailRow(
        label: AppStrings.invoiceAmount,
        value: '${payment.amount.toStringAsFixed(2)} ${payment.baseCurrency}',
      ),
      _DetailRow(
        label: AppStrings.exchangeRate,
        value: payment.exchangeRate == null
            ? null
            : '1 ${payment.baseCurrency} = '
                  '${NumberFormat.decimalPattern().format(payment.exchangeRate)} '
                  '${payment.settlementCurrency}',
      ),
      _DetailRow(
        label: AppStrings.transferAmount,
        value: payment.expectedAmountVnd == null
            ? null
            : '${NumberFormat.decimalPattern().format(payment.expectedAmountVnd)} '
                  '${payment.settlementCurrency}',
      ),
      _DetailRow(
        label: AppStrings.transferContent,
        value: payment.transferContent,
      ),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value ?? AppStrings.notAvailable,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _ExpirationLabel extends StatelessWidget {
  final Duration remaining;

  const _ExpirationLabel({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Text(
      '${AppStrings.expiresIn}: $minutes:$seconds',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: remaining == Duration.zero
            ? AppColors.error
            : AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _QrActions extends StatelessWidget {
  final PaymentDto payment;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onRegenerate;

  const _QrActions({
    required this.payment,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = payment.paymentStatus == 'EXPIRED';
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        OutlinedButton.icon(
          onPressed: payment.transferContent == null
              ? null
              : () async {
                  await Clipboard.setData(
                    ClipboardData(text: payment.transferContent!),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.transferContentCopied),
                      ),
                    );
                  }
                },
          icon: const Icon(Icons.copy),
          label: const Text(AppStrings.copyTransferContent),
        ),
        if (isExpired)
          FilledButton.icon(
            onPressed: onRegenerate,
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.regenerateQr),
          )
        else
          FilledButton.icon(
            onPressed: isRefreshing ? null : onRefresh,
            icon: const Icon(Icons.sync),
            label: const Text(AppStrings.refreshStatus),
          ),
      ],
    );
  }
}
