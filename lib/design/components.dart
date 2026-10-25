import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive.dart';
import 'order_styles.dart';
import 'tokens.dart';

// ---------------------------------------------------------------------------
// Estructura de página
// ---------------------------------------------------------------------------

/// Página con título grande: barra de navegación de iOS o SliverAppBar.large en Android.
class PrismaPage extends StatelessWidget {
  const PrismaPage({
    super.key,
    required this.title,
    required this.slivers,
    this.trailing,
    this.bottomBar,
    this.previousTitle,
    this.controller,
    this.compact = false,
  });

  final String title;
  final List<Widget> slivers;
  final Widget? trailing;
  final Widget? bottomBar;
  final String? previousTitle;
  final ScrollController? controller;

  /// Barra de título compacta (pantallas de detalle).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final ios = isCupertino(context);
    final header = compact
        ? SliverAppBar(
            pinned: true,
            centerTitle: ios,
            title: Text(title, style: context.tt.titleMedium),
            backgroundColor: c.background.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: Navigator.of(context).canPop()
                ? (ios
                    ? CupertinoNavigationBarBackButton(previousPageTitle: previousTitle, color: c.primary)
                    : const BackButton())
                : null,
            leadingWidth: ios ? 110 : null,
            actions: [if (trailing != null) trailing!, const SizedBox(width: Space.sm)],
            flexibleSpace: ClipRect(
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), child: const SizedBox.expand()),
            ),
          )
        : ios
            ? CupertinoSliverNavigationBar(
                largeTitle: Text(title),
                previousPageTitle: previousTitle,
                trailing: trailing,
                backgroundColor: c.background.withValues(alpha: 0.84),
                border: Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.6), width: 0.5)),
                stretch: true,
              )
            : SliverAppBar.large(
                title: Text(title, style: context.tt.headlineMedium),
                backgroundColor: c.background,
                surfaceTintColor: Colors.transparent,
                actions: [if (trailing != null) trailing!, const SizedBox(width: Space.sm)],
              );

    return Scaffold(
      backgroundColor: c.background,
      extendBody: true,
      body: CustomScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [header, ...slivers],
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}

/// Barra inferior fija con desenfoque, para la acción principal de la pantalla.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(Space.gutter, Space.md, Space.gutter, math.max(bottom, Space.md)),
          decoration: BoxDecoration(
            color: c.frame.withValues(alpha: 0.86),
            border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.8), width: 0.5)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Padding lateral estándar para slivers de contenido.
class Gutter extends StatelessWidget {
  const Gutter({super.key, required this.sliver, this.top = 0, this.bottom = 0});

  final Widget sliver;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: EdgeInsets.fromLTRB(Space.gutter, top, Space.gutter, bottom),
        sliver: sliver,
      );
}

// ---------------------------------------------------------------------------
// Superficies y texto
// ---------------------------------------------------------------------------

/// Tarjeta de nivel 1 (superficie blanca con sombra corta).
class PrismaCard extends StatelessWidget {
  const PrismaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.lg),
    this.onTap,
    this.color,
    this.borderColor,
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  /// Marcador de 3 px a la izquierda (acento de módulo o prioridad).
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    Widget content = Padding(padding: padding, child: child);
    if (accent != null) {
      content = Stack(
        children: [
          content,
          Positioned(
            left: 0,
            top: Space.lg,
            bottom: Space.lg,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
              ),
            ),
          ),
        ],
      );
    }
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor ?? c.border.withValues(alpha: 0.7)),
        boxShadow: c.cardShadow,
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(Radii.lg), child: content),
    );
    return onTap == null ? box : Pressable(onTap: onTap!, child: box);
  }
}

/// Encabezado de sección: etiqueta en mayúsculas con espaciado, como en el ERP.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing, this.padding});

  final String text;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(4, Space.xxl, 4, Space.sm),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: context.tt.labelSmall)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Chip de estado con punto, siguiendo los tonos de la guía.
