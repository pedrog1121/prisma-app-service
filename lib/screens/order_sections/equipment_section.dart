import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../design/adaptive.dart';
import '../../design/components.dart';
import '../../design/format.dart';
import '../../design/tokens.dart';
import '../../widgets/sparkline.dart';

/// Lecturas de los equipos del contrato para el mantenimiento predictivo.
class EquipmentSection extends StatelessWidget {
  const EquipmentSection({super.key, required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final alerts = order.equipments
        .expand((e) => e.measures.where((m) => e.readings[m.key] != null && m.isOutOfRange(e.readings[m.key]!)))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Space.md),
        AnimatedContainer(
          duration: Motion.medium,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: alerts > 0 ? c.dangerSoft : c.infoSoft,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(alerts > 0 ? Icons.warning_amber_rounded : Icons.insights_rounded,
                  size: 20, color: alerts > 0 ? c.dangerText : c.infoText),
              const SizedBox(width: Space.md),
              Expanded(
                child: Text(
                  alerts > 0
                      ? '$alerts lectura${alerts == 1 ? '' : 's'} fuera de rango. Al cerrar se genera una alerta predictiva en el ERP.'
                      : 'Carga las lecturas de cada equipo. Se comparan con las visitas anteriores del contrato.',
                  style: context.tt.bodySmall?.copyWith(color: alerts > 0 ? c.dangerText : c.infoText),
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < order.equipments.length; i++) ...[
          const SizedBox(height: Space.md),
          FadeSlideIn(index: i, child: _EquipmentCard(equipment: order.equipments[i], locked: order.isClosed)),
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
  late bool _open = !widget.equipment.reviewed;
  late final Map<String, TextEditingController> _ctrls = {
    for (final m in widget.equipment.measures)
      m.key: TextEditingController(
          text: widget.equipment.readings[m.key] == null ? '' : Fmt.number(widget.equipment.readings[m.key]!)),
  };

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final e = widget.equipment;
    final missing = e.measures.where((m) => e.readings[m.key] == null).length;
    if (missing > 0) {
      Haptics.warning();
      showToast(context, 'Falta${missing == 1 ? '' : 'n'} $missing lectura${missing == 1 ? '' : 's'} en este equipo',
          icon: Icons.error_outline_rounded);
      return;
    }
    Haptics.success();
    setState(() {
      e.reviewed = true;
      _open = false;
    });
    AppStore.instance.touch();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final e = widget.equipment;
    final editable = !widget.locked && !e.reviewed;
    final alerts = e.measures.where((m) => e.readings[m.key] != null && m.isOutOfRange(e.readings[m.key]!)).length;

    return PrismaCard(
      padding: EdgeInsets.zero,
      borderColor: alerts > 0 ? c.danger.withValues(alpha: 0.4) : null,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: Motion.medium,
                    transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                    child: e.reviewed
                        ? IconBadge(
                            key: const ValueKey('ok'),
                            icon: Icons.check_rounded,
                            color: c.successText,
                            background: c.successSoft)
                        : IconBadge(
                            key: const ValueKey('eq'),
                            icon: Icons.precision_manufacturing_outlined,
                            color: c.onSelection,
                            background: c.selection),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name, style: context.tt.titleSmall),
                        const SizedBox(height: 2),
                        Text('${e.brand} ${e.model} · ${e.location}', style: context.tt.bodySmall),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: Motion.medium,
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: c.faint),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: Motion.medium,
            curve: Motion.emphasized,
            alignment: Alignment.topCenter,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.7)))),
                    padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('S/N ${e.serial}', style: context.tt.bodySmall?.copyWith(color: c.faint)),
                        for (final m in e.measures) _measure(e, m, editable),
                        const SizedBox(height: Space.md),
                        if (!widget.locked)
                          e.reviewed
                              ? OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() => e.reviewed = false);
                                    AppStore.instance.touch();
                                  },
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('Editar lecturas'),
                                )
                              : FilledButton.tonalIcon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: c.selection,
                                    foregroundColor: c.onSelection,
                                    minimumSize: const Size(0, 48),
                                  ),
                                  onPressed: _save,
                                  icon: const Icon(Icons.check_rounded, size: 20),
                                  label: const Text('Guardar lecturas'),
                                ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _measure(Equipment e, MeasureDef m, bool editable) {
    final c = context.pc;
    final v = e.readings[m.key];
    final out = v != null && m.isOutOfRange(v);
    final last = m.history.last;
    final hasLimit = m.max < 99999;
    String? delta;
    if (v != null) {
      final d = v - last;
      delta = '${d >= 0 ? '▲' : '▼'} ${Fmt.number(d.abs())} ${m.unit}';
    }

    return Padding(
      padding: const EdgeInsets.only(top: Space.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.label, style: context.tt.titleSmall?.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  hasLimit
                      ? 'Rango ${Fmt.number(m.min)}–${Fmt.number(m.max)} · anterior ${Fmt.number(last)}'
                      : 'Anterior ${Fmt.number(last)} ${m.unit}',
                  style: context.tt.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: Space.sm),
                Row(
                  children: [
                    SizedBox(
                      width: 128,
                      child: TextField(
                        controller: _ctrls[m.key],
                        enabled: editable,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        style: context.tt.titleSmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
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
                          hintText: '—',
                          suffixText: m.unit,
                          fillColor: editable ? c.field : c.fieldReadonly,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Radii.md),
                            borderSide: BorderSide(color: out ? c.danger : c.input, width: out ? 1.5 : 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.sm),
                    if (delta != null)
                      Flexible(
                        child: Text(
                          out ? 'Fuera de rango' : delta,
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w600, color: out ? c.dangerText : c.successText),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Sparkline(values: m.history, max: m.max, current: v, width: 96),
          ),
        ],
      ),
    );
  }
}
