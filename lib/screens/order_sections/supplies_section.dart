import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../design/adaptive.dart';
import '../../design/components.dart';
import '../../design/format.dart';
import '../../design/order_styles.dart';
import '../../design/tokens.dart';

/// Insumos usados en la orden, tomados del stock de la camioneta.
class SuppliesSection extends StatefulWidget {
  const SuppliesSection({super.key, required this.order});

  final WorkOrder order;

  @override
  State<SuppliesSection> createState() => _SuppliesSectionState();
}

class _SuppliesSectionState extends State<SuppliesSection> {
  WorkOrder get o => widget.order;

  void _changed() {
    setState(() {});
    AppStore.instance.touch();
  }

  Future<void> _pick() async {
    final selected = await showPrismaSheet<Supply>(context, tall: true, builder: (_) => const _SupplyPicker());
    if (selected == null) return;
    final existing = o.supplies.where((s) => s.supply.code == selected.code).firstOrNull;
    if (existing != null) {
      existing.qty += existing.supply.unit == 'un' ? 1 : 0.5;
    } else {
      o.supplies.add(UsedSupply(selected, 1));
    }
    Haptics.success();
    _changed();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(
          'Usados en esta visita',
          padding: const EdgeInsets.fromLTRB(4, Space.md, 4, Space.sm),
          trailing: Text('${o.supplies.length}', style: context.tt.labelMedium),
        ),
        if (o.supplies.isEmpty)
          PrismaCard(
            child: Row(
              children: [
                IconBadge(icon: Icons.inventory_2_outlined, color: c.muted, background: c.sunken),
                const SizedBox(width: Space.md),
                Expanded(
                  child:
                      Text('Todavía no registraste insumos.', style: context.tt.bodyMedium?.copyWith(color: c.muted)),
                ),
              ],
            ),
          )
        else
          PrismaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < o.supplies.length; i++)
                  _SupplyRow(
                    key: ObjectKey(o.supplies[i]),
                    used: o.supplies[i],
                    last: i == o.supplies.length - 1,
                    enabled: !o.isClosed,
                    onChanged: (q) {
                      Haptics.tap();
                      if (q <= 0) {
                        o.supplies.removeAt(i);
                      } else {
                        o.supplies[i].qty = q;
                      }
                      _changed();
                    },
                  ),
                // Total en su propia superficie, sin color de marca
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 14),
                  decoration: BoxDecoration(
                    color: c.sunken,
                    border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.7))),
                  ),
                  child: Row(
                    children: [
                      Text('TOTAL INSUMOS', style: context.tt.labelSmall),
                      const Spacer(),
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: o.suppliesTotal.toDouble()),
                        duration: Motion.slow,
                        curve: Motion.enter,
                        builder: (_, v, __) => Text(
                          Fmt.money(v.round()),
                          style: context.tt.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (!o.isClosed) ...[
          const SizedBox(height: Space.md),
          OutlinedButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar insumo'),
          ),
        ],
      ],
    );
  }
}

class _SupplyRow extends StatelessWidget {
  const _SupplyRow({super.key, required this.used, required this.last, required this.enabled, required this.onChanged});

  final UsedSupply used;
  final bool last;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final s = used.supply;
    final step = s.unit == 'un' ? 1.0 : 0.5;
    return FadeSlideIn(
      offset: 8,
      child: Container(
        padding: const EdgeInsets.fromLTRB(Space.lg, 14, Space.md, 14),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.7))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name, style: context.tt.titleSmall),
                  const SizedBox(height: 2),
                  Text('${s.code} · ${Fmt.money(s.price)} / ${s.unit}', style: context.tt.bodySmall),
                  const SizedBox(height: 4),
                  Text(Fmt.money((s.price * used.qty).round()),
                      style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: c.sunken,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: c.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: enabled ? () => onChanged(used.qty - step) : null,
                    icon: Icon(used.qty - step <= 0 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                        size: 18, color: used.qty - step <= 0 ? c.dangerText : c.foreground),
                  ),
                  AnimatedSwitcher(
                    duration: Motion.fast,
                    transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                    child: SizedBox(
                      key: ValueKey(used.qty),
                      width: 46,
                      child: Text('${Fmt.number(used.qty)} ${s.unit}',
                          textAlign: TextAlign.center, style: context.tt.labelLarge?.copyWith(fontSize: 13.5)),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: enabled ? () => onChanged(used.qty + step) : null,
                    icon: Icon(Icons.add_rounded, size: 18, color: c.foreground),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final c = context.pc;
    final list = MockData.supplies
        .where(
            (s) => s.name.toLowerCase().contains(_q.toLowerCase()) || s.code.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stock de la camioneta', style: context.tt.titleLarge),
              const SizedBox(height: 2),
              Text('Elige el insumo que usaste.', style: context.tt.bodySmall),
              const SizedBox(height: Space.md),
              PrismaSearchField(placeholder: 'Buscar insumo o código', onChanged: (v) => setState(() => _q = v)),
            ],
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding:
                EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, MediaQuery.paddingOf(context).bottom + Space.lg),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              final low = s.stock < 10;
              return Padding(
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: PrismaCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () => Navigator.pop(context, s),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: context.tt.titleSmall),
                            Text('${s.code} · ${Fmt.money(s.price)} / ${s.unit}', style: context.tt.bodySmall),
                          ],
                        ),
                      ),
                      StateChip(
                        label: '${Fmt.number(s.stock)} ${s.unit}',
                        tone: low ? StateToneX.warning(c) : StateToneX.neutral(c),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
