import 'dart:js_interop';

import 'package:flutter/widgets.dart';

@JS('__prismaInsets')
external _Insets? get _insets;

extension type _Insets._(JSObject _) implements JSObject {
  external double get top;
  external double get right;
  external double get bottom;
  external double get left;
}

/// Flutter web no recibe `env(safe-area-inset-*)`, así que el index.html las mide
/// y las publica en `window.__prismaInsets` (notch e indicador de inicio en la PWA).
EdgeInsets readWebSafeArea() {
  final i = _insets;
  if (i == null) return EdgeInsets.zero;
  return EdgeInsets.fromLTRB(i.left, i.top, i.right, i.bottom);
}