class StateChip extends StatelessWidget {
  const StateChip({super.key, required this.label, required this.tone, this.icon});

  final String label;
  final StateTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return AnimatedContainer(
      duration: Motion.medium,
      curve: Motion.enter,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(Radii.pill),
        border: tone.dashed ? Border.all(color: c.strongBorder.withValues(alpha: 0.6)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 13, color: tone.fg)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tone.fg, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tone.fg, height: 1.1)),
        ],
      ),
    );
  }
}

/// Etiqueta neutra con marcador de color (tipo de trabajo, contrato).
class Tag extends StatelessWidget {
  const Tag({super.key, required this.label, this.marker, this.icon});

  final String label;
  final Color? marker;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.sunken,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (marker != null) ...[
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(color: marker, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 13, color: c.muted),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.muted, height: 1.1)),
        ],
      ),
    );
  }
}

/// Ícono dentro de un cuadrado suave.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.size = 40, this.background});

  final IconData icon;
  final Color color;
  final double size;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message});

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.xxxl, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(icon: icon, color: c.onSelection, background: c.selection, size: 64),
            const SizedBox(height: Space.lg),
            Text(title, textAlign: TextAlign.center, style: context.tt.titleMedium),
            if (message != null) ...[
              const SizedBox(height: Space.xs),
              Text(message!, textAlign: TextAlign.center, style: context.tt.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lista agrupada (estilo ajustes de iOS)
// ---------------------------------------------------------------------------

class GroupedSection extends StatelessWidget {
  const GroupedSection({super.key, required this.children, this.title, this.footer});

  final List<Widget> children;
  final String? title;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(Padding(
          padding: const EdgeInsets.only(left: 56),
          child: Divider(height: 0.5, thickness: 0.5, color: c.border),
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) SectionLabel(title!),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(color: c.border.withValues(alpha: 0.7)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.lg),
            child: Column(children: items),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, Space.sm, 4, 0),
            child: Text(footer!, style: context.tt.bodySmall),
          ),
      ],
    );
  }
}

class GroupedTile extends StatelessWidget {
  const GroupedTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.subtitle,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final color = destructive ? c.dangerText : (iconColor ?? c.onSelection);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 12),
        child: Row(
          children: [
            IconBadge(icon: icon, color: color, size: 28),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: context.tt.bodyLarge?.copyWith(
                          color: destructive ? c.dangerText : c.foreground,
                          fontWeight: destructive ? FontWeight.w600 : FontWeight.w400)),
                  if (subtitle != null) Text(subtitle!, style: context.tt.bodySmall),
                ],
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(left: Space.sm),
                child: Text(value!, style: context.tt.bodyMedium?.copyWith(color: c.muted)),
              ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null && !destructive)
              Icon(Icons.chevron_right_rounded, color: c.faint, size: 22),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Controles
// ---------------------------------------------------------------------------

