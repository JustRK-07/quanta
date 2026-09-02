import 'package:flutter/material.dart';

/// Quanta palette — "dark observatory" identity.
///
/// The cyan/amber/violet/emerald accents are picked to be readable on the
/// deep navy scaffold, and to give each subject (physics / chemistry / math /
/// biology) its own colour-coded badge in the history list.
abstract final class QuantaColors {
  /// Deep void navy — every scaffold paints this colour.
  static const void0 = Color(0xFF0A0E1A);

  /// One shade up from the void — raised surfaces (cards, sheets).
  static const surface1 = Color(0xFF121829);

  /// Neon cyan — primary accent, AppBar titles, scan button.
  static const cyan = Color(0xFF00E5FF);

  /// Amber — secondary accent, used for quiz/star emphasis.
  static const amber = Color(0xFFFFB300);

  /// Subject accent: math.
  static const violet = Color(0xFF9B5DE5);

  /// Subject accent: biology.
  static const emerald = Color(0xFF00E676);

  /// Subject accent: unclassified (other).
  static const slate = Color(0xFF64748B);

  /// Subject accent: chemistry.
  static const chemistry = Color(0xFFFFB300);

  /// Subject accent: physics.
  static const physics = Color(0xFF00E5FF);
}

/// Quanta dark theme — the default look.
ThemeData get quantaDark => _buildQuantaTheme(Brightness.dark);

/// Light counterpart — kept for the Settings toggle, but the app boots dark.
ThemeData get quantaLight => _buildQuantaTheme(Brightness.light);

ThemeData _buildQuantaTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: QuantaColors.cyan,
    brightness: brightness,
  ).copyWith(
    // M3 tonal derivation from cyan lands near #191C1D on dark — force our
    // exact surface tones so the scaffold matches the brand spec.
    surface: isDark ? QuantaColors.surface1 : Colors.white,
    tertiary: QuantaColors.amber,
    onTertiary: Colors.black,
  );

  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: isDark ? QuantaColors.void0 : Colors.white,
    cardColor: isDark ? QuantaColors.surface1 : Colors.white,
    textTheme: _quantatextTheme(
      brightness == Brightness.dark ? Typography.whiteMountainView : Typography.blackMountainView,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? QuantaColors.surface1 : Colors.white,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    iconTheme: IconThemeData(color: scheme.onSurface),
  );
}

/// Light tweak — pull Material's default textTheme and apply our colour
/// weights to avoid a complete typography redefinition. The "Inter" family is
/// declared in pubspec.yaml; calling `TextStyle(fontFamily: 'Inter')` later
/// will be honoured when assets/fonts/ are bundled.
TextTheme _quantatextTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w800),
    headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );
}

/// Mono style for variables, formulas, and code — JetBrains Mono.
TextStyle quantaMono(BuildContext c, {double size = 13, Color? color}) {
  final cs = Theme.of(c).colorScheme;
  return TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: const ['monospace'],
    fontSize: size,
    color: color ?? cs.onSurface.withValues(alpha: 0.75),
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
