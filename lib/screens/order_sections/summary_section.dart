import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../design/components.dart';
import '../../design/format.dart';
import '../../design/tokens.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({super.key, required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final o = order;
    final cl = o.client;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Tarea', padding: EdgeInsets.fromLTRB(4, Space.md, 4, Space.sm)),
        PrismaCard(child: Text(o.description, style: context.tt.bodyLarge?.copyWith(height: 1.5))),
        const SectionLabel('Visita'),
        PrismaCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _Row(
                  icon: Icons.event_outlined,
                  label: 'Fecha',
                  value: '${Fmt.relativeDay(o.scheduled)}, ${Fmt.time(o.scheduled)}'),
              _Row(icon: Icons.timelapse_rounded, label: 'Duración estimada', value: Fmt.durationShort(o.estimated)),
              _Row(icon: o.type.icon, label: 'Tipo de trabajo', value: o.type.label, last: true),
            ],
          ),
        ),
        const SectionLabel('Cliente'),
        PrismaCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _Row(icon: Icons.storefront_outlined, label: cl.id, value: cl.name),
              _Row(icon: Icons.place_outlined, label: 'Dirección', value: '${cl.address}, ${cl.city}'),
              _Row(icon: Icons.person_outline_rounded, label: 'Contacto', value: cl.contact),
              _Row(icon: Icons.phone_outlined, label: 'Teléfono', value: cl.phone, last: true),
            ],
          ),
        ),
        const SectionLabel('Contrato'),
        if (o.contract != null)
          PrismaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(Space.lg),
                  color: c.sunken,
                  child: Row(
                    children: [
                      IconBadge(icon: Icons.verified_outlined, color: c.onSelection, background: c.selection),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.contract!.name, style: context.tt.titleSmall),
                            Text(o.contract!.code, style: context.tt.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _Row(icon: Icons.repeat_rounded, label: 'Frecuencia', value: o.contract!.frequency),
                _Row(icon: Icons.timer_outlined, label: 'SLA de respuesta', value: '${o.contract!.slaHours} h'),
                _Row(
                    icon: Icons.event_available_outlined,
                    label: 'Vigente hasta',
                    value: Fmt.date(o.contract!.validUntil)),
                if (o.equipments.isNotEmpty)
                  _Row(
                    icon: Icons.precision_manufacturing_outlined,
                    label: 'Equipos',
                    value: '${o.equipmentsReviewed} de ${o.equipments.length} revisados',
                    last: true,
                  ),
              ],
            ),
          )
        else
          PrismaCard(
            child: Row(
              children: [
                IconBadge(icon: Icons.receipt_long_outlined, color: c.muted, background: c.sunken),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sin contrato', style: context.tt.titleSmall),
                      Text('Se factura por visita. No requiere lecturas de equipos.', style: context.tt.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value, this.last = false});

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 13),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.7))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c.faint),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.tt.bodySmall?.copyWith(color: c.faint)),
                const SizedBox(height: 1),
                Text(value, style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
