import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key, required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final c = o.client;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Tarea'),
                Text(o.description, style: const TextStyle(height: 1.45)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Visita'),
                InfoRow(
                    icon: Icons.event_rounded,
                    label: 'Fecha',
                    value: '${Fmt.dayLong(o.scheduled)}, ${Fmt.time(o.scheduled)}'),
                InfoRow(
                    icon: Icons.timelapse_rounded,
                    label: 'Duración',
                    value: Fmt.durationShort(o.estimated)),
                InfoRow(icon: o.type.icon, label: 'Tipo', value: o.type.label),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Cliente'),
                InfoRow(icon: Icons.storefront_rounded, label: 'Nombre', value: '${c.name} (${c.id})'),
                InfoRow(
                    icon: Icons.place_rounded, label: 'Dirección', value: '${c.address}, ${c.city}'),
                InfoRow(icon: Icons.person_rounded, label: 'Contacto', value: c.contact),
                InfoRow(icon: Icons.phone_rounded, label: 'Teléfono', value: c.phone),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (o.contract != null)
          Card(
            color: AppColors.primary.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Contrato'),
                  InfoRow(icon: Icons.verified_rounded, label: 'Código', value: o.contract!.code),
                  InfoRow(icon: Icons.description_rounded, label: 'Plan', value: o.contract!.name),
                  InfoRow(
                      icon: Icons.repeat_rounded, label: 'Frecuencia', value: o.contract!.frequency),
                  InfoRow(
                      icon: Icons.timer_rounded,
                      label: 'SLA',
                      value: '${o.contract!.slaHours} h de respuesta'),
                  InfoRow(
                      icon: Icons.event_available_rounded,
                      label: 'Vigencia',
                      value: 'Hasta ${Fmt.date(o.contract!.validUntil)}'),
                  if (o.equipments.isNotEmpty)
                    InfoRow(
                        icon: Icons.precision_manufacturing_rounded,
                        label: 'Equipos',
                        value: '${o.equipmentsReviewed} de ${o.equipments.length} revisados'),
                ],
              ),
            ),
          )
        else
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded, color: AppColors.muted),
              title: Text('Orden sin contrato'),
              subtitle: Text('Se factura por visita. No requiere lecturas de equipos.'),
            ),
          ),
      ],
    );
  }
}
