import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/app_store.dart';
import 'design/theme.dart';
import 'design/web_insets.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  // Con ?semantics en la URL se activa el árbol de accesibilidad (pruebas automáticas)
  if (kIsWeb && Uri.base.queryParameters.containsKey('semantics')) {
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const PrismaApp());
}

class PrismaApp extends StatelessWidget {
  const PrismaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prisma Service',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      themeAnimationDuration: const Duration(milliseconds: 300),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => _SafeAreaFromWeb(child: child!),
      home: ListenableBuilder(
        listenable: AppStore.instance,
        builder: (context, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: Tween(begin: 0.98, end: 1.0).animate(anim), child: child),
          ),
          child: AppStore.instance.loggedIn
              ? const HomeShell(key: ValueKey('home'))
              : const LoginScreen(key: ValueKey('login')),
        ),
      ),
    );
  }
}

/// Suma las zonas seguras que mide el index.html (notch e indicador de inicio)
/// cuando la app corre como PWA en el iPhone.
class _SafeAreaFromWeb extends StatelessWidget {
  const _SafeAreaFromWeb({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final web = readWebSafeArea();
    if (web == EdgeInsets.zero) return child;
    final mq = MediaQuery.of(context);
    EdgeInsets merge(EdgeInsets a) => EdgeInsets.fromLTRB(
          a.left > web.left ? a.left : web.left,
          a.top > web.top ? a.top : web.top,
          a.right > web.right ? a.right : web.right,
          a.bottom > web.bottom ? a.bottom : web.bottom,
        );
    return MediaQuery(
      data: mq.copyWith(padding: merge(mq.padding), viewPadding: merge(mq.viewPadding)),
      child: child,
    );
  }
}
