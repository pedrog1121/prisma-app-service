import 'package:flutter/material.dart';

import '../data/models.dart';
import '../screens/order_detail_screen.dart';
import '../theme.dart';
import 'common.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.showDate = false});

  final WorkOrder order;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o))),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: o.priority.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 15, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            showDate
                                ? '${Fmt.dayShort(o.scheduled)} ${Fmt.date(o.scheduled).substring(0, 5)} · ${Fmt.time(o.scheduled)}'
                                : Fmt.time(o.scheduled),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text('  ·  ${Fmt.durationShort(o.estimated)}',
                              style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                          const Spacer(),
                          StatusPill(o.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(o.client.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(o.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 13.5)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Pill(label: o.type.label, color: AppColors.text, icon: o.type.icon),
                          if (o.contract != null) ContractPill(o.contract!),
                          if (o.priority.index >= Priority.alta.index)
                            Pill(
                                label: o.priority.label,
                                color: o.priority.color,
                                icon: Icons.priority_high_rounded),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.place_outlined, size: 14, color: AppColors.muted),
                              const SizedBox(width: 2),
                              Text(o.client.address,
                                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
