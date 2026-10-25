import 'package:flutter/material.dart';

import 'models.dart';

/// Datos de prueba para previsualizar la app sin conexión al ERP.
class MockData {
  static const technician = Technician(
    name: 'Carlos Benítez',
    code: 'TEC-014',
    role: 'Técnico de refrigeración y climatización',
    phone: '+595 981 123 456',
    lat: -25.2867,
    lng: -57.6470,
  );

  static const clients = [
    Client(
      id: 'C-1021',
      name: 'Supermercado La Esperanza',
      address: 'Av. Mcal. López 3450',
      city: 'Asunción',
      contact: 'Laura Giménez',
      phone: '+595 21 600 120',
      lat: -25.2935,
      lng: -57.6040,
    ),
    Client(
      id: 'C-0877',
      name: 'Clínica Santa Lucía',
      address: 'Av. España 1820',
      city: 'Asunción',
      contact: 'Dr. Martín Ortiz',
      phone: '+595 21 223 400',
      lat: -25.2860,
      lng: -57.6185,
    ),
    Client(
      id: 'C-1150',
      name: 'Hotel Los Lapachos',
      address: 'Av. Santa Teresa 2215',
      city: 'Asunción',
      contact: 'Rocío Duarte',
      phone: '+595 21 615 900',
      lat: -25.2750,
      lng: -57.5810,
    ),
    Client(
      id: 'C-0412',
      name: 'Panadería Don Ramón',
      address: 'Calle Cerro Corá 845',
      city: 'Asunción',
      contact: 'Ramón Acosta',
      phone: '+595 982 445 210',
      lat: -25.2905,
      lng: -57.6330,
    ),
    Client(
      id: 'C-1302',
      name: 'Frigorífico del Este',
      address: 'Ruta PY02 km 12',
      city: 'San Lorenzo',
      contact: 'Ing. Pablo Ferreira',
      phone: '+595 21 585 300',
      lat: -25.3400,
      lng: -57.5090,
    ),
    Client(
      id: 'C-0990',
      name: 'Oficinas Grupo Andes',
      address: 'Av. Aviadores del Chaco 2050',
      city: 'Asunción',
      contact: 'Sofía Rojas',
      phone: '+595 21 612 777',
      lat: -25.2700,
      lng: -57.5650,
    ),
  ];

  static final contracts = {
    'super': Contract(
      code: 'CT-2026-018',
      name: 'Mantenimiento integral de frío',
      slaHours: 4,
      validUntil: DateTime(2027, 3, 31),
      frequency: 'Mensual',
    ),
    'clinica': Contract(
      code: 'CT-2026-007',
      name: 'Climatización y equipos críticos',
      slaHours: 2,
      validUntil: DateTime(2026, 12, 31),
      frequency: 'Quincenal',
    ),
    'frigo': Contract(
      code: 'CT-2025-044',
      name: 'Plan predictivo de compresores',
      slaHours: 6,
      validUntil: DateTime(2027, 6, 30),
      frequency: 'Mensual',
    ),
    'hotel': Contract(
      code: 'CT-2026-021',
      name: 'Mantenimiento de chillers y fan coils',
      slaHours: 8,
      validUntil: DateTime(2027, 1, 31),
      frequency: 'Bimestral',
    ),
  };

  static const supplies = [
    Supply(code: 'INS-001', name: 'Gas refrigerante R-410A', unit: 'kg', stock: 18, price: 95000),
    Supply(code: 'INS-002', name: 'Gas refrigerante R-404A', unit: 'kg', stock: 9, price: 120000),
    Supply(code: 'INS-010', name: 'Filtro deshidratador 3/8"', unit: 'un', stock: 12, price: 65000),
    Supply(code: 'INS-014', name: 'Capacitor de marcha 45 µF', unit: 'un', stock: 20, price: 48000),
    Supply(code: 'INS-022', name: 'Contactor 220 V 32 A', unit: 'un', stock: 6, price: 185000),
    Supply(code: 'INS-031', name: 'Aceite POE para compresor', unit: 'lt', stock: 15, price: 140000),
    Supply(code: 'INS-040', name: 'Limpiador de serpentín', unit: 'lt', stock: 24, price: 52000),
    Supply(code: 'INS-047', name: 'Cinta aislante térmica', unit: 'un', stock: 40, price: 18000),
    Supply(code: 'INS-055', name: 'Correa en V tipo A-42', unit: 'un', stock: 8, price: 75000),
    Supply(code: 'INS-063', name: 'Filtro de aire 24x24"', unit: 'un', stock: 30, price: 38000),
  ];

