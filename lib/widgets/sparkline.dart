import 'package:flutter/material.dart';

import '../theme.dart';

/// Mini gráfico de tendencia de una medida. El último punto puede ser la
/// lectura de la visita actual, resaltada con otro color.
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, required this.max, this.current});

  final List<double> values;
  final double max;
  final double? current;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: 96,
      child: CustomPaint(painter: _SparkPainter(values, max, current)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.max, this.current);

  final List<double> values;
  final double max;
  final double? current;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...values, if (current != null) current!];
    if (all.length < 2) return;
    var lo = all.reduce((a, b) => a < b ? a : b);
    var hi = all.reduce((a, b) => a > b ? a : b);
    if (max < 99999 && max > hi) hi = hi + (max - hi) * 0.4;
    if (hi == lo) {
      hi += 1;
      lo -= 1;
    }

    Offset pt(int i, double v) => Offset(
          i / (all.length - 1) * (size.width - 6) + 3,
          size.height - 4 - (v - lo) / (hi - lo) * (size.height - 8),
        );

    // Línea de límite máximo
    if (max < 99999 && max <= hi) {
      final y = pt(0, max).dy;
      final dash = Paint()
        ..color = AppColors.danger.withValues(alpha: 0.45)
        ..strokeWidth = 1;
      for (double x = 0; x < size.width; x += 6) {
        canvas.drawLine(Offset(x, y), Offset(x + 3, y), dash);
      }
    }

    final line = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(pt(0, all[0]).dx, pt(0, all[0]).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(pt(i, all[i]).dx, pt(i, all[i]).dy);
    }
    canvas.drawPath(path, line);

    if (current != null) {
      final a = pt(values.length - 1, values.last);
      final b = pt(all.length - 1, current!);
      final over = current! > max;
      final c = over ? AppColors.danger : AppColors.success;
      canvas.drawLine(a, b, Paint()
        ..color = c
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round);
      canvas.drawCircle(b, 3.5, Paint()..color = c);
    } else {
      canvas.drawCircle(pt(values.length - 1, values.last), 3, Paint()..color = AppColors.primaryLight);
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) =>
      old.current != current || old.values != values || old.max != max;
}
