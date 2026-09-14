import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../cards/app_cards.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key, required this.data, this.title});

  final List<DailyRevenue> data;
  final String? title;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? context.l10n.dailyRevenue,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 220,
          width: double.infinity,
          child: CustomPaint(painter: _RevenuePainter(data)),
        ),
        if (data.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppDateUtils.display(data.first.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                context.l10n.highestAmount(
                  CurrencyUtils.format(
                    data.map((e) => e.revenue).reduce(math.max),
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                AppDateUtils.display(data.last.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _RevenuePainter extends CustomPainter {
  _RevenuePainter(this.data);

  final List<DailyRevenue> data;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = AppColors.border.withValues(alpha: 0.7);
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (data.isEmpty) return;

    final maxValue = data.map((item) => item.revenue).fold<double>(0, math.max);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? size.width / 2
          : size.width * i / (data.length - 1);
      final y = size.height - (data[i].revenue / safeMax * (size.height - 12));
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = AppColors.primary.withValues(alpha: 0.10),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenuePainter oldDelegate) =>
      oldDelegate.data != data;
}
