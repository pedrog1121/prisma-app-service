import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../design/tokens.dart';

class GeoPoint {
  const GeoPoint(this.lat, this.lng);

  final double lat;
  final double lng;
}

/// Distancia en km entre dos puntos (fórmula de haversine).
double distanceKm(GeoPoint a, GeoPoint b) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.lat - a.lat);
  final dLng = rad(b.lng - a.lng);
  final h =
      math.pow(math.sin(dLat / 2), 2) + math.cos(rad(a.lat)) * math.cos(rad(b.lat)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(h));
}

/// Mapa ilustrativo de la ruta del día, con la ruta que se dibuja al abrir.
/// No usa teselas reales para que la vista previa funcione sin conexión.
class RouteMap extends StatefulWidget {
  const RouteMap({
    super.key,
    required this.origin,
    required this.stops,
    this.selected,
    this.padding = EdgeInsets.zero,
  });

  final GeoPoint origin;
  final List<GeoPoint> stops;
  final int? selected;

  /// Zona que tapan otros elementos (barra superior, hoja inferior).
  final EdgeInsets padding;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _MapPainter(
          origin: widget.origin,
          stops: widget.stops,
          selected: widget.selected,
          progress: Curves.easeInOutCubic.transform(_ctrl.value),
          padding: widget.padding,
          colors: c,
          dark: dark,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.origin,
    required this.stops,
    required this.selected,
    required this.progress,
    required this.padding,
    required this.colors,
    required this.dark,
  });

  final GeoPoint origin;
  final List<GeoPoint> stops;
  final int? selected;
  final double progress;
  final EdgeInsets padding;
  final PrismaColors colors;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = dark ? const Color(0xFF10131D) : const Color(0xFFE9ECF3);
    final block = dark ? const Color(0xFF171B27) : const Color(0xFFDFE3EC);
    final street = dark ? const Color(0xFF242939) : Colors.white;
    final park = dark ? const Color(0xFF14261E) : const Color(0xFFD3EAD6);
    final water = dark ? const Color(0xFF0F2236) : const Color(0xFFBEDAF3);

    canvas.drawRect(Offset.zero & size, Paint()..color = ground);

    final rnd = math.Random(11);
    final blockPaint = Paint()..color = block;
    for (double y = -20; y < size.height + 20; y += 36) {
      for (double x = -20; x < size.width + 20; x += 48) {
        final w = 32 + rnd.nextDouble() * 8;
        final h = 24 + rnd.nextDouble() * 6;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(4)), blockPaint);
      }
    }
    final parkPaint = Paint()..color = park;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.6, size.height * 0.2, 90, 60), const Radius.circular(10)),
        parkPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.08, size.height * 0.5, 70, 50), const Radius.circular(10)),
        parkPaint);
    final river = Path()
      ..moveTo(0, size.height * 0.12)
      ..cubicTo(size.width * 0.15, size.height * 0.18, size.width * 0.3, size.height * 0.05, size.width * 0.38, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(river, Paint()..color = water);

    final avenue = Paint()
      ..color = street
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.42), Offset(size.width, size.height * 0.28), avenue);
    canvas.drawLine(Offset(size.width * 0.32, 0), Offset(size.width * 0.52, size.height), avenue);
    canvas.drawLine(Offset(0, size.height * 0.72), Offset(size.width, size.height * 0.62), avenue);
    canvas.drawLine(Offset(size.width * 0.78, 0), Offset(size.width * 0.9, size.height), avenue..strokeWidth = 5);

    // Proyección a la zona visible
    final pts = [origin, ...stops];
    final minLat = pts.map((p) => p.lat).reduce(math.min);
    final maxLat = pts.map((p) => p.lat).reduce(math.max);
    final minLng = pts.map((p) => p.lng).reduce(math.min);
    final maxLng = pts.map((p) => p.lng).reduce(math.max);
    final area = Rect.fromLTRB(
      padding.left + 36,
      padding.top + 56,
      size.width - padding.right - 36,
      size.height - padding.bottom - 24,
    );
    final spanLat = math.max(maxLat - minLat, 0.004);
    final spanLng = math.max(maxLng - minLng, 0.004);
    Offset project(GeoPoint p) => Offset(
          area.left + (p.lng - minLng) / spanLng * area.width,
          area.top + (maxLat - p.lat) / spanLat * area.height,
        );
    final offsets = pts.map(project).toList();

    // Ruta con codos, para que parezca seguir las calles
    final route = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 1; i < offsets.length; i++) {
      final a = offsets[i - 1];
      final b = offsets[i];
      route.lineTo(b.dx, a.dy + (b.dy - a.dy) * 0.12);
      route.lineTo(b.dx, b.dy);
    }

    // Recorte según el progreso de la animación
    final metrics = route.computeMetrics().toList();
    final total = metrics.fold(0.0, (a, m) => a + m.length);
    var remaining = total * progress;
    final drawn = Path();
    for (final m in metrics) {
      if (remaining <= 0) break;
      drawn.addPath(m.extractPath(0, math.min(remaining, m.length)), Offset.zero);
      remaining -= m.length;
    }

    canvas.drawPath(
        drawn,
        Paint()
          ..color = colors.primary.withValues(alpha: 0.22)
          ..strokeWidth = 12
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round);
    canvas.drawPath(
        drawn,
        Paint()
          ..color = colors.primary
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round);

    // Distancia acumulada hasta cada parada, para hacerlas aparecer en orden
    final reachAt = <double>[0];
    var acc = 0.0;
    for (var i = 1; i < offsets.length; i++) {
      final a = offsets[i - 1];
      final b = offsets[i];
      final mid = Offset(b.dx, a.dy + (b.dy - a.dy) * 0.12);
      acc += (mid - a).distance + (b - mid).distance;
      reachAt.add(total == 0 ? 1 : acc / total);
    }

    // Técnico
    final me = offsets.first;
    canvas.drawCircle(me, 20, Paint()..color = colors.info.withValues(alpha: 0.18));
    canvas.drawCircle(me, 9, Paint()..color = Colors.white);
    canvas.drawCircle(me, 6.5, Paint()..color = colors.info);

    // Paradas
    for (var i = 1; i < offsets.length; i++) {
      final t = ((progress - reachAt[i] + 0.08) / 0.12).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final pop = Curves.easeOutBack.transform(t);
      final isSel = selected == i - 1;
      final color = isSel ? colors.danger : colors.primary;
      final r = (isSel ? 16.0 : 13.0) * pop;
      final cpt = offsets[i];
      final head = cpt.translate(0, -r - 8);
      final pin = Path()
        ..addOval(Rect.fromCircle(center: head, radius: r))
        ..moveTo(cpt.dx - r * 0.55, head.dy + r * 0.7)
        ..lineTo(cpt.dx, cpt.dy)
        ..lineTo(cpt.dx + r * 0.55, head.dy + r * 0.7)
        ..close();
      canvas.drawShadow(pin, Colors.black, 4, false);
      canvas.drawPath(pin, Paint()..color = color);
      canvas.drawCircle(
          head,
          r,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
              fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w700, fontSize: (isSel ? 14 : 12) * pop),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, head.translate(-tp.width / 2, -tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.progress != progress || old.selected != selected || old.dark != dark || old.padding != padding;
}

/// Contenedor translúcido que flota sobre el mapa.
class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding = const EdgeInsets.all(Space.md)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(color: c.border.withValues(alpha: 0.6)),
          ),
          child: child,
        ),
      ),
    );
  }
}
