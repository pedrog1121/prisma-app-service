# Relevamiento de requerimientos: Prisma App Service

> Estado: **borrador v0.2**. Armado a partir de la descripción inicial. El prototipo con datos de prueba ya cubre los puntos marcados con ✅.

## 1. Contexto y objetivo

Prisma ERP ya tiene un módulo de servicio técnico / CRM de servicios (órdenes de trabajo, contratos, presupuestos). Esta app lleva ese módulo al celular del técnico de campo.

**Objetivo:** que el técnico reciba sus órdenes, las ejecute y las cierre desde el celular. Todo lo que registre (tiempos, lecturas, fotos, insumos, firma) vuelve al ERP sin cargarse a mano en la oficina.

## 2. Usuarios y roles

| Rol | Uso de la app |
|-----|---------------|
| Técnico de campo | Ve su agenda y ruta, ejecuta y cierra órdenes. |
| Supervisor / coordinador | Asigna órdenes y ve el avance desde el ERP web (fuera del alcance de la app por ahora). |
| Cliente | Firma la conformidad en el celular del técnico. |

## 3. Alcance del MVP

**Incluido:** agenda, órdenes, ejecución (cronómetro, equipos, fotos, checklist, insumos), cierre con firma y ruta del día.

**Fuera de alcance por ahora:** creación de órdenes desde la app, presupuestos, cobros en campo, chat con la oficina.

## 4. Requerimientos funcionales

| ID | Requerimiento | Prioridad | Prototipo |
|----|---------------|-----------|-----------|
| RF-01 | Iniciar sesión con el usuario del ERP. | Must | ✅ (simulado) |
| RF-02 | Ver la agenda asignada por día, con el resumen del día. | Must | ✅ |
| RF-03 | Listar y buscar órdenes, con filtros por estado y contrato. | Must | ✅ |
| RF-04 | Ver el detalle de la orden: cliente, contacto, tarea, prioridad, tipo y contrato. | Must | ✅ |
| RF-05 | Avisar "En camino". | Should | ✅ (simulado) |
| RF-06 | Cronómetro de trabajo: iniciar, pausar, reanudar y registrar el tiempo total. | Must | ✅ |
| RF-07 | Si la orden pertenece a un contrato, cargar lecturas de los equipos para el mantenimiento predictivo, comparadas con el historial y con alerta fuera de rango. | Must | ✅ |
| RF-08 | Checklist de tareas del preventivo. | Must | ✅ |
| RF-09 | Fotos antes, durante y después, desde la cámara o la galería. | Must | ✅ |
| RF-10 | Registrar insumos usados desde el stock asignado, con cantidades. | Must | ✅ |
| RF-11 | Cerrar la orden con el trabajo realizado y el nombre y la firma del cliente, validando los requisitos. | Must | ✅ |
| RF-12 | Ver la ruta del día en el mapa, con orden de visitas, distancia y tiempo, y abrir la navegación. | Should | ✅ (mapa ilustrativo) |
| RF-13 | Llamar al cliente y abrir "Cómo llegar". | Should | ✅ |
| RF-14 | Funcionar sin conexión y sincronizar al recuperar señal. | Must | Pendiente |
| RF-15 | Notificaciones de órdenes nuevas o reasignadas. | Should | Pendiente |
| RF-16 | Generar y enviar al cliente el comprobante de servicio en PDF. | Could | Pendiente |

## 5. Requerimientos no funcionales

- **Plataformas:** Android e iOS con Flutter, en un solo código base.
- **Sin conexión:** la jornada se tiene que poder completar sin señal (base local y cola de sincronización).
- **Fotos:** comprimidas antes de subir (máx. 1600 px, calidad 80).
- **Seguridad:** autenticación contra el ERP con token; cada técnico ve solo sus órdenes.
- **Idioma y formato:** español; montos en guaraníes (Gs.).

## 6. Pantallas

1. Inicio de sesión.
2. Agenda (inicio): resumen del día, selector de semana y órdenes del día.
3. Órdenes: búsqueda y filtros.
4. Detalle de la orden, con pestañas Detalle, Equipos (solo con contrato), Fotos, Insumos y Cierre.
5. Ruta del día.
6. Perfil.

## 7. Integración con Prisma ERP (a definir)

Endpoints necesarios, a validar contra el contrato de API del módulo de servicios (`pantallas.md`):

- `GET /tecnicos/me/ordenes?desde&hasta`: agenda del técnico.
- `GET /ordenes/{id}`: detalle con cliente, contrato, equipos y checklist.
- `POST /ordenes/{id}/eventos`: en camino, inicio, pausa, reanudación y cierre del cronómetro.
- `POST /ordenes/{id}/lecturas`: lecturas de equipos (predictivo).
- `POST /ordenes/{id}/fotos`: subida de fotos (multipart).
- `POST /ordenes/{id}/insumos`: insumos usados (descuento de stock).
- `POST /ordenes/{id}/cierre`: diagnóstico, firma (imagen) y nombre de quien firma.
- `GET /tecnicos/me/stock`: stock de la camioneta.

## 8. Preguntas abiertas

1. ¿Ya existe en el ERP un catálogo de variables por tipo de equipo (rangos mínimo y máximo) o hay que crearlo?
2. ¿El stock de insumos se lleva por técnico o camioneta, o se descuenta del depósito central?
3. Mencionaste que ya hay un módulo similar (cronómetro, fotos, firma). ¿Es parte del ERP web? ¿Reutilizamos su API?
4. ¿Las órdenes sin contrato también requieren checklist o fotos obligatorias?
5. ¿Qué proveedor de mapas se usará en producción (Google Maps, Mapbox u OpenStreetMap)?
6. ¿El cliente necesita recibir un comprobante (PDF o correo) al cierre?
