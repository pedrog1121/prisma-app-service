import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../design/adaptive.dart';
import '../design/components.dart';
import '../design/format.dart';
import '../design/tokens.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late DateTime _day;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _day = DateTime(n.year, n.month, n.day);
  }

  bool get _isToday {
    final n = DateTime.now();
    return _day.year == n.year && _day.month == n.month && _day.day == n.day;
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final c = context.pc;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final today = store.ordersOn(DateTime.now());
        final dayOrders = store.ordersOn(_day);
        final next = today.where((o) => !o.isClosed).firstOrNull;

        return PrismaPage(
          title: 'Hoy',
          trailing: _Avatar(initials: store.technician.initials),
          slivers: [
            Gutter(
              sliver: SliverToBoxAdapter(
                child: Text(Fmt.dayLong(DateTime.now()), style: context.tt.bodyLarge?.copyWith(color: c.muted)),
              ),
            ),
            Gutter(
              top: Space.lg,
              sliver: SliverToBoxAdapter(child: FadeSlideIn(child: _DaySummary(orders: today))),
            ),
            if (next != null)
              Gutter(
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Próxima visita'),
                      FadeSlideIn(index: 1, child: _NextVisit(order: next)),
                    ],
                  ),
                ),
              ),
            const Gutter(
              sliver: SliverToBoxAdapter(child: SectionLabel('Semana')),
            ),
            SliverToBoxAdapter(
              child: _WeekStrip(
                selected: _day,
                countFor: (d) => store.ordersOn(d).length,
                onSelect: (d) => setState(() => _day = d),
              ),
            ),
            Gutter(
              sliver: SliverToBoxAdapter(
                child: SectionLabel(
                  _isToday ? 'Visitas de hoy' : Fmt.dayLong(_day),
                  trailing: Text('${dayOrders.length}', style: context.tt.labelMedium),
                ),
              ),
            ),
            if (dayOrders.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.event_available_rounded,
                  title: 'Sin visitas asignadas',
                  message: 'No tienes órdenes programadas para este día.',
                ),
              )
            else
              Gutter(
                sliver: SliverList.list(
                  key: ValueKey(_day),
                  children: [
                    for (var i = 0; i < dayOrders.length; i++)
                      _TimelineItem(
                        order: dayOrders[i],
                        isFirst: i == 0,
                        isLast: i == dayOrders.length - 1,
                        child: FadeSlideIn(index: i, child: OrderCard(order: dayOrders[i])),
                      ),
                  ],
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + Space.xxl)),
          ],
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: PrismaColors.brandGradient),
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}

