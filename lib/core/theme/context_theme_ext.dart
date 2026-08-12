// lib/core/theme/context_theme_ext.dart

import 'package:flutter/material.dart';

/// Shortcuts onto the current [ThemeData] (see [AppTheme] for the light/dark
/// definitions) so views pull UI-chrome colors — text, backgrounds,
/// surfaces, borders — from there instead of hardcoding [AppColors]
/// constants. That's what makes light/dark mode (driven by
/// `ThemeMode.system`) actually repaint the whole app.
///
/// Candle/semantic colors (bullish, bearish, warning, ...) are deliberately
/// NOT included here: those are brand-constant regardless of brightness
/// (green means "up" in both light and dark mode), so they stay as direct
/// [AppColors] references at call sites.
extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}
