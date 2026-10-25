import 'package:flutter/material.dart';

import '../data/models.dart';
import '../design/adaptive.dart';
import '../design/components.dart';
import '../design/format.dart';
import '../design/order_styles.dart';
import '../design/tokens.dart';
import '../screens/order_detail_screen.dart';

/// Tarjeta de una orden. La jerarquía: hora y estado → cliente → tarea → metadatos.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.showDay = false});

  final WorkOrder order;
  final bool showDay;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final o = order;
    final pTone = o.priority.tone(c);

    return PrismaCard(
      accent: o.type.accent(c),
      padding: const EdgeInsets.fromLTRB(Space.lg + 4, 14, Space.lg, 14),
      onTap: () {
        Haptics.tap();
        pushPage(context, (_) => OrderDetailScreen(order: o));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                showDay ? '${Fmt.relativeDay(o.scheduled)} · ${Fmt.time(o.scheduled)}' : Fmt.time(o.scheduled),
                style: context.tt.titleSmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              const SizedBox(width: 6),
              Text('· ${Fmt.durationShort(o.estimated)}', style: context.tt.bodySmall),
              const Spacer(),
              StateChip(label: o.status.label, tone: o.status.tone(c)),
            ],
          ),
          const SizedBox(height: 10),
          Text(o.client.name, style: context.tt.titleMedium),
          const SizedBox(height: 2),
          Text(o.title,
              maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.bodyMedium?.copyWith(color: c.muted)),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Tag(label: o.type.label, marker: o.type.accent(c)),
              if (o.contract != null) Tag(label: o.contract!.code, icon: Icons.verified_outlined),
              if (pTone != null) StateChip(label: o.priority.label, tone: pTone, icon: Icons.priority_high_rounded),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 15, color: c.faint),
              const SizedBox(width: 4),
              Expanded(
                child: Text('${o.client.address}, ${o.client.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.tt.bodySmall?.copyWith(color: c.faint)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
