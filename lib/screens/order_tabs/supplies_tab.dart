import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Insumos usados en la orden, descontados del stock de la camioneta.
class SuppliesTab extends StatefulWidget {
  const SuppliesTab({super.key, required this.order});

  final WorkOrder order;

  @override
  State<SuppliesTab> createState() => _SuppliesTabState();
}

class _SuppliesTabState extends State<SuppliesTab> {
  void _changed() {
    setState(() {});
    AppStore.instance.touch();
  }

  Future<void> _pickSupply() async {
    final selected = await showModalBottomSheet<Supply>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SupplyPicker(),
    );
    if (selected == null) return;
    final existing = widget.order.supplies.where((s) => s.supply.code == selected.code).firstOrNull;
    if (existing != null) {
      existing.qty += 1;
    } else {
      widget.order.supplies.add(UsedSupply(selected, 1));
    }
    _changed();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return Stack(
      children: [
        o.supplies.isEmpty
            ? const EmptyState(
                icon: Icons.inventory_2_rounded,
                title: 'Sin insumos registrados',
                message: 'Agrega los materiales que uses en esta visita.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  for (final s in o.supplies) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.supply.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                      '${s.supply.code} · ${Fmt.money(s.supply.price)} / ${s.supply.unit}',
                                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(Fmt.money((s.supply.price * s.qty).round()),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ],
                              ),
                            ),
                            _QtyStepper(
                              qty: s.qty,
                              unit: s.supply.unit,
                              step: s.supply.unit == 'un' ? 1 : 0.5,
                              enabled: !o.isClosed,
                              onChanged: (q) {
                                if (q <= 0) {
                                  o.supplies.remove(s);
                                } else {
                                  s.qty = q;
                                }
                                _changed();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Card(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Text('Total insumos', style: TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(Fmt.money(o.suppliesTotal),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        if (!o.isClosed)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: _pickSupply,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar insumo'),
            ),
          ),
      ],
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.unit,
    required this.step,
    required this.enabled,
    required this.onChanged,
  });

  final double qty;
  final String unit;
  final double step;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: enabled ? () => onChanged(qty - step) : null,
            icon: Icon(qty - step <= 0 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                size: 18),
          ),
          SizedBox(
            width: 44,
            child: Text('${Fmt.number(qty)} $unit',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: enabled ? () => onChanged(qty + step) : null,
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SupplyPicker extends StatefulWidget {
  const _SupplyPicker();

  @override
  State<_SupplyPicker> createState() => _SupplyPickerState();
}

class _SupplyPickerState extends State<_SupplyPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = MockData.supplies
        .where((s) =>
            s.name.toLowerCase().contains(_q.toLowerCase()) ||
            s.code.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Column(
        children: [
          const Text('Stock de la camioneta',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _q = v),
              decoration: const InputDecoration(
                hintText: 'Buscar insumo o código',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(indent: 16, endIndent: 16),
              itemBuilder: (_, i) {
                final s = list[i];
                final low = s.stock < 10;
                return ListTile(
                  onTap: () => Navigator.pop(context, s),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${s.code} · ${Fmt.money(s.price)} / ${s.unit}'),
                  trailing: Pill(
                    label: 'Stock ${Fmt.number(s.stock)} ${s.unit}',
                    color: low ? AppColors.warning : AppColors.success,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
