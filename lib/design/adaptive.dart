import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// true en iPhone/iPad (también en la PWA de Safari).
bool isCupertino(BuildContext context) {
  final p = Theme.of(context).platform;
  return p == TargetPlatform.iOS || p == TargetPlatform.macOS;
}

/// Navega con la transición nativa (deslizar para volver en iOS).
Future<T?> pushPage<T>(BuildContext context, WidgetBuilder builder) {
  final route = isCupertino(context) ? CupertinoPageRoute<T>(builder: builder) : MaterialPageRoute<T>(builder: builder);
  return Navigator.of(context).push(route);
}

/// Hoja inferior: modal de tarjeta en iOS, bottom sheet en Android.
Future<T?> showPrismaSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool tall = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    constraints: tall ? BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88) : null,
    builder: builder,
  );
}

/// Confirmación con el diálogo nativo de cada plataforma.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showAdaptiveDialog<bool>(
    context: context,
    builder: (ctx) {
      if (isCupertino(ctx)) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Padding(padding: const EdgeInsets.only(top: 6), child: Text(message)),
          actions: [
            CupertinoDialogAction(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            CupertinoDialogAction(
              isDefaultAction: !destructive,
              isDestructiveAction: destructive,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel),
            ),
          ],
        );
      }
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class Haptics {
  static void tap() => HapticFeedback.selectionClick();
  static void success() => HapticFeedback.mediumImpact();
  static void warning() => HapticFeedback.heavyImpact();
}

void showToast(BuildContext context, String message, {IconData icon = Icons.check_circle_rounded}) {
  final c = context.pc;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      margin: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
      content: Row(
        children: [
          Icon(icon, color: c.background, size: 20),
          const SizedBox(width: Space.md),
          Expanded(child: Text(message)),
        ],
      ),
    ));
}