  static MeasureDef _temp(List<double> h) => MeasureDef(
      key: 'temp', label: 'Temperatura de descarga', unit: '°C', min: 60, max: 95, history: h);
  static MeasureDef _vib(List<double> h) =>
      MeasureDef(key: 'vib', label: 'Vibración', unit: 'mm/s', min: 0, max: 4.5, history: h);
  static MeasureDef _amp(List<double> h, double max) =>
      MeasureDef(key: 'amp', label: 'Consumo', unit: 'A', min: 0, max: max, history: h);
  static MeasureDef _pres(List<double> h) =>
      MeasureDef(key: 'pres', label: 'Presión de succión', unit: 'psi', min: 55, max: 80, history: h);
  static MeasureDef _hours(List<double> h) =>
      MeasureDef(key: 'hrs', label: 'Horas de uso', unit: 'h', min: 0, max: 99999, history: h);

  static List<ChecklistItem> _preventiveChecklist() => [
        ChecklistItem('Limpieza de serpentines de condensador y evaporador'),
        ChecklistItem('Verificar presiones de alta y baja'),
        ChecklistItem('Revisar ajuste de bornes y conexiones eléctricas'),
        ChecklistItem('Medir consumo del compresor'),
        ChecklistItem('Revisar drenaje y bandeja de condensado'),
        ChecklistItem('Probar termostato y controlador'),
        ChecklistItem('Lubricar motores de ventiladores'),
      ];

  static List<WorkOrder> buildOrders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime at(int dayOffset, int h, [int m = 0]) =>
        today.add(Duration(days: dayOffset, hours: h, minutes: m));

