import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../design/adaptive.dart';
import '../design/components.dart';
import '../design/format.dart';
import '../design/order_styles.dart';
import '../design/tokens.dart';
import '../widgets/route_map.dart';
import 'order_detail_screen.dart';

/// Velocidad promedio en ciudad para estimar tiempos de viaje.
const _avgKmh = 25.0;

/// Factor para pasar de distancia en línea recta a distancia por calles.
const _streetFactor = 1.3;

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  int? _selected;
  final _sheet = DraggableScrollableController();

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  Future<void> _navigate(Technician t, List<WorkOrder> stops) async {
    final dest = stops.last.client;
    final waypoints = stops.take(stops.length - 1).map((o) => '${o.client.lat},${o.client.lng}').join('|');
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': '${t.lat},${t.lng}',
      'destination': '${dest.lat},${dest.lng}',
      if (waypoints.isNotEmpty) 'waypoints': waypoints,
      'travelmode': 'driving',
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final c = context.pc;
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = store.technician;
          final stops = store.todayRoute;
          if (stops.isEmpty) {
            return const Center(
              child: EmptyState(
                icon: Icons.flag_rounded,
                title: 'Terminaste la ruta de hoy',
                message: 'No quedan visitas pendientes.',
              ),
            );
          }

          final legs = <double>[];
          var prev = GeoPoint(t.lat, t.lng);
          for (final o in stops) {
            final p = GeoPoint(o.client.lat, o.client.lng);
            legs.add(distanceKm(prev, p) * _streetFactor);
            prev = p;
          }
          final totalKm = legs.fold(0.0, (a, b) => a + b);
          final totalMin = (totalKm / _avgKmh * 60).round();
          const sheetMin = 0.34;

          return Stack(
            children: [
              Positioned.fill(
                child: RouteMap(
                  origin: GeoPoint(t.lat, t.lng),
                  stops: stops.map((o) => GeoPoint(o.client.lat, o.client.lng)).toList(),
                  selected: _selected,
                  padding: EdgeInsets.only(top: mq.padding.top + 64, bottom: mq.size.height * 0.42),
                ),
              ),
              // Encabezado flotante
              Positioned(
                top: mq.padding.top + Space.sm,
                left: Space.lg,
                right: Space.lg,
                child: FadeSlideIn(
                  offset: -12,
                  child: GlassPanel(
                    padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.md, Space.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ruta de hoy', style: context.tt.titleMedium),
                              Text(
                                '${stops.length} paradas · ${totalKm.toStringAsFixed(1)} km · ${Fmt.durationShort(Duration(minutes: totalMin))}',
                                style: context.tt.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Centrar',
                          style: IconButton.styleFrom(backgroundColor: c.selection, foregroundColor: c.onSelection),
                          onPressed: () => setState(() => _selected = null),
                          icon: const Icon(Icons.my_location_rounded, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Hoja con las paradas
              DraggableScrollableSheet(
                controller: _sheet,
                initialChildSize: 0.44,
                minChildSize: sheetMin,
                maxChildSize: 0.9,
                snap: true,
                snapSizes: const [sheetMin, 0.44, 0.9],
                builder: (context, scroll) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.elevated,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl + 4)),
                    boxShadow: c.raisedShadow,
                  ),
                  child: ListView(
                    controller: scroll,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, mq.padding.bottom + Space.xxl),
                    children: [
                      Center(
                        child: Container(
                          width: 38,
                          height: 5,
                          margin: const EdgeInsets.only(top: 10, bottom: Space.lg),
                          decoration: BoxDecoration(
                            color: c.strongBorder.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          Haptics.tap();
                          _navigate(t, stops);
                        },
                        icon: const Icon(Icons.navigation_rounded, size: 20),
                        label: const Text('Iniciar navegación'),
                      ),
                      const SectionLabel('Orden de visitas'),
                      for (var i = 0; i < stops.length; i++)
                        FadeSlideIn(
                          index: i,
                          child: _StopTile(
                            index: i,
                            order: stops[i],
                            legKm: legs[i],
                            isLast: i == stops.length - 1,
                            selected: _selected == i,
                            onTap: () {
                              Haptics.tap();
                              setState(() => _selected = _selected == i ? null : i);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.index,
    required this.order,
    required this.legKm,
    required this.isLast,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final WorkOrder order;
  final double legKm;
  final bool isLast;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final color = selected ? c.danger : c.primary;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: Motion.medium,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                if (!isLast)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(width: 2, color: c.border),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Space.md),
              child: PrismaCard(
                onTap: onTap,
                borderColor: selected ? color.withValues(alpha: 0.5) : null,
                padding: const EdgeInsets.all(14),
                child: AnimatedSize(
                  duration: Motion.medium,
                  curve: Motion.enter,
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(Fmt.time(order.scheduled), style: context.tt.titleSmall),
                          const SizedBox(width: Space.sm),
                          Text(
                            '${legKm.toStringAsFixed(1)} km · ${(legKm / _avgKmh * 60).round()} min',
                            style: context.tt.bodySmall,
                          ),
                          const Spacer(),
                          StateChip(label: order.status.label, tone: order.status.tone(c)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(order.client.name, style: context.tt.titleSmall?.copyWith(fontSize: 16)),
                      Text('${order.client.address}, ${order.client.city}', style: context.tt.bodySmall),
                      if (selected) ...[
                        const SizedBox(height: Space.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                                onPressed: () => launchUrl(
                                  Uri.https('www.google.com', '/maps/dir/', {
                                    'api': '1',
                                    'destination': '${order.client.lat},${order.client.lng}',
                                  }),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: const Text('Cómo llegar'),
                              ),
                            ),
                            const SizedBox(width: Space.sm),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                                onPressed: () => pushPage(context, (_) => OrderDetailScreen(order: order)),
                                child: const Text('Ver orden'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
