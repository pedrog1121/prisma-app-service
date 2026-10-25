import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import '../widgets/order_card.dart';

enum _Filter { todas, pendientes, enCurso, finalizadas, contrato }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  _Filter _filter = _Filter.todas;
  String _query = '';

  bool _matches(WorkOrder o) {
    final ok = switch (_filter) {
      _Filter.todas => true,
      _Filter.pendientes =>
        o.status == OrderStatus.pendiente || o.status == OrderStatus.enCamino,
      _Filter.enCurso => o.status == OrderStatus.enProceso || o.status == OrderStatus.pausada,
      _Filter.finalizadas => o.isClosed,
      _Filter.contrato => o.hasContract,
    };
    if (!ok) return false;
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return o.number.toLowerCase().contains(q) ||
        o.client.name.toLowerCase().contains(q) ||
        o.title.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes de trabajo')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final list = store.orders.where(_matches).toList()
            ..sort((a, b) => a.scheduled.compareTo(b.scheduled));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por número, cliente o tarea',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final f in _Filter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(switch (f) {
                            _Filter.todas => 'Todas',
                            _Filter.pendientes => 'Pendientes',
                            _Filter.enCurso => 'En curso',
                            _Filter.finalizadas => 'Finalizadas',
                            _Filter.contrato => 'Con contrato',
                          }),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded, title: 'No hay órdenes con ese filtro')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => OrderCard(order: list[i], showDate: true),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
