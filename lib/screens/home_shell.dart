import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design/adaptive.dart';
import '../design/tokens.dart';
import 'agenda_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'route_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  /// Cuenta las visitas a Ruta y Perfil para reconstruirlas y repetir sus animaciones de entrada.
  int _visits = 0;

  static const _items = [
    (Icons.calendar_today_outlined, Icons.calendar_today_rounded, CupertinoIcons.calendar, 'Agenda'),
    (Icons.assignment_outlined, Icons.assignment_rounded, CupertinoIcons.doc_text, 'Órdenes'),
    (Icons.route_outlined, Icons.route_rounded, CupertinoIcons.map, 'Ruta'),
    (Icons.person_outline_rounded, Icons.person_rounded, CupertinoIcons.person_crop_circle, 'Perfil'),
  ];

  void _select(int i) {
    if (i == _index) return;
    Haptics.tap();
    setState(() {
      _index = i;
      _visits++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final ios = isCupertino(context);
    final pages = [
      const AgendaScreen(),
      const OrdersScreen(),
      RouteScreen(key: ValueKey('route-$_visits')),
      ProfileScreen(key: ValueKey('profile-$_visits')),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          for (var i = 0; i < pages.length; i++)
            IgnorePointer(
              ignoring: i != _index,
              child: AnimatedOpacity(
                opacity: i == _index ? 1 : 0,
                duration: Motion.medium,
                curve: Motion.enter,
                child: TickerMode(enabled: i == _index, child: pages[i]),
              ),
            ),
        ],
      ),
      bottomNavigationBar: ios
          ? CupertinoTabBar(
              currentIndex: _index,
              onTap: _select,
              activeColor: c.primary,
              inactiveColor: c.faint,
              backgroundColor: c.frame.withValues(alpha: 0.82),
              border: Border(top: BorderSide(color: c.border, width: 0.5)),
              iconSize: 26,
              height: 54,
              items: [
                for (final it in _items) BottomNavigationBarItem(icon: Icon(it.$3), label: it.$4),
              ],
            )
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                for (final it in _items)
                  NavigationDestination(icon: Icon(it.$1), selectedIcon: Icon(it.$2), label: it.$4),
              ],
            ),
    );
  }
}
