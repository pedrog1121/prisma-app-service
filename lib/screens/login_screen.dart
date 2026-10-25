import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1B4B), AppColors.primary, Color(0xFF0E7490)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Logo(),
                    const SizedBox(height: 18),
                    const Text('Prisma Service',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Órdenes de trabajo para técnicos de campo',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: TextEditingController(text: 'cbenitez'),
                            decoration: const InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            obscureText: true,
                            controller: TextEditingController(text: 'demo1234'),
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: AppStore.instance.login,
                            child: const Text('Ingresar'),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Modo demostración: cualquier usuario ingresa con datos de prueba.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: CustomPaint(painter: _PrismPainter()),
      ),
    );
  }
}

class _PrismPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final tri = Path()
      ..moveTo(c.dx, c.dy - 20)
      ..lineTo(c.dx + 19, c.dy + 14)
      ..lineTo(c.dx - 19, c.dy + 14)
      ..close();
    canvas.drawPath(
        tri,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round);
    const colors = [Color(0xFF67E8F9), Color(0xFFA5B4FC), Color(0xFFF9A8D4)];
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(c.dx + 6, c.dy - 2 + i * 5.0),
        Offset(c.dx + 26, c.dy + 2 + i * 8.0),
        Paint()
          ..color = colors[i]
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
