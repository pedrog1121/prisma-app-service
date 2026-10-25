import 'package:flutter/material.dart';

import '../data/models.dart';
import 'tokens.dart';

/// Colores de un estado: texto, fondo suave y si el chip va punteado.
class StateTone {
  const StateTone(this.fg, this.bg, {this.dashed = false});

  final Color fg;
  final Color bg;
  final bool dashed;
}

/// El ciclo de la orden sigue la guía de Prisma: neutro mientras no empezó,
/// azul en tránsito, ámbar mientras se trabaja, apagado en pausa y verde al cerrar.
extension OrderStatusTone on OrderStatus {
  StateTone tone(PrismaColors c) => switch (this) {
        OrderStatus.pendiente => StateTone(c.muted, Colors.transparent, dashed: true),
        OrderStatus.enCamino => StateTone(c.infoText, c.infoSoft),
        OrderStatus.enProceso => StateTone(c.warningText, c.warningSoft),
        OrderStatus.pausada => StateTone(c.closedText, c.closedSoft),
        OrderStatus.finalizada => StateTone(c.successText, c.successSoft),
      };
}

extension PriorityTone on Priority {
  StateTone? tone(PrismaColors c) => switch (this) {
        Priority.urgente => StateTone(c.dangerText, c.dangerSoft),
        Priority.alta => StateTone(c.warningText, c.warningSoft),
        _ => null,
      };
}

/// Acento por tipo de trabajo: solo para marcadores e íconos.
extension OrderTypeAccent on OrderType {
  Color accent(PrismaColors c) => switch (this) {
        OrderType.preventivo => c.modTeal,
        OrderType.correctivo => c.modAmber,
        OrderType.predictivo => c.modBlue,
        OrderType.instalacion => c.modViolet,
      };
}

/// Tonos sueltos para chips que no dependen de la orden.
class StateToneX {
  static StateTone neutral(PrismaColors c) => StateTone(c.muted, c.sunken);
  static StateTone success(PrismaColors c) => StateTone(c.successText, c.successSoft);
  static StateTone warning(PrismaColors c) => StateTone(c.warningText, c.warningSoft);
  static StateTone danger(PrismaColors c) => StateTone(c.dangerText, c.dangerSoft);
  static StateTone info(PrismaColors c) => StateTone(c.infoText, c.infoSoft);
}
