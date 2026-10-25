import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/route_map.dart';
import 'order_detail_screen.dart';

/// Velocidad promedio en ciudad para estimar tiempos de viaje.
const _avgKmh = 25.0;

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  int? _selected;

  Future<void> _openDirections(Technician t, List<WorkOrder> stops) async {
    if (stops.isEmpty) return;
    final dest = stops.last.client;
    final waypoints =
        stops.take(stops.length - 1).map((o) => '${o.client.lat},${o.client.lng}').join('|');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta del día')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final t = store.technician;
          final stops = store.todayRoute;
          if (stops.isEmpty) {
            return const EmptyState(
              icon: Icons.flag_rounded,
              title: 'Terminaste la ruta de hoy',
              message: 'No quedan visitas pendientes.',
            );
          }

          // Distancias por tramo
          final legs = <double>[];
          var prev = GeoPoint(t.lat, t.lng);
          for (final o in stops) {
            final p = GeoPoint(o.client.lat, o.client.lng);
            legs.add(distanceKm(prev, p) * 1.3); // factor por calles
            prev = p;
          }
          final totalKm = legs.fold(0.0, (a, b) => a + b);
          final totalMin = (totalKm / _avgKmh * 60).round();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              SizedBox(
                height: 300,
                child: RouteMap(
                  origin: GeoPoint(t.lat, t.lng),
                  stops: stops.map((o) => GeoPoint(o.client.lat, o.client.lng)).toList(),
                  selected: _selected,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Metric(icon: Icons.place_rounded, value: '${stops.length}', label: 'paradas'),
                  const SizedBox(width: 8),
                  _Metric(
                      icon: Icons.straighten_rounded,
                      value: '${totalKm.toStringAsFixed(1)} km',
                      label: 'recorrido'),
                  const SizedBox(width: 8),
                  _Metric(
                      icon: Icons.directions_car_rounded,
                      value: Fmt.durationShort(Duration(minutes: totalMin)),
                      label: 'manejando'),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _openDirections(t, stops),
                icon: const Icon(Icons.navigation_rounded),
                label: const Text('Iniciar navegación en Google Maps'),
              ),
              const SizedBox(height: 20),
              const SectionTitle('Orden de visitas'),
              for (var i = 0; i < stops.length; i++)
                _StopTile(
                  index: i,
                  order: stops[i],
                  legKm: legs[i],
                  isLast: i == stops.length - 1,
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = _selected == i ? null : i),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
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
    final color = selected ? AppColors.danger : AppColors.primary;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: color,
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: selected ? color : AppColors.border),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(Fmt.time(order.scheduled),
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Text('${legKm.toStringAsFixed(1)} km · ${(legKm / _avgKmh * 60).round()} min',
                                style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                            const Spacer(),
                            StatusPill(order.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(order.client.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text('${order.client.address}, ${order.client.city}',
                            style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                        if (selected) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => launchUrl(
                                    Uri.https('www.google.com', '/maps/dir/', {
                                      'api': '1',
                                      'destination': '${order.client.lat},${order.client.lng}',
                                    }),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  icon: const Icon(Icons.directions_rounded, size: 18),
                                  label: const Text('Cómo llegar'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => OrderDetailScreen(order: order))),
                                  icon: const Icon(Icons.assignment_rounded, size: 18),
                                  label: const Text('Ver orden'),
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
          ),
        ],
      ),
    );
  }
}