/// Control segmentado de Prisma: contenedor hundido y pastilla deslizante.
class PillTabs extends StatelessWidget {
  const PillTabs({super.key, required this.labels, required this.selected, required this.onChanged, this.badges});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final List<String?>? badges;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.sunken,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth / labels.length;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: Motion.medium,
              curve: Motion.emphasized,
              left: w * selected,
              top: 0,
              bottom: 0,
              width: w,
              child: Container(
                decoration: BoxDecoration(
                  color: c.elevated,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: c.cardShadow,
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (i != selected) {
                          Haptics.tap();
                          onChanged(i);
                        }
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: Motion.fast,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            fontWeight: i == selected ? FontWeight.w600 : FontWeight.w500,
                            color: i == selected ? c.foreground : c.muted,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                  child: Text(labels[i], maxLines: 1, overflow: TextOverflow.fade, softWrap: false)),
                              if (badges?[i] != null) ...[
                                const SizedBox(width: 4),
                                Text(badges![i]!,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.faint)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

/// Chip de filtro: usa el tono de selección, no el primario.
class FilterPill extends StatelessWidget {
  const FilterPill({super.key, required this.label, required this.selected, required this.onTap, this.count});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Pressable(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.selection : c.surface,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: selected ? c.onSelection.withValues(alpha: 0.25) : c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? c.onSelection : c.muted)),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text('$count',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? c.onSelection.withValues(alpha: 0.7) : c.faint)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Campo de búsqueda nativo de cada plataforma.
class PrismaSearchField extends StatelessWidget {
  const PrismaSearchField({super.key, required this.onChanged, required this.placeholder});

  final ValueChanged<String> onChanged;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    if (isCupertino(context)) {
      return CupertinoSearchTextField(
        onChanged: onChanged,
        placeholder: placeholder,
        backgroundColor: c.sunken.withValues(alpha: 1),
        style: TextStyle(fontFamily: 'Inter', color: c.foreground, fontSize: 16),
        placeholderStyle: TextStyle(fontFamily: 'Inter', color: c.faint, fontSize: 16),
        borderRadius: BorderRadius.circular(Radii.md),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      );
    }
    return SearchBar(
      onChanged: onChanged,
      hintText: placeholder,
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(c.surface),
      side: WidgetStatePropertyAll(BorderSide(color: c.border)),
      leading: Icon(Icons.search_rounded, color: c.muted),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
    );
  }
}

// ---------------------------------------------------------------------------
// Animación
// ---------------------------------------------------------------------------

/// Escala sutil al presionar, con respuesta háptica opcional.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, required this.onTap, this.scale = 0.97});

  final Widget child;
  final VoidCallback onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: _down ? const Duration(milliseconds: 90) : Motion.medium,
        curve: _down ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// Entrada con fundido y desplazamiento, escalonada por [index].
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0, this.offset = 18});

  final Widget child;
  final int index;
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: Motion.slow);
  Timer? _delay;

  @override
  void initState() {
    super.initState();
    final reduce = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduce) {
      _ctrl.value = 1;
    } else {
      _delay = Timer(Duration(milliseconds: 45 * widget.index.clamp(0, 10)), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _ctrl, curve: Motion.enter);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(offset: Offset(0, widget.offset * (1 - curved.value)), child: child),
      ),
      child: widget.child,
    );
  }
}

/// Número que cuenta hasta su valor.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({super.key, required this.value, required this.style});

  final int value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: Motion.slow,
      curve: Motion.enter,
      builder: (_, v, __) => Text('${v.round()}', style: style),
    );
  }
}

/// Anillo de progreso animado.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    required this.track,
    this.size = 64,
    this.stroke = 6,
    this.child,
  });

  final double value;
  final Color color;
  final Color track;
  final double size;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 700),
      curve: Motion.emphasized,
      builder: (_, v, child) => CustomPaint(
        painter: _RingPainter(v, color, track, stroke),
        child: SizedBox(width: size, height: size, child: Center(child: child)),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.track, this.stroke);

  final double value;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    canvas.drawArc(
        r,
        0,
        math.pi * 2,
        false,
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);
    if (value <= 0) return;
    canvas.drawArc(
        r,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color || old.track != track;
}

/// Punto que late (trabajo en curso, en línea).
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.6,
      height: widget.size * 2.6,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size * (1 + 1.6 * _ctrl.value),
              height: widget.size * (1 + 1.6 * _ctrl.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.35 * (1 - _ctrl.value)),
              ),
            ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reconstruye su contenido cada segundo mientras [active] sea true.
class LiveRebuild extends StatefulWidget {
  const LiveRebuild({super.key, required this.active, required this.builder});

  final bool active;
  final WidgetBuilder builder;

  @override
  State<LiveRebuild> createState() => _LiveRebuildState();
}

class _LiveRebuildState extends State<LiveRebuild> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(LiveRebuild old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.active && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    } else if (!widget.active) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
