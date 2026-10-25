import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Tendencia de una medida con área, límite máximo y la lectura actual resaltada.
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, required this.max, this.current, this.width = 104});

  final List<double> values;
  final double max;
  final double? current;
  final double width;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Motion.enter,
      builder: (_, t, __) => SizedBox(
        height: 44,
        width: width,
        child: CustomPaint(painter: _SparkPainter(values, max, current, context.pc, t)),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.max, this.current, this.c, this.t);

  final List<double> values;
  final double max;
  final double? current;
  final PrismaColors c;
  final double t;

  bool get _hasLimit => max < 99999;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...values, if (current != null) current!];
    if (all.length < 2) return;
    var lo = all.reduce((a, b) => a < b ? a : b);
    var hi = all.reduce((a, b) => a > b ? a : b);
    if (_hasLimit) hi = hi > max ? hi : hi + (max - hi) * 0.5;
    if (hi == lo) {
      hi += 1;
      lo -= 1;
    }
    final pad = (hi - lo) * 0.12;
    lo -= pad;

    Offset pt(int i, double v) => Offset(
          i / (all.length - 1) * (size.width - 8) + 4,
          size.height - 4 - (v - lo) / (hi - lo) * (size.height - 8) * t,
        );

    // Grilla tenue
    final grid = Paint()
      ..color = c.border.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 2), Offset(size.width, size.height - 2), grid);

    // Límite
    if (_hasLimit && max <= hi) {
      final y = pt(0, max).dy;
      final dash = Paint()
        ..color = c.danger.withValues(alpha: 0.55)
        ..strokeWidth = 1;
      for (double x = 0; x < size.width; x += 5) {
        canvas.drawLine(Offset(x, y), Offset(x + 2.5, y), dash);
      }
    }

    // Área e historial
    final hist = Path()..moveTo(pt(0, all[0]).dx, pt(0, all[0]).dy);
    for (var i = 1; i < values.length; i++) {
      hist.lineTo(pt(i, all[i]).dx, pt(i, all[i]).dy);
    }
    final area = Path.from(hist)
      ..lineTo(pt(values.length - 1, values.last).dx, size.height - 2)
      ..lineTo(pt(0, all[0]).dx, size.height - 2)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.primary.withValues(alpha: 0.22), c.primary.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      hist,
      Paint()
        ..color = c.primary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (current != null) {
      final a = pt(values.length - 1, values.last);
      final b = pt(all.length - 1, current!);
      final over = _hasLimit && current! > max;
      final col = over ? c.danger : c.success;
      final dash = Paint()
        ..color = col
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      const steps = 5;
      for (var i = 0; i < steps; i += 2) {
        canvas.drawLine(Offset.lerp(a, b, i / steps)!, Offset.lerp(a, b, (i + 1) / steps)!, dash);
      }
      canvas.drawCircle(b, 5, Paint()..color = col.withValues(alpha: 0.25));
      canvas.drawCircle(b, 3.2, Paint()..color = col);
    } else {
      final e = pt(values.length - 1, values.last);
      canvas.drawCircle(e, 3.2, Paint()..color = c.primary);
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.current != current || old.t != t || old.c != c;
}
