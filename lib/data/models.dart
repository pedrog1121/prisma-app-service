import 'dart:typed_data';

import 'package:flutter/material.dart';

enum OrderType { correctivo, preventivo, predictivo, instalacion }

extension OrderTypeX on OrderType {
  String get label => switch (this) {
        OrderType.correctivo => 'Correctivo',
        OrderType.preventivo => 'Preventivo',
        OrderType.predictivo => 'Predictivo',
        OrderType.instalacion => 'Instalación',
      };

  IconData get icon => switch (this) {
        OrderType.correctivo => Icons.build_rounded,
        OrderType.preventivo => Icons.event_repeat_rounded,
        OrderType.predictivo => Icons.insights_rounded,
        OrderType.instalacion => Icons.handyman_rounded,
      };
}

enum OrderStatus { pendiente, enCamino, enProceso, pausada, finalizada }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pendiente => 'Pendiente',
        OrderStatus.enCamino => 'En camino',
        OrderStatus.enProceso => 'En proceso',
        OrderStatus.pausada => 'Pausada',
        OrderStatus.finalizada => 'Finalizada',
      };

  Color get color => switch (this) {
        OrderStatus.pendiente => const Color(0xFF64748B),
        OrderStatus.enCamino => const Color(0xFF0EA5E9),
        OrderStatus.enProceso => const Color(0xFFF59E0B),
        OrderStatus.pausada => const Color(0xFFA855F7),
        OrderStatus.finalizada => const Color(0xFF16A34A),
      };
}

enum Priority { baja, media, alta, urgente }

extension PriorityX on Priority {
  String get label => switch (this) {
        Priority.baja => 'Baja',
        Priority.media => 'Media',
        Priority.alta => 'Alta',
        Priority.urgente => 'Urgente',
      };

  Color get color => switch (this) {
        Priority.baja => const Color(0xFF64748B),
        Priority.media => const Color(0xFF0EA5E9),
        Priority.alta => const Color(0xFFF97316),
        Priority.urgente => const Color(0xFFDC2626),
      };
}

class Technician {
  const Technician({
    required this.name,
    required this.code,
    required this.role,
    required this.phone,
    required this.lat,
    required this.lng,
  });

  final String name;
  final String code;
  final String role;
  final String phone;
  final double lat;
  final double lng;

  String get initials =>
      name.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
}

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.contact,
    required this.phone,
    required this.lat,
    required this.lng,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String contact;
  final String phone;
  final double lat;
  final double lng;
}

class Contract {
  const Contract({
    required this.code,
    required this.name,
    required this.slaHours,
    required this.validUntil,
    required this.frequency,
  });

  final String code;
  final String name;
  final int slaHours;
  final DateTime validUntil;
  final String frequency;
}

/// Variable que se mide en un equipo para el mantenimiento predictivo.
class MeasureDef {
  const MeasureDef({
    required this.key,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.history,
  });

  final String key;
  final String label;
  final String unit;
  final double min;
  final double max;

  /// Lecturas de visitas anteriores, de la más vieja a la más reciente.
  final List<double> history;

  bool isOutOfRange(double v) => v < min || v > max;
}

class Equipment {
  Equipment({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.serial,
    required this.location,
    required this.measures,
  });

  final String id;
  final String name;
  final String brand;
  final String model;
  final String serial;
  final String location;
  final List<MeasureDef> measures;

  /// Lecturas cargadas en la visita actual, por clave de medida.
  final Map<String, double> readings = {};
  String notes = '';
  bool reviewed = false;
}

class ChecklistItem {
  ChecklistItem(this.label, {this.done = false});

  final String label;
  bool done;
}

enum PhotoStage { antes, durante, despues }

extension PhotoStageX on PhotoStage {
  String get label => switch (this) {
        PhotoStage.antes => 'Antes',
        PhotoStage.durante => 'Durante',
        PhotoStage.despues => 'Después',
      };
}

class OrderPhoto {
  OrderPhoto({required this.stage, required this.caption, this.bytes, this.color});

  final PhotoStage stage;
  final String caption;

  /// Imagen real tomada con la cámara o la galería.
  final Uint8List? bytes;

  /// Color de la foto de ejemplo cuando no hay imagen real.
  final Color? color;
}

class Supply {
  const Supply({
    required this.code,
    required this.name,
    required this.unit,
    required this.stock,
    required this.price,
  });

  final String code;
  final String name;
  final String unit;
  final double stock;
  final int price;
}

class UsedSupply {
  UsedSupply(this.supply, this.qty);

  final Supply supply;
  double qty;
}

class WorkOrder {
  WorkOrder({
    required this.number,
    required this.client,
    required this.type,
    required this.priority,
    required this.scheduled,
    required this.estimated,
    required this.title,
    required this.description,
    this.contract,
    this.status = OrderStatus.pendiente,
    List<Equipment>? equipments,
    List<ChecklistItem>? checklist,
    List<OrderPhoto>? photos,
    List<UsedSupply>? supplies,
  })  : equipments = equipments ?? [],
        checklist = checklist ?? [],
        photos = photos ?? [],
        supplies = supplies ?? [];

  final String number;
  final Client client;
  final Contract? contract;
  final OrderType type;
  final Priority priority;
  final DateTime scheduled;
  final Duration estimated;
  final String title;
  final String description;
  OrderStatus status;

  final List<Equipment> equipments;
  final List<ChecklistItem> checklist;
  final List<OrderPhoto> photos;
  final List<UsedSupply> supplies;

  // Cronómetro
  Duration elapsed = Duration.zero;
  DateTime? runningSince;

  // Cierre
  String diagnosis = '';
  String signerName = '';
  List<List<Offset>> signature = [];
  DateTime? closedAt;

  bool get hasContract => contract != null;
  bool get isRunning => runningSince != null;
  bool get isClosed => status == OrderStatus.finalizada;

  Duration get totalElapsed =>
      elapsed + (runningSince == null ? Duration.zero : DateTime.now().difference(runningSince!));

  int get suppliesTotal =>
      supplies.fold(0, (sum, s) => sum + (s.supply.price * s.qty).round());

  int get checklistDone => checklist.where((c) => c.done).length;
  int get equipmentsReviewed => equipments.where((e) => e.reviewed).length;
}
