# Prisma App Service

App móvil para los técnicos de campo de **Prisma ERP**, hecha en **Flutter** para **Android e iOS**.

> Estado: **prototipo con datos de prueba**. Todavía no se conecta al ERP.

**Vista previa web:** https://pedrog1121.github.io/prisma-app-service/

## Qué incluye

- **Agenda asignada:** las órdenes del día y de la semana, con un resumen de pendientes, en curso y finalizadas.
- **Órdenes de trabajo:** búsqueda y filtros (pendientes, en curso, finalizadas, con contrato).
- **Detalle de la orden:**
  - Cronómetro: iniciar, pausar y reanudar.
  - Aviso "En camino".
  - Llamar al cliente y abrir "Cómo llegar".
  - **Equipos (solo órdenes de contrato):** lecturas para mantenimiento predictivo (temperatura, vibración, consumo, presión, horas de uso), comparadas con visitas anteriores. Marca las que quedan fuera de rango.
  - **Fotos:** antes, durante y después, más el checklist del preventivo.
  - **Insumos:** se eligen del stock de la camioneta, con cantidades y total en guaraníes.
  - **Cierre:** trabajo realizado, nombre y firma del cliente. Valida los requisitos antes de cerrar.
- **Ruta del día:** mapa con el orden de visitas, distancia y tiempo estimados, y navegación en Google Maps.

## Ejecutar

Requisitos: Flutter 3.27 o superior y Android Studio o Xcode.

```bash
flutter pub get
flutter run          # en un emulador o dispositivo
flutter test
```

Para generar la vista previa web:

```bash
flutter build web --release --no-web-resources-cdn --pwa-strategy=none --base-href /prisma-app-service/
```

## Estructura

```
lib/
  data/        modelos, datos de prueba y estado (AppStore)
  screens/     agenda, órdenes, ruta, perfil y detalle de la orden (con sus pestañas en order_tabs/)
  widgets/     componentes reutilizables (firma, mapa de ruta, mini gráficos, tarjetas)
docs/          relevamiento de requerimientos
```

Los datos de prueba están en `lib/data/mock_data.dart`. Al integrar con el ERP, `AppStore` se reemplaza por un repositorio que use la API.

## Documentación

- Relevamiento de requerimientos: [docs/requerimientos.md](docs/requerimientos.md)
