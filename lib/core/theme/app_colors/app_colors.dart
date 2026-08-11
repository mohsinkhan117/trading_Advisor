// lib/core/theme/app_colors/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Core Palette (brand) ──────────────────────────────────────────────────
  // Primary mirrors the bullish candle color — this is a trading advisory
  // app, so "growth green" is the brand color, not just a chart color.
  static const Color primary = Color(0xFF089981); // Bullish Green (Brand)
  static const Color secondary = Color(0xFF1E293B); // Terminal Slate Navy
  static const Color accent = Color(0xFFF0B90B); // Gold Accent (highlights)
  static const Color tertiaryColor = Color(0xFFF5F6FA); // Light Background

  // ─── Gradients ────────────────────────────────────────────────────────────────
  static const Gradient primaryLinerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF089981), // Bullish Green
      Color(0xFF06705F), // Deep Green
    ],
  );

  static const Gradient scaffoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x14089981), Color(0xFFF5F6FA), Color(0x0DF0B90B)],
  );

  // ─── Text Colors ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textWhite = Colors.white;

  // ─── Background Colors ────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F6FA);
  static const Color light = Color(0xFFFFFFFD);
  static const Color dark = Color(0xFF111827);
  static const Color lightContainer = Color(0xFFEEF2FF);
  static Color darkContainer = textWhite.withValues(alpha: 0.1);

  // Trading-terminal dark theme surfaces (TradingView-style dark UI)
  static const Color darkBackground = Color(0xFF131722);
  static const Color darkSurface = Color(0xFF1E222D);
  static const Color darkSurfaceBorder = Color(0xFF2A2E39);

  // ─── Button Colors ────────────────────────────────────────────────────────────
  static const Color buttonPrimary = Color(0xFF089981);
  static const Color buttonSecondary = Color(0xFFF0B90B);
  static const Color buttonDisabled = Color(0xFFD1D5DB);
  static const LinearGradient buttonActiveLinearGradientColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF089981), // Bullish Green
      Color(0xFF06705F), // Deep Green
    ],
  );
  static const LinearGradient buttonInActiveLinearGradientColor =
      LinearGradient(colors: [Colors.grey, Colors.grey]);

  // ─── Border Colors ────────────────────────────────────────────────────────────
  static const Color borderPrimary = Color(0xFF808080);
  static const Color borderSecondary = Color(0xFFE5E7EB);

  // ─── Semantic Colors ──────────────────────────────────────────────────────────
  // Aliased to the candle colors so success/error and bullish/bearish never
  // drift apart across the app.
  static const Color error = bearish;
  static const Color success = bullish;
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Neutral Shades ───────────────────────────────────────────────────────────
  static const Color fullBlack = Color(0xFF000000);
  static const Color black = Color(0xFF111827);
  static const Color darkerGrey = Color(0xFF374151);
  static const Color darkGrey = Color(0xFF4B5563);
  static const Color grey = Color(0xFFE5E7EB);
  static const Color softGrey = Color(0xFFF3F4F6);
  static const Color lightGrey = Color(0xFFF5F6FA);
  static const Color white = Color(0xFFFFFFFF);

  // ─── Candle / Market Colors ─────────────────────────────────────────────────
  // Standard bullish/bearish candlestick colors, shared by charts, price
  // tickers, P&L text, and stat cards throughout the app.
  static const Color bullish = Color(0xFF089981); // Price up / buy
  static const Color bearish = Color(0xFFF23645); // Price down / sell
  static const Color neutral = Color(0xFF787B86); // Unchanged / doji

  // Low-opacity tints for card/row backgrounds that indicate gain or loss.
  static const Color bullishSurface = Color(0x1A089981);
  static const Color bearishSurface = Color(0x1AF23645);
  static const Color neutralSurface = Color(0x1A787B86);

  // Matching borders for the tinted surfaces above.
  static const Color bullishBorder = Color(0x33089981);
  static const Color bearishBorder = Color(0x33F23645);
  static const Color neutralBorder = Color(0x33787B86);
  // ─── Home / Recommendation View ──────────────────────────────────────
  static const Color iconAvatarBackground = lightContainer;
  static const Color confidenceBadgeBackground = Color(0xFFEFF6FF); // info tint
  static const Color confidenceBadgeText = info;

  /// Returns [bullish], [bearish], or [neutral] for a given price/value
  /// change — the single source of truth for "is this gain or loss green".
  static Color priceChangeColor(num change) {
    if (change > 0) return bullish;
    if (change < 0) return bearish;
    return neutral;
  }

  /// Tinted surface counterpart to [priceChangeColor], for card backgrounds.
  static Color priceChangeSurface(num change) {
    if (change > 0) return bullishSurface;
    if (change < 0) return bearishSurface;
    return neutralSurface;
  }

  /// Tinted border counterpart to [priceChangeColor], for card borders.
  static Color priceChangeBorder(num change) {
    if (change > 0) return bullishBorder;
    if (change < 0) return bearishBorder;
    return neutralBorder;
  }

  // ─── Card & Surface Colors ────────────────────────────────────────────────────
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF5F6FA);
  static const Color cardBorder = Color(0xFFE5E7EB);
}
