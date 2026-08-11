// lib/core/theme/app_colors/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Core Palette ────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6B4C9A); // Royal Purple (Brand)
  static const Color secondary = Color(0xFFE67E22); // Warm Amber Orange
  static const Color accent = Color(0xFFF39C12); // Golden Amber Accent
  static const Color tertiaryColor = Color(0xFFF5F6FA); // Light Background
  static const Color tetraColor = Color(0xFFD35400); // Rich Terracotta
  static const Color pentaColor = Color(0xFF8E44AD); // Deep Violet
  static const Color hexaColor = Color(0xFFFFFFFD); // Warm White

  // ─── Gradients ────────────────────────────────────────────────────────────────
  static const Gradient primaryLinerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B4C9A), // Royal Purple
      Color(0xFF8E44AD), // Deep Violet
    ],
  );

  static const Gradient scaffoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x146B4C9A), Color(0xFFF5F6FA), Color(0x0DF39C12)],
  );

  // ─── Text Colors ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textWhite = Colors.white;
  static const Color textPurple = Color(0xFF4F6EF7);

  // ─── Background Colors ────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F6FA);
  static const Color light = Color(0xFFFFFFFD);
  static const Color dark = Color(0xFF111827);
  static const Color primaryBackground = Color(0xFFF5F6FA);
  static const Color lightContainer = Color(0xFFEEF2FF);
  static Color darkContainer = textWhite.withValues(alpha: 0.1);

  // ─── Button Colors ────────────────────────────────────────────────────────────
  static const Color buttonPrimary = Color(0xFF4F6EF7);
  static const Color buttonSecondary = Color(0xFFE67E22);
  static const Color buttonDisabled = Color(0xFFD1D5DB);
  static const LinearGradient buttonActiveLinearGradientColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4F6EF7), // Primary Blue
      Color(0xFF3D5AF1), // Darker Blue
    ],
  );
  static const LinearGradient buttonInActiveLinearGradientColor =
      LinearGradient(colors: [Colors.grey, Colors.grey]);

  // ─── Border Colors ────────────────────────────────────────────────────────────
  static const Color borderPrimary = Color(0xFF808080);
  static const Color borderSecondary = Color(0xFFE5E7EB);

  // ─── Semantic Colors ──────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF4F6EF7);

  // ─── Neutral Shades ───────────────────────────────────────────────────────────
  static const Color fullBlack = Color(0xFF000000);
  static const Color black = Color(0xFF111827);
  static const Color darkerGrey = Color(0xFF374151);
  static const Color darkGrey = Color(0xFF4B5563);
  static const Color grey = Color(0xFFE5E7EB);
  static const Color softGrey = Color(0xFFF3F4F6);
  static const Color lightGrey = Color(0xFFF5F6FA);
  static const Color white = Color(0xFFFFFFFF);

  // ─── Subject Colors (canonical — same everywhere) ─────────────────────────────
  static const Color physicsColor = Color(0xFF9C27B0);  // Purple
  static const Color chemistryColor = Color(0xFF009688); // Teal
  static const Color biologyColor = Color(0xFFFF9800);   // Orange
  static const Color mathColor = Color(0xFF2196F3);      // Blue
  static const Color englishColor = Color(0xFF3F51B5);   // Indigo

  // Keep legacy names as aliases so existing code doesn't break
  static const Color physicsPurple = physicsColor;
  static const Color chemistryGreen = chemistryColor;
  static const Color biologyOrange = biologyColor;
  static const Color mathPurple = mathColor;
  static const Color englishTerracotta = englishColor;

  // ─── Progress & Score Colors ──────────────────────────────────────────────────
  static const Color highScore = Color(0xFF22C55E);
  static const Color mediumScore = Color(0xFFF59E0B);
  static const Color lowScore = Color(0xFFEF4444);

  // ─── Quiz & Test Colors ───────────────────────────────────────────────────────
  static const Color correctAnswer = Color(0xFF22C55E);
  static const Color incorrectAnswer = Color(0xFFEF4444);
  static const Color neutralAnswer = Color(0xFFBDC3C7);

  // ─── Test Type Colors ─────────────────────────────────────────────────────────
  static const Color weeklyTest = Color(0xFF4F6EF7);    // Primary Blue
  static const Color monthlyTest = Color(0xFF8B5CF6);   // Violet
  static const Color fullLengthTest = Color(0xFF14B8A6); // Teal
  static const Color practiceTest = Color(0xFF22C55E);  // Success Green
  static const Color customTest = Color(0xFFF97316);    // Orange

  // ─── Status Colors ────────────────────────────────────────────────────────────
  static const Color locked = Color(0xFFEF4444);
  static const Color completed = Color(0xFFF59E0B);
  static const Color available = Color(0xFF22C55E);

  // ─── Card & Surface Colors ────────────────────────────────────────────────────
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF5F6FA);
  static const Color cardBorder = Color(0xFFE5E7EB);
}
