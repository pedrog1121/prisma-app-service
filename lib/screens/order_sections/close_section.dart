import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../design/components.dart';
import '../../design/format.dart';
import '../../design/tokens.dart';
import '../../widgets/signature_pad.dart';

/// Requisitos para poder cerrar la orden, con su estado.
List<(String, bool)> closeRequirements(WorkOrder o) => [
      ('Tiempo de trabajo registrado', o.totalElapsed > Duration.zero),
      if (o.hasContract && o.equipments.isNotEmpty)
        (
          'Lecturas de equipos (${o.equipmentsReviewed}/${o.equipments.length})',
          o.equipmentsReviewed == o.equipments.length
        ),
      if (o.checklist.isNotEmpty)
        ('Checklist (${o.checklistDone}/${o.checklist.length})', o.checklistDone == o.checklist.length),
      if (o.type == OrderType.preventivo)
        (
          'Fotos de antes y después',
          o.photos.any((p) => p.stage == PhotoStage.antes) && o.photos.any((p) => p.stage == PhotoStage.despues)
        ),
      ('Trabajo realizado', o.diagnosis.trim().isNotEmpty),
      ('Nombre de quien firma', o.signerName.trim().isNotEmpty),
      ('Firma del cliente', o.signature.isNotEmpty),
    ];

/// Trabajo realizado, conformidad del cliente y requisitos de cierre.
class CloseSection extends StatefulWidget {
  const CloseSection({super.key, required this.order});

  final WorkOrder order;

  @override
  State<CloseSection> createState() => _CloseSectionState();
}

class _CloseSectionState extends State<CloseSection> {
  late final _diagnosis = TextEditingController(text: widget.order.diagnosis);
  late final _signer = TextEditingController(text: widget.order.signerName);

  WorkOrder get o => widget.order;

  @override
  void dispose() {
    _diagnosis.dispose();
    _signer.dispose();
    super.dispose();
  }

  void _changed() {
    setState(() {});
    AppStore.instance.touch();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final reqs = closeRequirements(o);
    final done = reqs.where((r) => r.$2).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!o.isClosed) ...[
          SectionLabel(
            'Antes de cerrar',
            padding: const EdgeInsets.fromLTRB(4, Space.md, 4, Space.sm),
            trailing: Text('$done de ${reqs.length}', style: context.tt.labelMedium),
          ),
          PrismaCard(
            padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.md),
            child: Column(
              children: [
                for (final r in reqs)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: Motion.medium,
                          transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                          child: Icon(
                            r.$2 ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            key: ValueKey(r.$2),
                            size: 20,
                            color: r.$2 ? c.success : c.input,
                          ),
                        ),
                        const SizedBox(width: Space.md),
                        Expanded(
                          child:
                              Text(r.$1, style: context.tt.bodyMedium?.copyWith(color: r.$2 ? c.foreground : c.muted)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: Space.md),
            child: Container(
              padding: const EdgeInsets.all(Space.lg),
              decoration: BoxDecoration(color: c.successSoft, borderRadius: BorderRadius.circular(Radii.lg)),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, color: c.successText),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Text(
                      o.closedAt == null
                          ? 'Orden cerrada'
                          : 'Cerrada el ${Fmt.date(o.closedAt!)} a las ${Fmt.time(o.closedAt!)}',
                      style: context.tt.titleSmall?.copyWith(color: c.successText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SectionLabel('Trabajo realizado'),
        TextField(
          controller: _diagnosis,
          enabled: !o.isClosed,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) {
            o.diagnosis = v;
            _changed();
          },
          decoration: const InputDecoration(hintText: 'Diagnóstico y tareas realizadas'),
        ),
        SectionLabel(
          'Conformidad del cliente',
          trailing: o.signature.isNotEmpty && !o.isClosed
              ? GestureDetector(
                  onTap: () {
                    o.signature.clear();
                    _changed();
                  },
                  child: Text('Borrar firma', style: context.tt.labelMedium?.copyWith(color: c.primary)),
                )
              : null,
        ),
        TextField(
          controller: _signer,
          enabled: !o.isClosed,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) {
            o.signerName = v;
            _changed();
          },
          decoration: InputDecoration(
            labelText: 'Nombre y aclaración',
            hintText: o.client.contact,
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: Space.md),
        if (o.isClosed && o.signature.isEmpty)
          Container(
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.fieldReadonly, borderRadius: BorderRadius.circular(Radii.lg)),
            child: Text('Firmado por ${o.signerName}',
                style: context.tt.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: c.muted)),
          )
        else
          SignaturePad(strokes: o.signature, enabled: !o.isClosed, onChanged: _changed),
      ],
    );
  }
}
