import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../design/adaptive.dart';
import '../design/components.dart';
import '../design/format.dart';
import '../design/order_styles.dart';
import '../design/tokens.dart';
import 'order_sections/close_section.dart';
import 'order_sections/equipment_section.dart';
import 'order_sections/photos_section.dart';
import 'order_sections/summary_section.dart';
import 'order_sections/supplies_section.dart';
import 'order_success_screen.dart';

enum _Section { detalle, equipos, fotos, insumos, cierre }

extension on _Section {
  String get label => switch (this) {
        _Section.detalle => 'Detalle',
        _Section.equipos => 'Equipos',
        _Section.fotos => 'Fotos',
        _Section.insumos => 'Insumos',
        _Section.cierre => 'Cierre',
      };
}

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});

  final WorkOrder order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  _Section _section = _Section.detalle;
  final _scroll = ScrollController();

  WorkOrder get o => widget.order;

  /// La carga de equipos para predictivo solo aplica a órdenes de contrato.
  List<_Section> get _sections => [
        _Section.detalle,
        if (o.hasContract && o.equipments.isNotEmpty) _Section.equipos,
        _Section.fotos,
        _Section.insumos,
        _Section.cierre,
      ];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goTo(_Section s) {
    setState(() => _section = s);
    // Lleva el contenido al inicio de la sección sin perder el encabezado
    if (_scroll.hasClients && _scroll.offset > 320) {
      _scroll.animateTo(320, duration: Motion.medium, curve: Motion.enter);
    }
  }

  Future<void> _close() async {
    final ok = await confirmAction(
      context,
      title: '¿Cerrar la orden?',
      message: 'Se enviará ${o.number} al ERP con ${Fmt.durationShort(o.totalElapsed)} de trabajo, '
          '${o.photos.length} fotos y ${o.supplies.length} insumos. Después no se puede editar.',
      confirmLabel: 'Cerrar orden',
    );
    if (!ok || !mounted) return;
    AppStore.instance.closeOrder(o);
    Haptics.success();
    await Navigator.of(context).push(PageRouteBuilder<void>(
      transitionDuration: Motion.slow,
      pageBuilder: (_, __, ___) => OrderSuccessScreen(order: o),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final sections = _sections;
    if (!sections.contains(_section)) _section = _Section.detalle;

    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) => PrismaPage(
        title: o.number,
        previousTitle: 'Volver',
        compact: true,
        controller: _scroll,
        trailing: IconButton(
          tooltip: 'Llamar a ${o.client.contact}',
          onPressed: () => launchUrl(Uri(scheme: 'tel', path: o.client.phone.replaceAll(' ', ''))),
          icon: Icon(isCupertino(context) ? CupertinoIcons.phone : Icons.call_outlined, color: c.primary),
        ),
        bottomBar: o.isClosed
            ? null
            : _ActionBar(order: o, section: _section, onClose: _close, onGoToClose: () => _goTo(_Section.cierre)),
        slivers: [
          Gutter(sliver: SliverToBoxAdapter(child: FadeSlideIn(child: _Header(order: o)))),
          Gutter(
            top: Space.lg,
            sliver: SliverToBoxAdapter(child: FadeSlideIn(index: 1, child: _WorkPanel(order: o))),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedTabs(
              child: PillTabs(
                labels: [for (final s in sections) s.label],
                selected: sections.indexOf(_section),
                onChanged: (i) => _goTo(sections[i]),
              ),
              color: c.background,
            ),
          ),
          Gutter(
            top: Space.sm,
            sliver: SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: Motion.medium,
                switchInCurve: Motion.enter,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, if (current != null) current],
                ),
                child: KeyedSubtree(
                  key: ValueKey(_section),
                  child: switch (_section) {
                    _Section.detalle => SummarySection(order: o),
                    _Section.equipos => EquipmentSection(order: o),
                    _Section.fotos => PhotosSection(order: o),
                    _Section.insumos => SuppliesSection(order: o),
                    _Section.cierre => CloseSection(order: o),
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 120)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final o = order;
    final pTone = o.priority.tone(c);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            StateChip(label: o.status.label, tone: o.status.tone(c)),
            Tag(label: o.type.label, marker: o.type.accent(c)),
            if (pTone != null) StateChip(label: o.priority.label, tone: pTone, icon: Icons.priority_high_rounded),
            if (o.contract != null) Tag(label: o.contract!.code, icon: Icons.verified_outlined),
          ],
        ),
        const SizedBox(height: Space.md),
        Text(o.client.name, style: context.tt.headlineSmall?.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(o.title, style: context.tt.bodyMedium?.copyWith(color: c.muted)),
        const SizedBox(height: Space.md),
        Row(
          children: [
            _QuickAction(
              icon: Icons.near_me_outlined,
              label: 'Cómo llegar',
              onTap: () => launchUrl(
                Uri.https('www.google.com', '/maps/dir/', {
                  'api': '1',
                  'destination': '${o.client.lat},${o.client.lng}',
                }),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(width: Space.sm),
            _QuickAction(
              icon: Icons.call_outlined,
              label: 'Llamar',
              onTap: () => launchUrl(Uri(scheme: 'tel', path: o.client.phone.replaceAll(' ', ''))),
            ),
            const SizedBox(width: Space.sm),
            _QuickAction(
              icon: Icons.sms_outlined,
              label: 'Mensaje',
              onTap: () => launchUrl(Uri(scheme: 'sms', path: o.client.phone.replaceAll(' ', ''))),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Expanded(
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.border.withValues(alpha: 0.8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: c.onSelection),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.tt.labelMedium?.copyWith(color: c.foreground, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panel del cronómetro: anillo de avance contra el tiempo estimado.
class _WorkPanel extends StatelessWidget {
  const _WorkPanel({required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final o = order;
    return LiveRebuild(
      active: o.isRunning,
      builder: (context) {
        final elapsed = o.totalElapsed;
        final ratio = elapsed.inSeconds / o.estimated.inSeconds;
        final over = ratio > 1;
        final ringColor = o.isClosed
            ? c.success
            : over
                ? c.danger
                : o.isRunning
                    ? c.warning
                    : c.input;
        final label = o.isClosed
            ? 'Tiempo total'
            : o.isRunning
                ? 'Trabajando'
                : o.status == OrderStatus.pausada
                    ? 'En pausa'
                    : 'Sin iniciar';

        return PrismaCard(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            children: [
              Row(
                children: [
                  ProgressRing(
                    value: ratio,
                    color: ringColor,
                    track: c.sunken,
                    size: 60,
                    stroke: 6,
                    child: o.isRunning
                        ? PulseDot(color: c.warning, size: 9)
                        : Icon(
                            o.isClosed
                                ? Icons.check_rounded
                                : o.status == OrderStatus.pausada
                                    ? Icons.pause_rounded
                                    : Icons.timer_outlined,
                            color: ringColor == c.input ? c.muted : ringColor,
                          ),
                  ),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label.toUpperCase(), style: context.tt.labelSmall),
                        const SizedBox(height: 2),
                        Text(
                          Fmt.duration(elapsed),
                          style: context.tt.displaySmall?.copyWith(
                            fontSize: 28,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          over
                              ? 'Excede lo estimado (${Fmt.durationShort(o.estimated)})'
                              : 'Estimado ${Fmt.durationShort(o.estimated)} · ${(ratio * 100).clamp(0, 100).round()} %',
                          style: context.tt.bodySmall?.copyWith(color: over ? c.dangerText : c.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.lg),
              Divider(height: 1, color: c.border.withValues(alpha: 0.7)),
              const SizedBox(height: Space.md),
              _Steps(order: o),
            ],
          ),
        );
      },
    );
  }
}

/// Pasos del trabajo, como el indicador de proceso del ERP.
class _Steps extends StatelessWidget {
  const _Steps({required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final o = order;
    final registered = (o.equipments.isEmpty || !o.hasContract || o.equipmentsReviewed == o.equipments.length) &&
        (o.checklist.isEmpty || o.checklistDone == o.checklist.length);
    final steps = [
      ('Llegada', o.status != OrderStatus.pendiente),
      ('Trabajo', o.totalElapsed > Duration.zero),
      ('Registro', registered && o.totalElapsed > Duration.zero),
      ('Firma', o.signature.isNotEmpty || (o.isClosed && o.signerName.isNotEmpty)),
      ('Cierre', o.isClosed),
    ];
    final current = steps.indexWhere((s) => !s.$2);

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: Motion.medium,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: steps[i].$2
                        ? c.successSoft
                        : i == current
                            ? c.primary
                            : c.surface,
                    border: Border.all(
                      color: steps[i].$2 || i == current ? Colors.transparent : c.border,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: steps[i].$2
                      ? Icon(Icons.check_rounded, size: 14, color: c.successText)
                      : Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: i == current ? c.onPrimary : c.faint)),
                ),
                const SizedBox(height: 6),
                Text(
                  steps[i].$1,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: i == current ? FontWeight.w600 : FontWeight.w500,
                    color: i == current ? c.foreground : (steps[i].$2 ? c.muted : c.faint),
                  ),
                ),
              ],
            ),
          ),
          if (i < steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: AnimatedContainer(
                duration: Motion.medium,
                width: 14,
                height: 2,
                color: steps[i].$2 ? c.successText : c.border,
              ),
            ),
        ],
      ],
    );
  }
}

/// Acción principal según el estado de la orden y la sección abierta.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.order, required this.section, required this.onClose, required this.onGoToClose});

  final WorkOrder order;
  final _Section section;
  final VoidCallback onClose;
  final VoidCallback onGoToClose;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final store = AppStore.instance;

    Widget secondary(String label, IconData icon, VoidCallback onTap) => Expanded(
          flex: 2,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
            onPressed: onTap,
            child: Text(label, maxLines: 1),
          ),
        );
    Widget primary(String label, IconData icon, VoidCallback? onTap, {Color? color, Color? fg}) => Expanded(
          flex: 3,
          child: FilledButton.icon(
            style: color == null ? null : FilledButton.styleFrom(backgroundColor: color, foregroundColor: fg),
            onPressed: onTap,
            icon: Icon(icon, size: 20),
            label: Text(label),
          ),
        );

    final List<Widget> buttons;
    if (section == _Section.cierre && o.totalElapsed > Duration.zero) {
      final ready = closeRequirements(o).every((r) => r.$2);
      buttons = [
        if (o.isRunning) secondary('Pausar', Icons.pause_rounded, () => store.pauseTimer(o)),
        if (o.isRunning) const SizedBox(width: Space.sm),
        primary(ready ? 'Cerrar orden' : 'Faltan pasos', Icons.task_alt_rounded, ready ? onClose : null),
      ];
    } else if (o.status == OrderStatus.pendiente) {
      buttons = [
        secondary('En camino', Icons.near_me_outlined, () {
          store.setOnTheWay(o);
          Haptics.tap();
          showToast(context, 'Se avisó a ${o.client.contact} que vas en camino', icon: Icons.near_me_rounded);
        }),
        const SizedBox(width: Space.sm),
        primary('Iniciar trabajo', Icons.play_arrow_rounded, () {
          Haptics.success();
          store.startTimer(o);
        }),
      ];
    } else if (o.isRunning) {
      buttons = [
        secondary('Pausar', Icons.pause_rounded, () {
          Haptics.tap();
          store.pauseTimer(o);
        }),
        const SizedBox(width: Space.sm),
        primary('Finalizar', Icons.flag_rounded, onGoToClose),
      ];
    } else {
      buttons = [
        if (o.totalElapsed > Duration.zero) ...[
          secondary('Finalizar', Icons.flag_outlined, onGoToClose),
          const SizedBox(width: Space.sm),
        ],
        primary(o.totalElapsed > Duration.zero ? 'Reanudar' : 'Iniciar trabajo', Icons.play_arrow_rounded, () {
          Haptics.success();
          store.startTimer(o);
        }),
      ];
    }

    return BottomActionBar(
      child: AnimatedSwitcher(
        duration: Motion.medium,
        child: Row(key: ValueKey('${o.status}-$section'), children: buttons),
      ),
    );
  }
}

class _PinnedTabs extends SliverPersistentHeaderDelegate {
  _PinnedTabs({required this.child, required this.color});

  final Widget child;
  final Color color;

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          color: color.withValues(alpha: overlapsContent ? 0.86 : 1),
          padding: const EdgeInsets.fromLTRB(Space.gutter, 10, Space.gutter, 10),
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_PinnedTabs old) => true;
}
