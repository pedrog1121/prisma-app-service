import 'package:flutter/material.dart';

import '../data/models.dart';
import '../design/components.dart';
import '../design/format.dart';
import '../design/tokens.dart';

/// Confirmación animada después de cerrar una orden.
class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final WorkOrder order;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final o = widget.order;
    final circle = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.55, curve: Curves.easeOutBack));
    final check = CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1, curve: Curves.easeOutCubic));

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          child: Column(
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Transform.scale(
                  scale: circle.value,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(color: c.successSoft, shape: BoxShape.circle),
                    child: CustomPaint(painter: _CheckPainter(check.value, c.success)),
                  ),
                ),
              ),
              const SizedBox(height: Space.xxl),
              FadeSlideIn(index: 6, child: Text('Orden cerrada', style: context.tt.headlineMedium)),
              const SizedBox(height: Space.sm),
              FadeSlideIn(
                index: 7,
                child: Text(
                  '${o.number} · ${o.client.name}\nSe sincronizó con Prisma ERP.',
                  textAlign: TextAlign.center,
                  style: context.tt.bodyLarge?.copyWith(color: c.muted),
                ),
              ),
              const SizedBox(height: Space.xxl),
              FadeSlideIn(
                index: 8,
                child: PrismaCard(
                  child: Row(
                    children: [
                      _Fig(value: Fmt.durationShort(o.totalElapsed), label: 'Trabajo'),
                      _Fig(value: '${o.photos.length}', label: 'Fotos'),
                      _Fig(value: '${o.supplies.length}', label: 'Insumos'),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              FadeSlideIn(
                index: 9,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text('Volver a la agenda'),
                  ),
                ),
              ),
              const SizedBox(height: Space.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fig extends StatelessWidget {
  const _Fig({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: context.tt.titleMedium),
          const SizedBox(height: 2),
          Text(label, style: context.tt.bodySmall),
        ],
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.t, this.color);

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.52)
      ..lineTo(size.width * 0.45, size.height * 0.66)
      ..lineTo(size.width * 0.72, size.height * 0.38);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * t),
      Paint()
        ..color = color
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.t != t;
}
