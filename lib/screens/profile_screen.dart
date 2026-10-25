import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final t = store.technician;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final closed = store.orders.where((o) => o.isClosed).toList();
          final hours = closed.fold(Duration.zero, (a, o) => a + o.totalElapsed);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary,
                        child: Text(t.initials,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name,
                                style:
                                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(t.role,
                                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                            const SizedBox(height: 6),
                            Pill(label: t.code, color: AppColors.primary, icon: Icons.badge_rounded),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Kpi(value: '${closed.length}', label: 'Órdenes cerradas'),
                  const SizedBox(width: 8),
                  _Kpi(value: Fmt.durationShort(hours), label: 'Horas registradas'),
                  const SizedBox(width: 8),
                  _Kpi(value: '${store.orders.length}', label: 'Asignadas'),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.phone_rounded),
                      title: const Text('Teléfono'),
                      subtitle: Text(t.phone),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.cloud_done_rounded, color: AppColors.success),
                      title: Text('Sincronización'),
                      subtitle: Text('Modo demostración: los datos son de prueba'),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.info_outline_rounded),
                      title: Text('Versión'),
                      subtitle: Text('Prisma App Service 0.1.0 (prototipo)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: store.logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
