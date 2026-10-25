import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'order_tabs/close_tab.dart';
import 'order_tabs/equipment_tab.dart';
import 'order_tabs/photos_tab.dart';
import 'order_tabs/summary_tab.dart';
import 'order_tabs/supplies_tab.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    // La carga de equipos para predictivo solo aplica a órdenes de contrato.
    final showEquipment = o.hasContract && o.equipments.isNotEmpty;
    final tabs = <(String, IconData, Widget)>[
      ('Detalle', Icons.info_outline_rounded, SummaryTab(order: o)),
      if (showEquipment) ('Equipos', Icons.precision_manufacturing_outlined, EquipmentTab(order: o)),
      ('Fotos', Icons.photo_camera_outlined, PhotosTab(order: o)),
      ('Insumos', Icons.inventory_2_outlined, SuppliesTab(order: o)),
      ('Cierre', Icons.draw_outlined, CloseTab(order: o)),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(o.number),
          actions: [
            IconButton(
              tooltip: 'Llamar al cliente',
              icon: const Icon(Icons.call_rounded),
              onPressed: () => launchUrl(Uri(scheme: 'tel', path: o.client.phone.replaceAll(' ', ''))),
            ),
            IconButton(
              tooltip: 'Cómo llegar',
              icon: const Icon(Icons.directions_rounded),
              onPressed: () => launchUrl(
                Uri.https('www.google.com', '/maps/dir/', {
                  'api': '1',
                  'destination': '${o.client.lat},${o.client.lng}',
                }),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: ListenableBuilder(
          listenable: AppStore.instance,
          builder: (context, _) => NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(child: _Header(order: o)),
              SliverToBoxAdapter(child: _TimerCard(order: o)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                    tabs: [
                      for (final t in tabs) Tab(icon: Icon(t.$2, size: 20), text: t.$1, height: 58),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(children: [for (final t in tabs) t.$3]),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusPill(o.status),
              Pill(label: o.type.label, color: AppColors.text, icon: o.type.icon),
              Pill(label: 'Prioridad ${o.priority.label.toLowerCase()}', color: o.priority.color),
              if (o.contract != null) ContractPill(o.contract!),
            ],
          ),
          const SizedBox(height: 10),
          Text(o.client.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(o.title, style: const TextStyle(color: AppColors.muted, fontSize: 14.5)),
        ],
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final store = AppStore.instance;
    final over = o.totalElapsed > o.estimated;
    final onDark = o.isRunning;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: onDark ? const Color(0xFF1E1B4B) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: onDark ? Colors.transparent : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.isClosed
                          ? 'Tiempo total trabajado'
                          : o.isRunning
                              ? 'Trabajo en curso'
                              : 'Cronómetro de trabajo',
                      style: TextStyle(
                          fontSize: 12.5, color: onDark ? Colors.white70 : AppColors.muted),
                    ),
                    const SizedBox(height: 2),
                    Ticker(
                      active: o.isRunning,
                      builder: (_) => Text(
                        Fmt.duration(o.totalElapsed),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: onDark
                              ? Colors.white
                              : (over && o.isClosed ? AppColors.warning : AppColors.text),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: o.isClosed
                    ? const Pill(
                        label: 'Cerrada',
                        color: AppColors.success,
                        icon: Icons.check_rounded,
                        filled: true)
                    : Text('Estimado ${Fmt.durationShort(o.estimated)}',
                        style: TextStyle(
                            fontSize: 12.5, color: onDark ? Colors.white60 : AppColors.muted)),
              ),
            ],
          ),
          if (!o.isClosed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (o.status == OrderStatus.pendiente) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        store.setOnTheWay(o);
                        showToast(context, 'Se avisó al cliente que vas en camino',
                            icon: Icons.near_me_rounded);
                      },
                      icon: const Icon(Icons.near_me_rounded, size: 18),
                      label: const Text('En camino'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: o.isRunning
                      ? FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
                          onPressed: () => store.pauseTimer(o),
                          icon: const Icon(Icons.pause_rounded),
                          label: const Text('Pausar'),
                        )
                      : FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                          onPressed: () => store.startTimer(o),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(o.elapsed == Duration.zero ? 'Iniciar trabajo' : 'Reanudar'),
                        ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
}