    return [
      WorkOrder(
        number: 'OT-2026-1184',
        client: clients[0],
        contract: contracts['super'],
        type: OrderType.preventivo,
        priority: Priority.media,
        scheduled: at(0, 8),
        estimated: const Duration(hours: 2),
        title: 'Preventivo mensual de cámaras frigoríficas',
        description:
            'Visita mensual del contrato. Revisar cámaras de lácteos y carnes, '
            'tomar lecturas de los compresores y registrar fotos antes y después de la limpieza.',
        equipments: [
          Equipment(
            id: 'EQ-3301',
            name: 'Compresor cámara de carnes',
            brand: 'Copeland',
            model: 'ZB45KCE',
            serial: 'CP-22K-88413',
            location: 'Depósito trasero',
            measures: [
              _temp([78, 80, 81, 84]),
              _vib([2.1, 2.3, 2.6, 3.1]),
              _amp([14.2, 14.6, 15.1, 15.8], 18),
              _hours([10450, 11180, 11905, 12640]),
            ],
          ),
          Equipment(
            id: 'EQ-3302',
            name: 'Evaporador cámara de lácteos',
            brand: 'Bohn',
            model: 'BHE-160',
            serial: 'BH-19-55021',
            location: 'Salón de ventas',
            measures: [
              _pres([66, 65, 64, 63]),
              _amp([3.2, 3.2, 3.3, 3.3], 5),
            ],
          ),
          Equipment(
            id: 'EQ-3303',
            name: 'Condensadora góndola refrigerada',
            brand: 'Danfoss',
            model: 'OP-MPZM034',
            serial: 'DF-21-10992',
            location: 'Azotea',
            measures: [
              _temp([72, 73, 72, 74]),
              _vib([1.4, 1.5, 1.5, 1.6]),
            ],
          ),
        ],
        checklist: _preventiveChecklist(),
        photos: [
          OrderPhoto(
              stage: PhotoStage.antes,
              caption: 'Serpentín condensador',
              color: const Color(0xFF94A3B8)),
        ],
      ),
      WorkOrder(
        number: 'OT-2026-1187',
        client: clients[1],
        contract: contracts['clinica'],
        type: OrderType.correctivo,
        priority: Priority.urgente,
        scheduled: at(0, 10, 30),
        estimated: const Duration(hours: 1, minutes: 30),
        title: 'Equipo de quirófano 2 no enfría',
        description:
            'Reclamo del cliente: el split del quirófano 2 enciende pero no baja de 26 °C. '
            'Prioridad por SLA del contrato (2 h).',
        equipments: [
          Equipment(
            id: 'EQ-2110',
            name: 'Split quirófano 2',
            brand: 'Carrier',
            model: '42QHC024',
            serial: 'CR-20-77120',
            location: 'Planta alta, quirófano 2',
            measures: [
              _pres([68, 67, 61, 52]),
              _amp([9.8, 9.9, 10.4, 11.6], 12),
            ],
          ),
        ],
      ),
      WorkOrder(
        number: 'OT-2026-1190',
        client: clients[3],
        type: OrderType.correctivo,
        priority: Priority.alta,
        scheduled: at(0, 13, 30),
        estimated: const Duration(hours: 1),
        title: 'Heladera exhibidora con ruido fuerte',
        description:
            'Cliente sin contrato. La exhibidora de postres hace ruido fuerte al arrancar. '
            'Presupuestar si hace falta cambiar el ventilador.',
      ),
      WorkOrder(
        number: 'OT-2026-1193',
        client: clients[4],
        contract: contracts['frigo'],
        type: OrderType.predictivo,
        priority: Priority.media,
        scheduled: at(0, 15, 30),
        estimated: const Duration(hours: 2, minutes: 30),
        title: 'Ronda predictiva de compresores de túnel',
        description:
            'Tomar lecturas de vibración, temperatura y consumo de los compresores del túnel de congelado. '
            'Informar si alguna variable supera el límite.',
        equipments: [
          Equipment(
            id: 'EQ-5001',
            name: 'Compresor tornillo N.º 1',
            brand: 'Bitzer',
            model: 'HSK7461',
            serial: 'BZ-18-30019',
            location: 'Sala de máquinas',
            measures: [
              _temp([82, 83, 83, 85]),
              _vib([3.0, 3.4, 3.9, 4.3]),
              _amp([88, 90, 91, 94], 110),
              _hours([31200, 31920, 32650, 33390]),
            ],
          ),
          Equipment(
            id: 'EQ-5002',
            name: 'Compresor tornillo N.º 2',
            brand: 'Bitzer',
            model: 'HSK7461',
            serial: 'BZ-18-30020',
            location: 'Sala de máquinas',
            measures: [
              _temp([80, 80, 81, 80]),
              _vib([2.2, 2.2, 2.3, 2.2]),
              _amp([86, 86, 87, 86], 110),
              _hours([29870, 30590, 31300, 32010]),
            ],
          ),
        ],
      ),
      WorkOrder(
        number: 'OT-2026-1196',
        client: clients[2],
        contract: contracts['hotel'],
        type: OrderType.preventivo,
        priority: Priority.baja,
        scheduled: at(1, 9),
        estimated: const Duration(hours: 3),
        title: 'Preventivo bimestral de chiller y fan coils',
        description: 'Mantenimiento del chiller central y revisión de fan coils de los pisos 3 a 5.',
        equipments: [
          Equipment(
            id: 'EQ-4100',
            name: 'Chiller central',
            brand: 'Trane',
            model: 'CGAM 052',
            serial: 'TR-17-66001',
            location: 'Azotea',
            measures: [
              _temp([74, 75, 75, 76]),
              _pres([62, 62, 61, 61]),
              _amp([65, 66, 66, 67], 80),
            ],
          ),
        ],
        checklist: _preventiveChecklist(),
      ),
      WorkOrder(
        number: 'OT-2026-1198',
        client: clients[5],
        type: OrderType.instalacion,
        priority: Priority.media,
        scheduled: at(1, 14),
        estimated: const Duration(hours: 4),
        title: 'Instalación de 2 splits inverter 18.000 BTU',
        description: 'Instalar dos equipos nuevos en la sala de reuniones del piso 8. Cañería ya presupuestada.',
      ),
      WorkOrder(
        number: 'OT-2026-1201',
        client: clients[1],
        contract: contracts['clinica'],
        type: OrderType.preventivo,
        priority: Priority.media,
        scheduled: at(2, 8, 30),
        estimated: const Duration(hours: 2),
        title: 'Preventivo quincenal de climatización',
        description: 'Revisión de equipos de áreas críticas según plan del contrato.',
        checklist: _preventiveChecklist(),
      ),
      WorkOrder(
        number: 'OT-2026-1179',
        client: clients[0],
        contract: contracts['super'],
        type: OrderType.correctivo,
        priority: Priority.alta,
        scheduled: at(-1, 16),
        estimated: const Duration(hours: 1),
        status: OrderStatus.finalizada,
        title: 'Pérdida de gas en góndola de congelados',
        description: 'Se detectó pérdida en la soldadura de la línea de líquido.',
        supplies: [
          UsedSupply(supplies[1], 2.5),
          UsedSupply(supplies[2], 1),
        ],
      )
        ..elapsed = const Duration(hours: 1, minutes: 12)
        ..diagnosis = 'Se resoldó la línea de líquido, se cambió el filtro y se recargó gas.'
        ..signerName = 'Laura Giménez'
        ..closedAt = at(-1, 17, 15),
    ];
  }

  /// Colores para las fotos de ejemplo cuando no hay cámara.
  static const photoSwatches = [
    Color(0xFF94A3B8),
    Color(0xFF7C9CBF),
    Color(0xFF8FA98B),
    Color(0xFFB8A07E),
    Color(0xFFA3879C),
  ];
}
