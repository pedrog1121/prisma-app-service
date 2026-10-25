import 'package:flutter/material.dart';

/// Paleta de Prisma ERP (convertida desde los tokens oklch de la guía de color).
///
/// Reglas de uso:
/// - Los neutros arman la estructura: fondo → superficie → hundida → elevada.
/// - `primary` solo para la acción principal de cada zona.
/// - `selection` indica dónde estoy (pestaña, filtro, día elegido), no qué hago.
/// - Los estados tienen tres variantes: sólido, texto y suave.
/// - Los acentos de módulo se usan solo en marcadores e íconos.
@immutable
class PrismaColors extends ThemeExtension<PrismaColors> {
  const PrismaColors({
    required this.background,
    required this.frame,
    required this.surface,
    required this.sunken,
    required this.elevated,
    required this.field,
    required this.fieldReadonly,
    required this.foreground,
    required this.muted,
    required this.faint,
    required this.border,
    required this.input,
    required this.strongBorder,
    required this.primary,
    required this.onPrimary,
    required this.selection,
    required this.onSelection,
    required this.ring,
    required this.success,
    required this.successText,
    required this.successSoft,
    required this.warning,
    required this.onWarning,
    required this.warningText,
    required this.warningSoft,
    required this.danger,
    required this.dangerText,
    required this.dangerSoft,
    required this.info,
    required this.infoText,
    required this.infoSoft,
    required this.closedText,
    required this.closedSoft,
    required this.modTeal,
    required this.modAmber,
    required this.modBlue,
    required this.modViolet,
    required this.shadow,
  });

