import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prisma_app_service/main.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('ingresa y muestra la agenda del técnico', (tester) async {
    await tester.pumpWidget(const PrismaApp());
    expect(find.text('Ingresar'), findsOneWidget);

    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();
    expect(find.text('Hola, Carlos'), findsOneWidget);
  });
}
