import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prisma_app_service/main.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('ingresa y muestra la agenda del técnico', (tester) async {
    await tester.pumpWidget(const PrismaApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Ingresar'), findsOneWidget);

    await tester.tap(find.text('Ingresar'));
    // La pantalla de inicio tiene animaciones continuas: se avanza el reloj a mano.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Próxima visita'.toUpperCase()), findsOneWidget);
    expect(find.text('Supermercado La Esperanza'), findsWidgets);
  });
}
