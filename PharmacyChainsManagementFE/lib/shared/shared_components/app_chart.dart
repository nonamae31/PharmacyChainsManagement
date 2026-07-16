import 'package:flutter/material.dart';

import '../../core/theme/branch_manager_app_theme.dart';

class AppBarChart extends StatelessWidget {
  final List<double> values;
  final Color color;

  const AppBarChart({
    super.key,
    required this.values,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
            ? AppSpacing.metricHeight
            : AppSpacing.chartHeight,
        width: double.infinity,
        child: CustomPaint(painter: _BarChartPainter(values, color)),
      ),
    );
  }
}

class AppLineChart extends StatelessWidget {
  final List<double> values;

  const AppLineChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: constraints.maxWidth < AppSpacing.mobileHeaderBreakpoint
            ? AppSpacing.metricHeight
            : AppSpacing.chartHeight,
        width: double.infinity,
        child: CustomPaint(painter: _LineChartPainter(values)),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _BarChartPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maximum = values.reduce((a, b) => a > b ? a : b);
    final safeMaximum = maximum <= 0 ? 1.0 : maximum;
    final slot = size.width / values.length;
    final barWidth = slot * 0.54;
    final paint = Paint()..color = color;
    final mutedPaint = Paint()..color = AppColors.chartMuted;
    for (var index = 0; index < values.length; index++) {
      final height = values[index] / safeMaximum * size.height;
      final left = index * slot + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(AppRadius.small),
      );
      canvas.drawRRect(rect, index.isOdd ? paint : mutedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;

  const _LineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maximum = values.reduce((a, b) => a > b ? a : b);
    final safeMaximum = maximum <= 0 ? 1.0 : maximum;
    final step = values.length <= 1
        ? size.width
        : size.width / (values.length - 1);
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = index * step;
      final y =
          size.height -
          values[index] / safeMaximum * (size.height - AppSpacing.md);
      index == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.chartMuted, AppColors.surface],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = AppSpacing.xxs
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values;
}
