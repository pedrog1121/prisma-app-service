import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../design/adaptive.dart';
import '../design/components.dart';
import '../design/format.dart';
import '../design/tokens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _offline = true;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final t = store.technician;
    final c = context.pc;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final closed = store.orders.where((o) => o.isClosed).toList();
        final hours = closed.fold(Duration.zero, (a, o) => a + o.totalElapsed);

        return PrismaPage(
          title: 'Perfil',
          slivers: [
            Gutter(
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(
                  child: PrismaCard(
                    padding: const EdgeInsets.all(Space.xl),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: PrismaColors.brandGradient),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: c.surface,
                            child: Text(t.initials, style: context.tt.headlineSmall?.copyWith(color: c.onSelection)),
                          ),
                        ),
                        const SizedBox(height: Space.md),
                        Text(t.name, style: context.tt.titleLarge),
                        const SizedBox(height: 2),
                        Text(t.role, textAlign: TextAlign.center, style: context.tt.bodySmall),
                        const SizedBox(height: Space.lg),
                        Divider(color: c.border),
                        const SizedBox(height: Space.md),
                        Row(
                          children: [
                            _Stat(value: '${closed.length}', label: 'Cerradas'),
                            _Stat(value: Fmt.durationShort(hours), label: 'Registradas'),
                            _Stat(value: '${store.orders.length}', label: 'Asignadas'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Gutter(
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(
                  index: 1,
                  child: GroupedSection(
                    title: 'Cuenta',
                    children: [
                      GroupedTile(icon: Icons.badge_outlined, title: 'Legajo', value: t.code),
                      GroupedTile(icon: Icons.phone_outlined, title: 'Teléfono', value: t.phone),
                      GroupedTile(
                        icon: Icons.local_shipping_outlined,
                        title: 'Stock de la camioneta',
                        onTap: () => showToast(context, 'Disponible cuando se conecte con el ERP',
                            icon: Icons.info_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Gutter(
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(
                  index: 2,
                  child: GroupedSection(
                    title: 'Preferencias',
                    footer: 'Con «Sistema», la app usa la apariencia clara u oscura configurada en el teléfono.',
                    children: [
                      GroupedTile(
                        icon: Icons.notifications_outlined,
                        title: 'Avisos de órdenes nuevas',
                        trailing: Switch.adaptive(
                          value: _notifications,
                          onChanged: (v) => setState(() => _notifications = v),
                        ),
                      ),
                      GroupedTile(
                        icon: Icons.cloud_off_outlined,
                        title: 'Trabajar sin conexión',
                        trailing: Switch.adaptive(
                          value: _offline,
                          onChanged: (v) => setState(() => _offline = v),
                        ),
                      ),
                      GroupedTile(
                        icon: Icons.contrast_rounded,
                        title: 'Apariencia',
                        value: _themeLabel(store.themeMode),
                        onTap: () => showPrismaSheet<void>(context, builder: (_) => const _AppearanceSheet()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Gutter(
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(
                  index: 3,
                  child: GroupedSection(
                    title: 'Sincronización',
                    children: [
                      GroupedTile(
                        icon: Icons.sync_rounded,
                        iconColor: c.successText,
                        title: 'Última sincronización',
                        value: 'Hace un momento',
                      ),
                      const GroupedTile(icon: Icons.info_outline_rounded, title: 'Versión', value: '0.3.0 · demo'),
                    ],
                  ),
                ),
              ),
            ),
            Gutter(
              top: Space.xxl,
              sliver: SliverToBoxAdapter(
                child: GroupedSection(
                  children: [
                    GroupedTile(
                      icon: Icons.logout_rounded,
                      title: 'Cerrar sesión',
                      destructive: true,
                      onTap: () async {
                        final ok = await confirmAction(
                          context,
                          title: '¿Cerrar sesión?',
                          message: 'Las órdenes sin sincronizar quedan guardadas en este teléfono.',
                          confirmLabel: 'Cerrar sesión',
                          destructive: true,
                        );
                        if (ok) store.logout();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + Space.xxl)),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: context.tt.titleMedium),
          const SizedBox(height: 2),
          Text(label, style: context.tt.bodySmall),
        ],
      ),
    );
  }
}

String _themeLabel(ThemeMode m) => switch (m) {
      ThemeMode.system => 'Sistema',
      ThemeMode.light => 'Clara',
      ThemeMode.dark => 'Oscura',
    };

/// Selector de apariencia con vista previa de cada opción.
class _AppearanceSheet extends StatelessWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apariencia', style: context.tt.titleLarge),
              const SizedBox(height: 2),
              Text('Se aplica al instante y queda guardada en este teléfono.', style: context.tt.bodySmall),
              const SizedBox(height: Space.xl),
              Row(
                children: [
                  for (final m in [ThemeMode.system, ThemeMode.light, ThemeMode.dark]) ...[
                    Expanded(
                      child: _ThemeOption(
                        mode: m,
                        selected: store.themeMode == m,
                        onTap: () {
                          Haptics.tap();
                          store.setThemeMode(m);
                        },
                      ),
                    ),
                    if (m != ThemeMode.dark) const SizedBox(width: Space.md),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.mode, required this.selected, required this.onTap});

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Pressable(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: Motion.medium,
            height: 132,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.lg + 3),
              border: Border.all(color: selected ? c.primary : c.border, width: selected ? 2.5 : 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.lg),
              child: switch (mode) {
                ThemeMode.light => const _MiniScreen(colors: PrismaColors.light),
                ThemeMode.dark => const _MiniScreen(colors: PrismaColors.dark),
                ThemeMode.system => const Row(
                    children: [
                      Expanded(child: _MiniScreen(colors: PrismaColors.light, clipRight: true)),
                      Expanded(child: _MiniScreen(colors: PrismaColors.dark, clipLeft: true)),
                    ],
                  ),
              },
            ),
          ),
          const SizedBox(height: Space.sm),
          Text(
            _themeLabel(mode),
            style: context.tt.labelLarge?.copyWith(color: selected ? c.foreground : c.muted),
          ),
          const SizedBox(height: 4),
          AnimatedScale(
            scale: selected ? 1 : 0,
            duration: Motion.medium,
            curve: Curves.easeOutBack,
            child: Icon(Icons.check_circle_rounded, size: 20, color: c.primary),
          ),
        ],
      ),
    );
  }
}

/// Miniatura de la app con una paleta, para el selector de apariencia.
class _MiniScreen extends StatelessWidget {
  const _MiniScreen({required this.colors, this.clipLeft = false, this.clipRight = false});

  final PrismaColors colors;
  final bool clipLeft;
  final bool clipRight;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    Widget bar(double w, Color color, [double h = 6]) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        );
    return Container(
      color: c.background,
      padding: const EdgeInsets.all(10),
      child: OverflowBox(
        alignment: clipLeft ? Alignment.topRight : Alignment.topLeft,
        maxWidth: 90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(34, c.foreground, 8),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(50, c.muted, 5),
                  const SizedBox(height: 5),
                  bar(36, c.faint, 4),
                  const SizedBox(height: 6),
                  bar(70, c.primary, 10),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 22,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: c.border),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
