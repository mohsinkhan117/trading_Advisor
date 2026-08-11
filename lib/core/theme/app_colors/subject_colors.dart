// lib/core/theme/app_colors/subject_colors.dart

import 'package:flutter/material.dart';

/// A class containing predefined solid colors for different subjects
/// Use these colors to maintain consistent visual identity across the app
class SubjectColors {
  // Private constructor to prevent instantiation
  SubjectColors._();

  /// List of modern vibrant colors for subjects (2024 trending palette)
  static const List<Color> colors = [
    Color(0xFF7C3AED), // Electric Violet - Programming/Computer Science
    Color(0xFFFF6B9D), // Hot Pink - Design/Arts
    Color(0xFF8B5FBF), // Royal Purple - Business/Management
    Color(0xFFFFB547), // Golden Orange - Marketing/Communication
    Color(0xFF00D9A3), // Mint Green - Science/Biology
    Color(0xFF4F8FFF), // Bright Blue - Mathematics
    Color(0xFFFF5757), // Coral Red - Physics
    Color(0xFF00BFA5), // Turquoise - Chemistry
    Color(0xFFFF8A34), // Tangerine - English/Literature
    Color(0xFF00C9FF), // Sky Blue - History/Social Studies
    Color(0xFFBB6BD9), // Lavender - Music/Arts
    Color(0xFF7FE34B), // Fresh Lime - Environmental Studies
    Color(0xFFFF4E88), // Watermelon - Health/Fitness
    Color(0xFF5B9FFF), // Ocean Blue - Geography
    Color(0xFFFFD54F), // Sunflower - Economics
    Color(0xFF26C6DA), // Aqua - Technology
  ];

  /// Alternative: Pastel colors for a softer, modern look
  static const List<Color> pastelColors = [
    Color(0xFFB8A7F9), // Soft Violet
    Color(0xFFFFB3D1), // Baby Pink
    Color(0xFFC9ADFF), // Pale Purple
    Color(0xFFFFD699), // Peach Cream
    Color(0xFF99F5E0), // Mint Cream
    Color(0xFFA5C9FF), // Powder Blue
    Color(0xFFFFB3B3), // Rose Quartz
    Color(0xFF99EFE0), // Pastel Turquoise
    Color(0xFFFFCC99), // Apricot
    Color(0xFF99E6FF), // Baby Blue
    Color(0xFFDEB8F5), // Lilac
    Color(0xFFCCF299), // Pale Lime
    Color(0xFFFFB8D1), // Cotton Candy
    Color(0xFFADD8FF), // Cloud Blue
    Color(0xFFFFE699), // Buttercream
    Color(0xFF99E0EB), // Ice Blue
  ];

  /// Dark vibrant colors for better contrast and modern UI
  static const List<Color> darkColors = [
    Color(0xFF5B21B6), // Deep Violet
    Color(0xFFD91A5B), // Magenta
    Color(0xFF6B1FA8), // Grape Purple
    Color(0xFFE07B00), // Dark Orange
    Color(0xFF00A87E), // Forest Green
    Color(0xFF2563EB), // Deep Blue
    Color(0xFFDC2626), // Crimson
    Color(0xFF008B7A), // Deep Teal
    Color(0xFFD65A00), // Burnt Orange
    Color(0xFF0284C7), // Navy Blue
    Color(0xFF9333EA), // Purple Haze
    Color(0xFF5FA305), // Olive Green
    Color(0xFFDB2777), // Ruby
    Color(0xFF1E40AF), // Sapphire
    Color(0xFFCA8A04), // Gold
    Color(0xFF0891B2), // Deep Cyan
  ];

  /// Get a color by index (cycles through if index exceeds list length)
  static Color getColorByIndex(
    int index, {
    bool usePastel = false,
    bool useDark = false,
  }) {
    final colorList = usePastel
        ? pastelColors
        : (useDark ? darkColors : colors);
    return colorList[index % colorList.length];
  }

  /// Get a color by subject name (uses hash for consistent color assignment)
  static Color getColorBySubject(
    String subject, {
    bool usePastel = false,
    bool useDark = false,
  }) {
    final colorList = usePastel
        ? pastelColors
        : (useDark ? darkColors : colors);
    final hash = subject.toLowerCase().hashCode;
    return colorList[hash.abs() % colorList.length];
  }

  /// Subject-specific modern color mappings (2024 palette)
  static const Map<String, Color> subjectColorMap = {
    'programming': Color(0xFF7C3AED), // Electric Violet
    'computer science': Color(0xFF7C3AED),
    'design': Color(0xFFFF6B9D), // Hot Pink
    'arts': Color(0xFFBB6BD9), // Lavender
    'business': Color(0xFF8B5FBF), // Royal Purple
    'management': Color(0xFF8B5FBF),
    'marketing': Color(0xFFFFB547), // Golden Orange
    'science': Color(0xFF00D9A3), // Mint Green
    'biology': Color(0xFF00D9A3),
    'mathematics': Color(0xFF4F8FFF), // Bright Blue
    'math': Color(0xFF4F8FFF),
    'physics': Color(0xFFFF5757), // Coral Red
    'chemistry': Color(0xFF00BFA5), // Turquoise
    'english': Color(0xFFFF8A34), // Tangerine
    'literature': Color(0xFFFF8A34),
    'history': Color(0xFF00C9FF), // Sky Blue
    'music': Color(0xFFBB6BD9), // Lavender
    'environment': Color(0xFF7FE34B), // Fresh Lime
    'health': Color(0xFFFF4E88), // Watermelon
    'fitness': Color(0xFFFF4E88),
    'geography': Color(0xFF5B9FFF), // Ocean Blue
    'economics': Color(0xFFFFD54F), // Sunflower
    'technology': Color(0xFF26C6DA), // Aqua
  };

  /// Get color by specific subject name with fallback
  static Color getSubjectColor(String subject, {Color? fallback}) {
    final normalizedSubject = subject.toLowerCase().trim();
    return subjectColorMap[normalizedSubject] ??
        fallback ??
        getColorBySubject(subject);
  }
}
