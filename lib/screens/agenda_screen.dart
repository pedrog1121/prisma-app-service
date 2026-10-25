import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/order_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final today = DateTime.now();
        final todayOrders = store.ordersOn(today);
        final dayOrders = store.ordersOn(_day);
        final isToday = _day.day == today.day && _day.month == today.month;

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(store: store, todayOrders: todayOrders)),
              SliverToBoxAdapter(
                child: _WeekStrip(
                  selected: _day,
                  countFor: (d) => store.ordersOn(d).length,
                  onSelect: (d) => setState(() => _day = d),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                sliver: SliverToBoxAdapter(
                  child: SectionTitle(
                    isToday ? 'Hoy, ${Fmt.dayLong(_day).toLowerCase()}' : Fmt.dayLong(_day),
                    trailing: Text('${dayOrders.length} órdenes',
                        style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ),
                ),
              ),
              if (dayOrders.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.event_available_rounded,
                    title: 'Sin órdenes asignadas',
                    message: 'No tienes visitas programadas para este día.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: dayOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => OrderCard(order: dayOrders[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.store, required this.todayOrders});

  final AppStore store;
  final List<WorkOrder> todayOrders;

  @override
  Widget build(BuildContext context) {
    final pending = todayOrders.where((o) =>
        o.status == OrderStatus.pendiente || o.status == OrderStatus.enCamino).length;
    final active = todayOrders.where((o) =>
        o.status == OrderStatus.enProceso || o.status == OrderStatus.pausada).length;
    final done = todayOrders.where((o) => o.isClosed).length;
    final next = todayOrders.where((o) => !o.isClosed).firstOrNull;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF312E81), AppColors.primary, Color(0xFF4F46E5)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: Text(store.technician.initials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, ${store.technician.name.split(' ').first}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
                    Text(Fmt.dayLong(DateTime.now()),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF4ADE80)),
                    SizedBox(width: 6),
                    Text('En línea', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Stat(value: pending, label: 'Pendientes'),
              _Stat(value: active, label: 'En curso'),
              _Stat(value: done, label: 'Finalizadas'),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: 'Próxima visita  '),
                        TextSpan(
                            text: '${Fmt.time(next.scheduled)} · ${next.client.name}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value',
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5)),
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
    final n = DateTime.now();
    final start = DateTime(n.year, n.month, n.day).subtract(const Duration(days: 1));
    final days = List.generate(7, (i) => start.add(Duration(days: i)));

    return SizedBox(
      height: 84,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = days[i];
          final sel = d.day == selected.day && d.month == selected.month;
          final count = countFor(d);
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? AppColors.primary : AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Fmt.dayShort(d),
                      style: TextStyle(
                          fontSize: 12, color: sel ? Colors.white70 : AppColors.muted)),
                  const SizedBox(height: 2),
                  Text('${d.day}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : AppColors.text)),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: count == 0
                          ? Colors.transparent
                          : (sel ? Colors.white : AppColors.primaryLight),
                    ),
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
