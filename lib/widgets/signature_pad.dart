import 'package:flutter/material.dart';

import '../theme.dart';

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
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: Container(height: 1, color: AppColors.border),
            ),
            if (widget.strokes.isEmpty)
              const Center(
                child: Text('Firma del cliente aquí',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ),
            GestureDetector(
              onPanStart: widget.enabled
                  ? (d) => setState(() => widget.strokes.add([d.localPosition]))
                  : null,
              onPanUpdate: widget.enabled
                  ? (d) => setState(() => widget.strokes.last.add(d.localPosition))
                  : null,
              onPanEnd: widget.enabled ? (_) => widget.onChanged() : null,
              child: CustomPaint(
                painter: _SignaturePainter(widget.strokes),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E1B4B)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final s in strokes) {
      if (s.length == 1) {
        canvas.drawCircle(s.first, 1.3, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (var i = 1; i < s.length; i++) {
        path.lineTo(s[i].dx, s[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
