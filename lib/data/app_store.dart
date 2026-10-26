import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_data.dart';
import 'models.dart';

/// Estado en memoria de la app. Reemplazar por el repositorio del ERP
/// cuando exista la API para técnicos.
class AppStore extends ChangeNotifier {
  AppStore._();

  static final AppStore instance = AppStore._();

  final Technician technician = MockData.technician;
  final List<WorkOrder> orders = MockData.buildOrders();
  bool loggedIn = false;

  /// Apariencia elegida en Perfil. Se guarda en el teléfono.
  ThemeMode themeMode = ThemeMode.system;
  static const _themeKey = 'prisma.themeMode';

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_themeKey);
      themeMode = ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
    } catch (_) {
      // Sin almacenamiento (por ejemplo, navegación privada): se usa el tema del sistema.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.name);
    } catch (_) {}
  }

  void login() {
    loggedIn = true;
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    notifyListeners();
  }

  List<WorkOrder> ordersOn(DateTime day) {
    final list = orders
        .where((o) => o.scheduled.year == day.year && o.scheduled.month == day.month && o.scheduled.day == day.day)
        .toList()
      ..sort((a, b) => a.scheduled.compareTo(b.scheduled));
    return list;
  }

  /// Órdenes de hoy que todavía hay que visitar, en orden de horario.
  List<WorkOrder> get todayRoute => ordersOn(DateTime.now()).where((o) => !o.isClosed).toList();

  void setOnTheWay(WorkOrder o) {
    if (o.status == OrderStatus.pendiente) o.status = OrderStatus.enCamino;
    notifyListeners();
  }

  void startTimer(WorkOrder o) {
    if (o.isRunning || o.isClosed) return;
    o.runningSince = DateTime.now();
    o.status = OrderStatus.enProceso;
    notifyListeners();
  }

  void pauseTimer(WorkOrder o) {
    if (!o.isRunning) return;
    o.elapsed += DateTime.now().difference(o.runningSince!);
    o.runningSince = null;
    o.status = OrderStatus.pausada;
    notifyListeners();
  }

  void closeOrder(WorkOrder o) {
    if (o.isRunning) {
      o.elapsed += DateTime.now().difference(o.runningSince!);
      o.runningSince = null;
    }
    o.status = OrderStatus.finalizada;
    o.closedAt = DateTime.now();
    notifyListeners();
  }

  void touch() => notifyListeners();
}
