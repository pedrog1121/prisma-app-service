import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

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
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) * math.cos(rad(b.lat)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(h));
}

/// Mapa ilustrativo de la ruta del día. No usa teselas reales para que la
/// vista previa funcione sin conexión; en producción se reemplaza por un mapa real.
class RouteMap extends StatelessWidget {
  const RouteMap({super.key, required this.origin, required this.stops, this.selected});

  final GeoPoint origin;
  final List<GeoPoint> stops;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: _MapPainter(origin, stops, selected),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.origin, this.stops, this.selected);

  final GeoPoint origin;
  final List<GeoPoint> stops;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEDEFF5));

    final rnd = math.Random(7);
    // Manzanas
    final block = Paint()..color = const Color(0xFFE2E5EE);
    for (double y = -20; y < size.height + 20; y += 34) {
      for (double x = -20; x < size.width + 20; x += 46) {
        final w = 30 + rnd.nextDouble() * 10;
        final h = 22 + rnd.nextDouble() * 6;
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(3)), block);
      }
    }
    // Parques
    final park = Paint()..color = const Color(0xFFD5EBD3);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.58, size.height * 0.18, 70, 46), const Radius.circular(6)),
        park);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.12, size.height * 0.62, 56, 40), const Radius.circular(6)),
        park);
    // Río
    final river = Path()
      ..moveTo(0, size.height * 0.05)
      ..quadraticBezierTo(size.width * 0.18, size.height * 0.12, size.width * 0.22, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(river, Paint()..color = const Color(0xFFBFDBF5));
    // Avenidas
    final avenue = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.30), avenue);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.55, size.height), avenue);
    canvas.drawLine(Offset(0, size.height * 0.80), Offset(size.width, size.height * 0.68), avenue);

    // Proyección de coordenadas al lienzo
    final pts = [origin, ...stops];
    var minLat = pts.map((p) => p.lat).reduce(math.min);
    var maxLat = pts.map((p) => p.lat).reduce(math.max);
    var minLng = pts.map((p) => p.lng).reduce(math.min);
    var maxLng = pts.map((p) => p.lng).reduce(math.max);
    final padLat = math.max((maxLat - minLat) * 0.05, 0.002);
    final padLng = math.max((maxLng - minLng) * 0.05, 0.002);
    minLat -= padLat;
    maxLat += padLat;
    minLng -= padLng;
    maxLng += padLng;
    // Margen en píxeles para que los marcadores no se corten en los bordes
    final area = Rect.fromLTRB(28, 48, size.width - 28, size.height - 18);
    Offset project(GeoPoint p) => Offset(
          area.left + (p.lng - minLng) / (maxLng - minLng) * area.width,
          area.top + (maxLat - p.lat) / (maxLat - minLat) * area.height,
        );

    final offsets = pts.map(project).toList();

    // Ruta con codos, para que parezca seguir las calles
    final route = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 1; i < offsets.length; i++) {
      final a = offsets[i - 1];
      final b = offsets[i];
      route.lineTo(b.dx, a.dy + (b.dy - a.dy) * 0.15);
      route.lineTo(b.dx, b.dy);
    }
    canvas.drawPath(
        route,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.25)
          ..strokeWidth = 9
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(
        route,
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round);

    // Posición del técnico
    final me = offsets.first;
    canvas.drawCircle(me, 16, Paint()..color = AppColors.accent.withValues(alpha: 0.22));
    canvas.drawCircle(me, 8, Paint()..color = Colors.white);
    canvas.drawCircle(me, 6, Paint()..color = AppColors.accent);

    // Paradas
    for (var i = 1; i < offsets.length; i++) {
      final isSel = selected == i - 1;
      final c = offsets[i];
      final color = isSel ? AppColors.danger : AppColors.primary;
      final r = isSel ? 15.0 : 12.0;
      final pin = Path()
        ..addOval(Rect.fromCircle(center: c.translate(0, -r - 6), radius: r))
        ..moveTo(c.dx - r * 0.6, c.dy - r - 2)
        ..lineTo(c.dx, c.dy)
        ..lineTo(c.dx + r * 0.6, c.dy - r - 2)
        ..close();
      canvas.drawShadow(pin, Colors.black, 3, false);
      canvas.drawPath(pin, Paint()..color = color);
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isSel ? 14 : 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c.translate(-tp.width / 2, -r - 6 - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.selected != selected || old.stops != stops;
}
