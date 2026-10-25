import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../design/adaptive.dart';
import '../design/components.dart';
import '../design/tokens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _user = TextEditingController(text: 'cbenitez');
  final _pass = TextEditingController(text: 'demo1234');
  bool _loading = false;
  bool _obscure = true;

  late final _glow = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    _glow.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    Haptics.success();
    AppStore.instance.login();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final mq = MediaQuery.of(context);
    final heroHeight = math.max(260.0, mq.size.height * 0.42);

    return Scaffold(
      backgroundColor: c.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Fondo de marca con luz que se desplaza
          SizedBox(
            height: heroHeight + 60,
            child: AnimatedBuilder(
              animation: _glow,
              builder: (_, __) => CustomPaint(
                painter: _HeroPainter(_glow.value),
                size: Size.infinite,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: mq.padding.bottom + Space.xxl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      SizedBox(
                        height: heroHeight - mq.padding.top - 20,
                        child: const FadeSlideIn(child: _Brand()),
                      ),
                      FadeSlideIn(
                        index: 3,
                        offset: 40,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: Space.gutter),
                          padding: const EdgeInsets.fromLTRB(Space.xl, Space.xxl, Space.xl, Space.xl),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(Radii.xl),
                            boxShadow: c.raisedShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Iniciar sesión', style: context.tt.titleLarge),
                              const SizedBox(height: Space.xs),
                              Text('Usa tu usuario de Prisma ERP.', style: context.tt.bodySmall),
                              const SizedBox(height: Space.xl),
                              TextField(
                                controller: _user,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                decoration: const InputDecoration(
                                  labelText: 'Usuario',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: Space.md),
                              TextField(
                                controller: _pass,
                                obscureText: _obscure,
                                autofillHints: const [AutofillHints.password],
                                onSubmitted: (_) => _login(),
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(height: Space.xl),
                              FilledButton(
                                onPressed: _loading ? null : _login,
                                child: AnimatedSwitcher(
                                  duration: Motion.fast,
                                  child: _loading
                                      ? SizedBox(
                                          key: const ValueKey('l'),
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.5, color: c.faint),
                                        )
                                      : const Text('Ingresar', key: ValueKey('t')),
                                ),
                              ),
                              const SizedBox(height: Space.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.science_outlined, size: 16, color: c.faint),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text('Modo demostración con datos de prueba',
                                        style: context.tt.bodySmall?.copyWith(color: c.faint)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: CustomPaint(painter: PrismLogoPainter()),
        ),
        const SizedBox(height: Space.lg),
        const Text('Prisma Service',
            style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8)),
        const SizedBox(height: Space.xs),
        Text('Órdenes de trabajo en el campo',
            style: TextStyle(fontFamily: 'Inter', color: Colors.white.withValues(alpha: 0.78), fontSize: 15)),
      ],
    );
  }
}

class _HeroPainter extends CustomPainter {
  _HeroPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = PrismaColors.brandGradient.createShader(rect));
    // Haz de luz que recorre el fondo
    final a = t * math.pi * 2;
    final center = Offset(size.width * (0.5 + 0.35 * math.cos(a)), size.height * (0.35 + 0.2 * math.sin(a)));
    canvas.drawCircle(
      center,
      size.width * 0.6,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: center, radius: size.width * 0.6)),
    );
    // Rayos del prisma
    const rays = [Color(0x5567E8F9), Color(0x55A5B4FC), Color(0x55F9A8D4)];
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.62 + i * 0.07);
      canvas.drawLine(
        Offset(size.width * 0.55, size.height * 0.45),
        Offset(size.width * 1.1, y),
        Paint()
          ..color = rays[i]
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_HeroPainter old) => old.t != t;
}

/// Logo: triángulo que descompone la luz.
class PrismLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.width / 72;
    final tri = Path()
      ..moveTo(c.dx - 4 * s, c.dy - 19 * s)
      ..lineTo(c.dx + 14 * s, c.dy + 13 * s)
      ..lineTo(c.dx - 22 * s, c.dy + 13 * s)
      ..close();
    canvas.drawPath(
        tri,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * s
          ..strokeJoin = StrokeJoin.round);
    canvas.drawLine(
      Offset(c.dx - 26 * s, c.dy - 2 * s),
      Offset(c.dx - 9 * s, c.dy + 1 * s),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 2.4 * s
        ..strokeCap = StrokeCap.round,
    );
    const colors = [Color(0xFF67E8F9), Color(0xFFA5B4FC), Color(0xFFF9A8D4)];
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(c.dx + 4 * s, c.dy - 1 * s + i * 4 * s),
        Offset(c.dx + 24 * s, c.dy + 3 * s + i * 7 * s),
        Paint()
          ..color = colors[i]
          ..strokeWidth = 2.4 * s
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
