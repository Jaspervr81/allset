import 'package:flutter/material.dart';

/// Central design system for AllSet
class AppTheme {
  AppTheme._();

  // ── Accent ──────────────────────────────────────────────
  static const Color accent = Color(0xFF7C5CFC);
  static const Color accentSoft = Color(0x337C5CFC);

  // ── Dark palette ────────────────────────────────────────
  static const Color dBg = Color(0xFF0D0D12);
  static const Color dSurface = Color(0xFF1A1A26);
  static const Color dSurface2 = Color(0xFF252538);
  static const Color dBorder = Color(0xFF333350);
  static const Color dText = Color(0xFFF0F0F8);
  static const Color dSubtext = Color(0xFF8080A0);

  // ── Light palette ───────────────────────────────────────
  static const Color lBg = Color(0xFFF2F2F7);
  static const Color lSurface = Color(0xFFFFFFFF);
  static const Color lSurface2 = Color(0xFFE8E8F2);
  static const Color lBorder = Color(0xFFD8D8E8);
  static const Color lText = Color(0xFF0D0D20);
  static const Color lSubtext = Color(0xFF777792);

  // ── Item tag colours ────────────────────────────────────
  static const Color tagPurple = Color(0xFFAA88FF);
  static const Color tagRed = Color(0xFFFF6B6B);
  static const Color tagOrange = Color(0xFFFFAA55);

  // ── Semantic helpers ────────────────────────────────────
  static Color bg(bool dark) => dark ? dBg : lBg;
  static Color surface(bool dark) => dark ? dSurface : lSurface;
  static Color surface2(bool dark) => dark ? dSurface2 : lSurface2;
  static Color border(bool dark) => dark ? dBorder : lBorder;
  static Color text(bool dark) => dark ? dText : lText;
  static Color subtext(bool dark) => dark ? dSubtext : lSubtext;

  static Color itemColor(String? code, bool dark) {
    switch (code) {
      case 'purple':
        return tagPurple;
      case 'red':
        return tagRed;
      case 'orange':
        return tagOrange;
      default:
        return text(dark);
    }
  }

  static Color itemBarColor(String? code) {
    switch (code) {
      case 'purple':
        return tagPurple;
      case 'red':
        return tagRed;
      case 'orange':
        return tagOrange;
      default:
        return Colors.transparent;
    }
  }

  // ── Theme data ──────────────────────────────────────────
  static ThemeData themeData(bool dark) {
    final cs = dark
        ? ColorScheme.dark(
            primary: accent,
            surface: dSurface,
            onSurface: dText,
            outline: dBorder,
          )
        : ColorScheme.light(
            primary: accent,
            surface: lSurface,
            onSurface: lText,
            outline: lBorder,
          );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: bg(dark),
      dialogTheme: DialogThemeData(backgroundColor: surface(dark)),
      dividerColor: border(dark),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accentSoft : null,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2(dark),
        selectedColor: accentSoft,
        labelStyle: TextStyle(color: text(dark), fontSize: 13),
        side: BorderSide(color: border(dark)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2(dark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border(dark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border(dark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: subtext(dark)),
        hintStyle: TextStyle(color: subtext(dark)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // ── Route transitions ────────────────────────────────────

  /// Slides up from bottom — for modals / library screens
  static Route<T> slideUp<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (context, anim, secAnim) => page,
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, anim, secAnim, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutQuart));
          final fade = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
                parent: anim, curve: const Interval(0, 0.5)),
          );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      );

  /// Crossfade — for performance mode (dramatic)
  static Route<T> fade<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (context, anim, secAnim) => page,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
      );

  /// Slide from right — for detail drill-downs
  static Route<T> slideRight<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (context, anim, secAnim) => page,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (context, anim, secAnim, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutQuart));
          return SlideTransition(position: slide, child: child);
        },
      );
}
