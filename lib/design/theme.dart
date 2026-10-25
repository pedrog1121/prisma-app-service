import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';

const _font = 'Inter';

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? PrismaColors.dark : PrismaColors.light;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.selection,
    onPrimaryContainer: c.onSelection,
    secondary: c.primary,
    onSecondary: c.onPrimary,
    secondaryContainer: c.selection,
    onSecondaryContainer: c.onSelection,
    error: c.danger,
    onError: Colors.white,
    surface: c.surface,
    onSurface: c.foreground,
    onSurfaceVariant: c.muted,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.sunken,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.elevated,
    surfaceContainerHighest: c.sunken,
    outline: c.input,
    outlineVariant: c.border,
    shadow: c.shadow,
  );

  // Escala tipográfica
  final text = TextTheme(
    displaySmall:
        TextStyle(fontSize: 34, height: 1.1, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: c.foreground),
    headlineMedium:
        TextStyle(fontSize: 28, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: c.foreground),
    headlineSmall:
        TextStyle(fontSize: 24, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: c.foreground),
    titleLarge:
        TextStyle(fontSize: 20, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: c.foreground),
    titleMedium:
        TextStyle(fontSize: 17, height: 1.3, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: c.foreground),
    titleSmall:
        TextStyle(fontSize: 15, height: 1.3, fontWeight: FontWeight.w600, letterSpacing: -0.1, color: c.foreground),
    bodyLarge: TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w400, color: c.foreground),
    bodyMedium: TextStyle(fontSize: 14.5, height: 1.45, fontWeight: FontWeight.w400, color: c.foreground),
    bodySmall: TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w400, color: c.muted),
    labelLarge: TextStyle(fontSize: 15, height: 1.2, fontWeight: FontWeight.w600, color: c.foreground),
    labelMedium: TextStyle(fontSize: 12.5, height: 1.2, fontWeight: FontWeight.w600, color: c.muted),
    labelSmall: TextStyle(fontSize: 11, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: 0.7, color: c.faint),
  ).apply(fontFamily: _font);

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: _font,
    textTheme: text,
    extensions: [c],
  );

  OutlineInputBorder border(Color color, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        borderSide: BorderSide(color: color, width: w),
      );

  return base.copyWith(
    scaffoldBackgroundColor: c.background,
    canvasColor: c.background,
    splashFactory: InkRipple.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    }),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brightness,
      primaryColor: c.primary,
      scaffoldBackgroundColor: c.background,
      barBackgroundColor: c.frame.withValues(alpha: 0.82),
      textTheme: CupertinoTextThemeData(
        primaryColor: c.primary,
        textStyle: TextStyle(fontFamily: _font, fontSize: 16, color: c.foreground),
        navTitleTextStyle: TextStyle(
            fontFamily: _font, fontSize: 17, fontWeight: FontWeight.w600, color: c.foreground, letterSpacing: -0.2),
        navLargeTitleTextStyle: TextStyle(
            fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w700, color: c.foreground, letterSpacing: -0.9),
        navActionTextStyle: TextStyle(fontFamily: _font, fontSize: 16, color: c.primary),
        tabLabelTextStyle: const TextStyle(fontFamily: _font, fontSize: 10.5, fontWeight: FontWeight.w500),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: c.foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.frame,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.selection,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontFamily: _font,
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? c.onSelection : c.muted,
          )),
      iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(size: 24, color: s.contains(WidgetState.selected) ? c.onSelection : c.muted)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.field,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: TextStyle(color: c.faint, fontFamily: _font),
      labelStyle: TextStyle(color: c.muted, fontFamily: _font),
      floatingLabelStyle: TextStyle(color: c.ring, fontFamily: _font, fontWeight: FontWeight.w600),
      prefixIconColor: c.muted,
      border: border(c.input),
      enabledBorder: border(c.input),
      disabledBorder: border(c.border),
      focusedBorder: border(c.ring, 2),
      errorBorder: border(c.danger),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        disabledBackgroundColor: c.border,
        disabledForegroundColor: c.faint,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        textStyle: const TextStyle(fontFamily: _font, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: -0.1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.foreground,
        backgroundColor: c.surface,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        side: BorderSide(color: c.input),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        textStyle: const TextStyle(fontFamily: _font, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: -0.1),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        textStyle: const TextStyle(fontFamily: _font, fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: c.input, width: 1.5),
      fillColor:
          WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.success : Colors.transparent),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.success : c.border),
    ),
    dividerTheme: DividerThemeData(color: c.border, space: 1, thickness: 1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.elevated,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: c.strongBorder.withValues(alpha: 0.5),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl))),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: c.elevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.muted),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.foreground,
      contentTextStyle: TextStyle(fontFamily: _font, color: c.background, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary, linearTrackColor: c.border),
    iconTheme: IconThemeData(color: c.muted, size: 22),
  );
}
