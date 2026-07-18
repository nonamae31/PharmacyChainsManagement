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
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, progress, _) => CustomPaint(
            painter: _BarChartPainter(values, color, progress),
          ),
        ),
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
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, progress, _) => CustomPaint(
            painter: _LineChartPainter(values, progress),
          ),
        ),
      ),
    );
  }
}

void _drawGrid(Canvas canvas, Size size) {
  final gridPaint = Paint()
    ..color = AppColors.border
    ..strokeWidth = 1;
  const lines = 3;
  for (var i = 1; i <= lines; i++) {
    final y = size.height * i / (lines + 1);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double progress;

  const _BarChartPainter(this.values, this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    if (values.isEmpty) return;
    final maximum = values.reduce((a, b) => a > b ? a : b);
    final safeMaximum = maximum <= 0 ? 1.0 : maximum;
    final slot = size.width / values.length;
    final barWidth = slot * 0.54;
    final mutedPaint = Paint()..color = AppColors.chartMuted;
    for (var index = 0; index < values.length; index++) {
      final height = values[index] / safeMaximum * size.height * progress;
      final left = index * slot + (slot - barWidth) / 2;
      final barPaint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.55)],
            ).createShader(
              Rect.fromLTWH(left, size.height - height, barWidth, height),
            );
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(AppRadius.small),
      );
      canvas.drawRRect(rect, index.isOdd ? barPaint : mutedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.progress != progress;
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double progress;

  const _LineChartPainter(this.values, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    if (values.isEmpty) return;
    final maximum = values.reduce((a, b) => a > b ? a : b);
    final safeMaximum = maximum <= 0 ? 1.0 : maximum;
    final step = values.length <= 1
        ? size.width
        : size.width / (values.length - 1);
    final visibleCount = (values.length * progress).ceil().clamp(
      1,
      values.length,
    );
    final path = Path();
    for (var index = 0; index < visibleCount; index++) {
      final x = index * step;
      final y =
          size.height -
          values[index] / safeMaximum * (size.height - AppSpacing.md);
      index == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    final fill = Path.from(path)
      ..lineTo((visibleCount - 1).clamp(0, values.length - 1) * step, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.22),
            AppColors.surface.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = AppSpacing.xxs
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    final dotPaint = Paint()..color = AppColors.primary;
    final dotHalo = Paint()..color = AppColors.surface;
    for (var index = 0; index < visibleCount; index++) {
      final x = index * step;
      final y =
          size.height -
          values[index] / safeMaximum * (size.height - AppSpacing.md);
      canvas.drawCircle(Offset(x, y), 4.5, dotHalo);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.progress != progress;
}