/// Resumen del día: progreso de visitas, horas planificadas y estado en línea.
class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.orders});

  final List<WorkOrder> orders;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final done = orders.where((o) => o.isClosed).length;
    final active = orders.where((o) => o.status == OrderStatus.enProceso || o.status == OrderStatus.pausada).length;
    final pending = orders.length - done - active;
    final planned = orders.fold(Duration.zero, (a, o) => a + o.estimated);

    return PrismaCard(
      padding: const EdgeInsets.all(Space.lg),
      child: Row(
        children: [
          ProgressRing(
            value: orders.isEmpty ? 0 : done / orders.length,
            color: c.success,
            track: c.sunken,
            size: 76,
            stroke: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedCount(value: done, style: context.tt.titleLarge),
                    Text('/${orders.length}', style: context.tt.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done == orders.length && orders.isNotEmpty ? 'Día completo' : 'Visitas completadas',
                  style: context.tt.titleSmall,
                ),
                const SizedBox(height: 2),
                Text('${Fmt.durationShort(planned)} planificadas', style: context.tt.bodySmall),
                const SizedBox(height: Space.md),
                Row(
                  children: [
                    _Mini(value: pending, label: 'Pendientes', color: c.muted),
                    const SizedBox(width: Space.lg),
                    _Mini(value: active, label: 'En curso', color: c.warningText),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedCount(value: value, style: context.tt.titleSmall?.copyWith(color: color)),
        const SizedBox(width: 4),
        Text(label, style: context.tt.bodySmall),
      ],
    );
  }
}

/// Tarjeta destacada de la próxima visita. Una sola acción principal.
class _NextVisit extends StatelessWidget {
  const _NextVisit({required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final o = order;
    final running = o.isRunning;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: c.border.withValues(alpha: 0.7)),
        boxShadow: c.raisedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Franja superior con el horario
          Container(
            padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.md),
            decoration: BoxDecoration(
              color: c.sunken,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
              border: Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.7))),
            ),
            child: Row(
              children: [
                if (running) PulseDot(color: c.warning) else Icon(Icons.schedule_rounded, size: 18, color: c.muted),
                const SizedBox(width: Space.sm),
                Text(
                  running
                      ? 'Trabajando ahora'
                      : DateTime.now().difference(o.scheduled).inMinutes > 30
                          ? '${Fmt.time(o.scheduled)} · con retraso'
                          : '${Fmt.time(o.scheduled)} · ${Fmt.fromNow(o.scheduled)}',
                  style: context.tt.labelLarge?.copyWith(fontSize: 14),
                ),
                const Spacer(),
                Text(o.number,
                    style: context.tt.bodySmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.client.name, style: context.tt.titleLarge),
                const SizedBox(height: 4),
                Text(o.title, style: context.tt.bodyMedium?.copyWith(color: c.muted)),
                const SizedBox(height: Space.md),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: c.faint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('${o.client.address}, ${o.client.city}',
                          style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: Space.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => launchUrl(
                          Uri.https('www.google.com', '/maps/dir/', {
                            'api': '1',
                            'destination': '${o.client.lat},${o.client.lng}',
                          }),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.near_me_outlined, size: 18),
                        label: const Text('Cómo llegar'),
                      ),
                    ),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => pushPage(context, (_) => OrderDetailScreen(order: o)),
                        child: Text(running ? 'Continuar' : 'Abrir orden'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selected, required this.countFor, required this.onSelect});

  final DateTime selected;
  final int Function(DateTime) countFor;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final start = today.subtract(const Duration(days: 1));
    final days = List.generate(8, (i) => start.add(Duration(days: i)));

    return SizedBox(
      height: 76,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: Space.sm),
        itemBuilder: (_, i) {
          final d = days[i];
          final sel = d == selected;
          final isToday = d == today;
          final count = countFor(d);
          return Pressable(
            onTap: () {
              Haptics.tap();
              onSelect(d);
            },
            child: AnimatedContainer(
              duration: Motion.medium,
              curve: Motion.enter,
              width: 52,
              decoration: BoxDecoration(
                color: sel ? c.selection : c.surface,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(
                  color: sel ? c.onSelection.withValues(alpha: 0.3) : c.border.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Fmt.dayShort(d),
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: sel ? c.onSelection : c.faint)),
                  const SizedBox(height: 2),
                  Text('${d.day}',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: sel ? c.onSelection : (isToday ? c.primary : c.foreground))),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var k = 0; k < count.clamp(0, 3); k++)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sel ? c.onSelection : c.input,
                          ),
                        ),
                      if (count == 0) const SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Riel de línea de tiempo a la izquierda de cada tarjeta.
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.order, required this.isFirst, required this.isLast, required this.child});

  final WorkOrder order;
  final bool isFirst;
  final bool isLast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final done = order.isClosed;
    final active = order.status == OrderStatus.enProceso || order.status == OrderStatus.pausada;
    final dotColor = done ? c.success : (active ? c.warning : c.surface);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(width: 2, height: 24, color: isFirst ? Colors.transparent : c.border),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: done || active ? dotColor : c.input, width: 2),
                  ),
                  child: done ? const Icon(Icons.check, size: 8, color: Colors.white) : null,
                ),
                Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : c.border)),
              ],
            ),
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Padding(padding: const EdgeInsets.only(bottom: Space.md), child: child),
          ),
        ],
      ),
    );
  }
}
