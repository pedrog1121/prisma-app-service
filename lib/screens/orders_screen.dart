import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../design/components.dart';
import '../design/format.dart';
import '../design/tokens.dart';
import '../widgets/order_card.dart';

enum _Filter { todas, pendientes, enCurso, contrato, finalizadas }

extension on _Filter {
  String get label => switch (this) {
        _Filter.todas => 'Todas',
        _Filter.pendientes => 'Pendientes',
        _Filter.enCurso => 'En curso',
        _Filter.contrato => 'Con contrato',
        _Filter.finalizadas => 'Finalizadas',
      };

  bool matches(WorkOrder o) => switch (this) {
        _Filter.todas => true,
        _Filter.pendientes => o.status == OrderStatus.pendiente || o.status == OrderStatus.enCamino,
        _Filter.enCurso => o.status == OrderStatus.enProceso || o.status == OrderStatus.pausada,
        _Filter.contrato => o.hasContract,
        _Filter.finalizadas => o.isClosed,
      };
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  _Filter _filter = _Filter.todas;
  String _query = '';

  bool _matchesQuery(WorkOrder o) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return o.number.toLowerCase().contains(q) ||
        o.client.name.toLowerCase().contains(q) ||
        o.title.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final base = store.orders.where(_matchesQuery).toList();
        final list = base.where(_filter.matches).toList()..sort((a, b) => a.scheduled.compareTo(b.scheduled));

        // Agrupar por día
        final groups = <DateTime, List<WorkOrder>>{};
        for (final o in list) {
          final d = DateTime(o.scheduled.year, o.scheduled.month, o.scheduled.day);
          groups.putIfAbsent(d, () => []).add(o);
        }

        var index = 0;
        return PrismaPage(
          title: 'Órdenes',
          slivers: [
            Gutter(
              sliver: SliverToBoxAdapter(
                child: PrismaSearchField(
                  placeholder: 'Buscar cliente, número o tarea',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(Space.gutter, Space.md, Space.gutter, 4),
                  children: [
                    for (final f in _Filter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: Space.sm),
                        child: FilterPill(
                          label: f.label,
                          count: base.where(f.matches).length,
                          selected: _filter == f,
                          onTap: () => setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (list.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Sin resultados',
                  message: 'Prueba con otro filtro o búsqueda.',
                ),
              )
            else
              for (final entry in groups.entries) ...[
                Gutter(
                  sliver: SliverToBoxAdapter(
                    child: SectionLabel(
                      entry.key.difference(DateTime.now()).inDays.abs() < 2
                          ? '${Fmt.relativeDay(entry.key)} · ${Fmt.dayMonth(entry.key)}'
                          : Fmt.dayLong(entry.key),
                      trailing: Text('${entry.value.length}', style: context.tt.labelMedium),
                    ),
                  ),
                ),
                Gutter(
                  sliver: SliverList.separated(
                    itemCount: entry.value.length,
                    separatorBuilder: (_, __) => const SizedBox(height: Space.md),
                    itemBuilder: (_, i) => FadeSlideIn(
                      key: ValueKey('${_filter.name}-${entry.value[i].number}'),
                      index: index++,
                      child: OrderCard(order: entry.value[i]),
                    ),
                  ),
                ),
              ],
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + Space.xxl)),
          ],
        );
      },
    );
  }
}
