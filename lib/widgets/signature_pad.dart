import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Área para que el cliente firme con el dedo. Guarda los trazos en [strokes].
class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key, required this.strokes, required this.onChanged, this.enabled = true});

  final List<List<Offset>> strokes;
  final VoidCallback onChanged;
  final bool enabled;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return AnimatedContainer(
      duration: Motion.medium,
      height: 200,
      decoration: BoxDecoration(
        color: widget.enabled ? c.field : c.fieldReadonly,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: widget.strokes.isEmpty ? c.input : c.ring, width: widget.strokes.isEmpty ? 1 : 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg - 1),
        child: Stack(
          children: [
            Positioned(
              left: 24,
              right: 24,
              bottom: 44,
              child: Row(
                children: [
                  Text('×', style: TextStyle(color: c.faint, fontSize: 18)),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 1, color: c.border)),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: widget.strokes.isEmpty ? 1 : 0,
              duration: Motion.fast,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.draw_outlined, color: c.faint),
                    const SizedBox(height: 4),
                    Text('El cliente firma aquí', style: TextStyle(color: c.faint, fontSize: 13)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onPanStart: widget.enabled ? (d) => setState(() => widget.strokes.add([d.localPosition])) : null,
              onPanUpdate: widget.enabled ? (d) => setState(() => widget.strokes.last.add(d.localPosition)) : null,
              onPanEnd: widget.enabled ? (_) => widget.onChanged() : null,
              child: CustomPaint(painter: _SignaturePainter(widget.strokes, c.foreground), size: Size.infinite),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes, this.color);

  final List<List<Offset>> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(s.first, 1.3, Paint()..color = color);
        continue;
      }
      // Curvas suaves entre puntos medios
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (var i = 1; i < s.length - 1; i++) {
        final mid = Offset.lerp(s[i], s[i + 1], 0.5)!;
        path.quadraticBezierTo(s[i].dx, s[i].dy, mid.dx, mid.dy);
      }
      path.lineTo(s.last.dx, s.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