  final Color background;
  final Color frame;
  final Color surface;
  final Color sunken;
  final Color elevated;
  final Color field;
  final Color fieldReadonly;
  final Color foreground;
  final Color muted;
  final Color faint;
  final Color border;
  final Color input;
  final Color strongBorder;
  final Color primary;
  final Color onPrimary;
  final Color selection;
  final Color onSelection;
  final Color ring;
  final Color success;
  final Color successText;
  final Color successSoft;
  final Color warning;
  final Color onWarning;
  final Color warningText;
  final Color warningSoft;
  final Color danger;
  final Color dangerText;
  final Color dangerSoft;
  final Color info;
  final Color infoText;
  final Color infoSoft;
  final Color closedText;
  final Color closedSoft;
  final Color modTeal;
  final Color modAmber;
  final Color modBlue;
  final Color modViolet;
  final Color shadow;

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D4BD1), Color(0xFF864AD2), Color(0xFF00B3CB)],
    stops: [0, 0.55, 1],
  );

  static const light = PrismaColors(
    background: Color(0xFFEEF0F6),
    frame: Color(0xFFF8F9FD),
    surface: Color(0xFFFFFFFF),
    sunken: Color(0xFFF4F6FA),
    elevated: Color(0xFFFFFFFF),
    field: Color(0xFFFFFFFF),
    fieldReadonly: Color(0xFFF2F3F8),
    foreground: Color(0xFF161A29),
    muted: Color(0xFF525769),
    faint: Color(0xFF666B7B),
    border: Color(0xFFDDDFE6),
    input: Color(0xFF8C909D),
    strongBorder: Color(0xFF6B7184),
    primary: Color(0xFF4D4BD1),
    onPrimary: Color(0xFFFCFCFC),
    selection: Color(0xFFE3E8FF),
    onSelection: Color(0xFF33348A),
    ring: Color(0xFF5A5CE2),
    success: Color(0xFF007E46),
    successText: Color(0xFF006436),
    successSoft: Color(0xFFDCF9E5),
    warning: Color(0xFFEFA831),
    onWarning: Color(0xFF311D03),
    warningText: Color(0xFF864900),
    warningSoft: Color(0xFFFFF0CC),
    danger: Color(0xFFD01D21),
    dangerText: Color(0xFFB7191C),
    dangerSoft: Color(0xFFFFECE9),
    info: Color(0xFF0074BA),
    infoText: Color(0xFF005B9C),
    infoSoft: Color(0xFFE0F3FF),
    closedText: Color(0xFF5A4E72),
    closedSoft: Color(0xFFF0ECFA),
    modTeal: Color(0xFF009D89),
    modAmber: Color(0xFFD98A2E),
    modBlue: Color(0xFF2D86C8),
    modViolet: Color(0xFF9A66BE),
    shadow: Color(0x1A1B2040),
  );

  static const dark = PrismaColors(
    background: Color(0xFF080B13),
    frame: Color(0xFF0D1019),
    surface: Color(0xFF141721),
    sunken: Color(0xFF0F121C),
    elevated: Color(0xFF1D212E),
    field: Color(0xFF0D0F17),
    fieldReadonly: Color(0xFF181B25),
    foreground: Color(0xFFECEEF4),
    muted: Color(0xFFA8AEBE),
    faint: Color(0xFF8C92A2),
    border: Color(0xFF272B37),
    input: Color(0xFF656B7E),
    strongBorder: Color(0xFF7A8093),
    primary: Color(0xFF808AFF),
    onPrimary: Color(0xFF080B14),
    selection: Color(0xFF262A4B),
    onSelection: Color(0xFFCBD4FF),
    ring: Color(0xFF8D98FF),
    success: Color(0xFF4EBE7D),
    successText: Color(0xFF6CD092),
    successSoft: Color(0xFF0F2E1B),
    warning: Color(0xFFEDB345),
    onWarning: Color(0xFF201301),
    warningText: Color(0xFFF3BD5C),
    warningSoft: Color(0xFF3A270B),
    danger: Color(0xFFF3625D),
    dangerText: Color(0xFFFF8880),
    dangerSoft: Color(0xFF421C19),
    info: Color(0xFF5EACEB),
    infoText: Color(0xFF7CC2FD),
    infoSoft: Color(0xFF0E293D),
    closedText: Color(0xFFC3B6DF),
    closedSoft: Color(0xFF292335),
    modTeal: Color(0xFF43BBA7),
    modAmber: Color(0xFFECA851),
    modBlue: Color(0xFF5EACEB),
    modViolet: Color(0xFFBC8FDD),
    shadow: Color(0x66000000),
  );

  List<BoxShadow> get cardShadow => [
        BoxShadow(color: shadow.withValues(alpha: shadow.a * 0.6), blurRadius: 2, offset: const Offset(0, 1)),
        BoxShadow(color: shadow, blurRadius: 14, offset: const Offset(0, 4)),
      ];

  List<BoxShadow> get raisedShadow => [
        BoxShadow(color: shadow.withValues(alpha: shadow.a * 1.6), blurRadius: 30, offset: const Offset(0, 10)),
      ];

  @override
  PrismaColors copyWith() => this;

  @override
  PrismaColors lerp(PrismaColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PrismaColors(
      background: l(background, other.background),
      frame: l(frame, other.frame),
      surface: l(surface, other.surface),
      sunken: l(sunken, other.sunken),
      elevated: l(elevated, other.elevated),
      field: l(field, other.field),
      fieldReadonly: l(fieldReadonly, other.fieldReadonly),
      foreground: l(foreground, other.foreground),
      muted: l(muted, other.muted),
      faint: l(faint, other.faint),
      border: l(border, other.border),
      input: l(input, other.input),
      strongBorder: l(strongBorder, other.strongBorder),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      selection: l(selection, other.selection),
      onSelection: l(onSelection, other.onSelection),
      ring: l(ring, other.ring),
      success: l(success, other.success),
      successText: l(successText, other.successText),
      successSoft: l(successSoft, other.successSoft),
      warning: l(warning, other.warning),
      onWarning: l(onWarning, other.onWarning),
      warningText: l(warningText, other.warningText),
      warningSoft: l(warningSoft, other.warningSoft),
      danger: l(danger, other.danger),
      dangerText: l(dangerText, other.dangerText),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      info: l(info, other.info),
      infoText: l(infoText, other.infoText),
      infoSoft: l(infoSoft, other.infoSoft),
      closedText: l(closedText, other.closedText),
      closedSoft: l(closedSoft, other.closedSoft),
      modTeal: l(modTeal, other.modTeal),
      modAmber: l(modAmber, other.modAmber),
      modBlue: l(modBlue, other.modBlue),
      modViolet: l(modViolet, other.modViolet),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension PrismaContext on BuildContext {
  PrismaColors get pc => Theme.of(this).extension<PrismaColors>()!;
  TextTheme get tt => Theme.of(this).textTheme;
}

/// Espaciado en grilla de 4 pt.
class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  /// Margen lateral de las pantallas.
  static const gutter = 20.0;
}

class Radii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 22.0;
  static const pill = 999.0;
}

class Motion {
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);
  static const enter = Curves.easeOutCubic;
  static const emphasized = Cubic(0.2, 0.0, 0, 1.0);
}
