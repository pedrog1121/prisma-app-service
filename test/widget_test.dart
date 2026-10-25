import 'package:flutter_test/flutter_test.dart';
import 'package:prisma_app_service/main.dart';

void main() {
  testWidgets('muestra la pantalla de inicio', (tester) async {
    await tester.pumpWidget(const PrismaApp());
    expect(find.text('Bienvenido'), findsOneWidget);
  });
}
