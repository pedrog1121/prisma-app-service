import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/signature_pad.dart';

/// Diagnóstico, firma del cliente y cierre de la orden.
class CloseTab extends StatefulWidget {
  const CloseTab({super.key, required this.order});

  final WorkOrder order;

  @override
  State<CloseTab> createState() => _CloseTabState();
}

class _CloseTabState extends State<CloseTab> {
  late final _diagnosis = TextEditingController(text: widget.order.diagnosis);
  late final _signer = TextEditingController(text: widget.order.signerName);

  @override
  void dispose() {
    _diagnosis.dispose();
    _signer.dispose();
    super.dispose();
  }

  List<(String, bool)> _requirements() {
    final o = widget.order;
    return [
      ('Cronómetro iniciado', o.totalElapsed > Duration.zero),
      if (o.hasContract && o.equipments.isNotEmpty)
        ('Lecturas de equipos (${o.equipmentsReviewed}/${o.equipments.length})',
            o.equipmentsReviewed == o.equipments.length),
      if (o.checklist.isNotEmpty)
        ('Checklist (${o.checklistDone}/${o.checklist.length})',
            o.checklistDone == o.checklist.length),
      if (o.type == OrderType.preventivo)
        ('Fotos antes y después',
            o.photos.any((p) => p.stage == PhotoStage.antes) &&
                o.photos.any((p) => p.stage == PhotoStage.despues)),
      ('Diagnóstico o trabajo realizado', _diagnosis.text.trim().isNotEmpty),
      ('Nombre de quien firma', _signer.text.trim().isNotEmpty),
      ('Firma del cliente', o.signature.isNotEmpty),
    ];
  }

  Future<void> _close() async {
    final o = widget.order;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar la orden?'),
        content: Text(
            'Se enviará ${o.number} al ERP con ${Fmt.duration(o.totalElapsed)} de trabajo, '
            '${o.photos.length} foto(s) y ${o.supplies.length} insumo(s). Después no se puede editar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cerrar orden')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    AppStore.instance.closeOrder(o);
    showToast(context, 'Orden ${o.number} cerrada y sincronizada');
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final reqs = _requirements();
    final ready = reqs.every((r) => r.$2);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Trabajo realizado'),
                TextField(
                  controller: _diagnosis,
                  enabled: !o.isClosed,
                  maxLines: 4,
                  onChanged: (v) => setState(() => o.diagnosis = v),
                  decoration: const InputDecoration(
                    hintText: 'Describe el diagnóstico y lo que se hizo',
                  ),
                ),
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
                SectionTitle(
                  'Conformidad del cliente',
                  trailing: o.signature.isNotEmpty && !o.isClosed
                      ? TextButton.icon(
                          onPressed: () => setState(() => o.signature.clear()),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Borrar'),
                        )
                      : null,
                ),
                TextField(
                  controller: _signer,
                  enabled: !o.isClosed,
                  onChanged: (v) => setState(() => o.signerName = v),
                  decoration: InputDecoration(
                    labelText: 'Nombre y aclaración',
                    hintText: o.client.contact,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                if (o.isClosed && o.signature.isEmpty)
                  Container(
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('Firmado por ${o.signerName}',
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                  )
                else
                  SignaturePad(
                    strokes: o.signature,
                    enabled: !o.isClosed,
                    onChanged: () => setState(() {}),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (o.isClosed)
          Card(
            color: AppColors.success.withValues(alpha: 0.08),
            child: ListTile(
              leading: const Icon(Icons.check_circle_rounded, color: AppColors.success),
              title: const Text('Orden cerrada'),
              subtitle: Text(o.closedAt == null
                  ? ''
                  : '${Fmt.date(o.closedAt!)} a las ${Fmt.time(o.closedAt!)} · ${Fmt.money(o.suppliesTotal)} en insumos'),
            ),
          )
        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Antes de cerrar'),
                  for (final r in reqs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(r.$2 ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                              size: 20, color: r.$2 ? AppColors.success : AppColors.muted),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(r.$1,
                                  style: TextStyle(
                                      color: r.$2 ? AppColors.text : AppColors.muted))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: ready ? _close : null,
            icon: const Icon(Icons.task_alt_rounded),
            label: const Text('Finalizar orden'),
          ),
        ],
      ],
    );
  }
}
