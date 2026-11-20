import 'package:flutter/material.dart';

/// الهوية البصرية الداكنة للعبة "إمبراطورية الذكاء الاصطناعي":
/// ألوان مختبر ذكاء اصطناعي عصري مع تباين عالٍ وتدرج بصري واضح.
class EmpireColors {
  const EmpireColors._();

  static const Color bg = Color(0xFF090E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF182235);
  static const Color border = Color(0xFF25334D);

  static const Color cyan = Color(0xFF00E5C4);
  static const Color indigo = Color(0xFF7C6BFF);
  static const Color gold = Color(0xFFF5B942);
  static const Color emerald = Color(0xFF22C55E);
  static const Color coral = Color(0xFFF43F5E);
  static const Color amber = Color(0xFFF59E0B);
  static const Color sky = Color(0xFF38BDF8);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

ThemeData buildEmpireTheme() {
  const colorScheme = ColorScheme.dark(
    primary: EmpireColors.cyan,
    onPrimary: Color(0xFF04221D),
    primaryContainer: Color(0xFF0A3D36),
    onPrimaryContainer: Color(0xFFB3FFF2),
    secondary: EmpireColors.indigo,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF262052),
    onSecondaryContainer: Color(0xFFDCD6FF),
    tertiary: EmpireColors.gold,
    onTertiary: Color(0xFF291C00),
    error: EmpireColors.coral,
    onError: Colors.white,
    surface: EmpireColors.surface,
    onSurface: EmpireColors.textPrimary,
    onSurfaceVariant: EmpireColors.textSecondary,
    outline: EmpireColors.border,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: EmpireColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: EmpireColors.bg,
      foregroundColor: EmpireColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: EmpireColors.textPrimary,
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: const CardThemeData(
      color: EmpireColors.surface,
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: EmpireColors.border, width: 1),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: EmpireColors.cyan,
        foregroundColor: const Color(0xFF04221D),
        disabledBackgroundColor: EmpireColors.surfaceElevated,
        disabledForegroundColor: EmpireColors.textMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: EmpireColors.indigo,
        foregroundColor: Colors.white,
        disabledBackgroundColor: EmpireColors.surfaceElevated,
        disabledForegroundColor: EmpireColors.textMuted,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: EmpireColors.cyan,
        disabledForegroundColor: EmpireColors.textMuted,
        side: const BorderSide(color: EmpireColors.border, width: 1.2),
        backgroundColor: EmpireColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: EmpireColors.textSecondary,
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: EmpireColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: EmpireColors.cyan.withOpacity(0.16),
      height: 66,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          color: selected ? EmpireColors.cyan : EmpireColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: selected ? EmpireColors.cyan : EmpireColors.textSecondary,
        );
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: EmpireColors.border,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: EmpireColors.textPrimary,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        color: EmpireColors.textSecondary,
        fontSize: 12.5,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        color: EmpireColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: EmpireColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
