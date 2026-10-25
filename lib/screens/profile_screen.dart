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
                    footer: 'La apariencia sigue la configuración clara u oscura del teléfono.',
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
                        value: Theme.of(context).brightness == Brightness.dark ? 'Oscura' : 'Clara',
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
                      const GroupedTile(icon: Icons.info_outline_rounded, title: 'Versión', value: '0.2.0 · demo'),
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
