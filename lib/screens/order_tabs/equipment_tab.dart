import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/sparkline.dart';

/// Lecturas de equipos del contrato para el mantenimiento predictivo.
class EquipmentTab extends StatelessWidget {
  const EquipmentTab({super.key, required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final alerts = order.equipments
        .expand((e) => e.measures.where(
            (m) => e.readings[m.key] != null && m.isOutOfRange(e.readings[m.key]!)))
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: alerts > 0
                ? AppColors.danger.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(alerts > 0 ? Icons.warning_amber_rounded : Icons.insights_rounded,
                  color: alerts > 0 ? AppColors.danger : AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alerts > 0
                      ? '$alerts lectura(s) fuera de rango. Se generará una alerta predictiva en el ERP.'
                      : 'Carga las lecturas de cada equipo. Se comparan con las visitas anteriores.',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final e in order.equipments) ...[
          _EquipmentCard(equipment: e, locked: order.isClosed),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _EquipmentCard extends StatefulWidget {
  const _EquipmentCard({required this.equipment, required this.locked});

  final Equipment equipment;
  final bool locked;

  @override
  State<_EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<_EquipmentCard> {
  late final Map<String, TextEditingController> _ctrls = {
    for (final m in widget.equipment.measures)
      m.key: TextEditingController(
          text: widget.equipment.readings[m.key] == null
              ? ''
              : Fmt.number(widget.equipment.readings[m.key]!)),
  };

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.equipment;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: !e.reviewed,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundColor:
              e.reviewed ? AppColors.success.withValues(alpha: 0.12) : AppColors.background,
          child: Icon(e.reviewed ? Icons.check_rounded : Icons.precision_manufacturing_rounded,
              color: e.reviewed ? AppColors.success : AppColors.primary),
        ),
        title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${e.brand} ${e.model} · S/N ${e.serial}\n${e.location}',
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (final m in e.measures) _measureRow(e, m),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: e.notes,
            enabled: !widget.locked,
            maxLines: 2,
            onChanged: (v) => e.notes = v,
            decoration: const InputDecoration(
                labelText: 'Observaciones del equipo', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: e.reviewed
                ? OutlinedButton.icon(
                    onPressed: widget.locked
                        ? null
                        : () {
                            setState(() => e.reviewed = false);
                            AppStore.instance.touch();
                          },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Editar lecturas'),
                  )
                : FilledButton.icon(
                    onPressed: widget.locked
                        ? null
                        : () {
                            final missing =
                                e.measures.where((m) => e.readings[m.key] == null).length;
                            if (missing > 0) {
                              showToast(context, 'Faltan $missing lectura(s) en este equipo',
                                  icon: Icons.error_outline_rounded);
                              return;
                            }
                            setState(() => e.reviewed = true);
                            AppStore.instance.touch();
                            showToast(context, '${e.name}: lecturas guardadas');
                          },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Guardar lecturas'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _measureRow(Equipment e, MeasureDef m) {
    final v = e.readings[m.key];
    final out = v != null && m.isOutOfRange(v);
    final last = m.history.last;
    final hasLimit = m.max < 99999;
    String? delta;
    if (v != null) {
      final d = v - last;
      delta = '${d >= 0 ? '+' : ''}${Fmt.number(d)} vs. anterior';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(
                  hasLimit
                      ? 'Rango ${Fmt.number(m.min)}–${Fmt.number(m.max)} ${m.unit} · última ${Fmt.number(last)}'
                      : 'Última lectura ${Fmt.number(last)} ${m.unit}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _ctrls[m.key],
                    enabled: !widget.locked && !e.reviewed,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (s) {
                      final parsed = double.tryParse(s.replaceAll(',', '.'));
                      setState(() {
                        if (parsed == null) {
                          e.readings.remove(m.key);
                        } else {
                          e.readings[m.key] = parsed;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      suffixText: m.unit,
                      hintText: 'Lectura',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: out ? AppColors.danger : AppColors.border),
                      ),
                    ),
                  ),
                ),
                if (delta != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      out ? 'Fuera de rango · $delta' : delta,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: out ? FontWeight.w600 : FontWeight.w400,
                          color: out ? AppColors.danger : AppColors.success),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Sparkline(values: m.history, max: m.max, current: v),
          ),
        ],
      ),
    );
  }
}
