import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../design/adaptive.dart';
import '../design/components.dart';
import '../design/tokens.dart';
import '../widgets/signature_pad.dart';

/// Pantalla dedicada para que el cliente firme la conformidad.
/// Devuelve true si se confirmó la firma.
class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key, required this.order});

  final WorkOrder order;

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  // Se trabaja sobre una copia: si se cancela, la firma anterior queda intacta.
  final List<List<Offset>> _strokes = [];
  late final _name = TextEditingController(
    text: widget.order.signerName.isEmpty ? widget.order.client.contact : widget.order.signerName,
  );
  Size _size = Size.zero;

  WorkOrder get o => widget.order;

  bool get _ready => _strokes.isNotEmpty && _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _confirm() {
    o
      ..signature = [for (final s in _strokes) List.of(s)]
      ..signatureSize = _size
      ..signerName = _name.text.trim()
      ..signedAt = DateTime.now();
    AppStore.instance.touch();
    Haptics.success();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;

    return Scaffold(
      backgroundColor: c.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: c.background,
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        centerTitle: true,
        title: Text('Firma del cliente', style: context.tt.titleMedium),
        actions: [
          AnimatedOpacity(
            opacity: _strokes.isEmpty ? 0.4 : 1,
            duration: Motion.fast,
            child: TextButton(
              onPressed: _strokes.isEmpty
                  ? null
                  : () {
                      Haptics.tap();
                      setState(_strokes.clear);
                    },
              child: const Text('Limpiar'),
            ),
          ),
          const SizedBox(width: Space.xs),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen de lo que se firma
            PrismaCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  IconBadge(icon: Icons.assignment_turned_in_outlined, color: c.onSelection, background: c.selection),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${o.number} · ${o.client.name}',
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
                        Text(o.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Nombre y aclaración',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: Space.md),
            Expanded(
              child: SignaturePad(
                strokes: _strokes,
                height: null,
                onChanged: () => setState(() {}),
                onSize: (s) => _size = s,
              ),
            ),
            const SizedBox(height: Space.md),
            Text(
              'Al firmar, ${_name.text.trim().isEmpty ? 'el cliente' : _name.text.trim()} confirma que el trabajo '
              'de la orden ${o.number} se realizó de conformidad.',
              textAlign: TextAlign.center,
              style: context.tt.bodySmall,
            ),
            const SizedBox(height: Space.md),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: FilledButton.icon(
          onPressed: _ready ? _confirm : null,
          icon: const Icon(Icons.check_rounded),
          label: Text(_strokes.isEmpty ? 'Firma en el recuadro' : 'Confirmar firma'),
        ),
      ),
    );
  }
}
