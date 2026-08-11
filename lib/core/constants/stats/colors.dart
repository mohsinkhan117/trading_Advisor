// lib/core/constants/stats/colors.dart

import 'package:flutter/material.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';

class StatsColors {
  static Color getSubjectColor(String subject) {
    switch (subject) {
      case 'Physics':
        return AppColors.physicsColor;
      case 'Chemistry':
        return AppColors.chemistryColor;
      case 'Biology':
        return AppColors.biologyColor;
      case 'English':
        return AppColors.englishColor;
      case 'Mathematics':
        return AppColors.mathColor;
      default:
        return AppColors.primary;
    }
  }

  static Color getScoreColor(double percentage) {
    if (percentage >= 80) {
      return AppColors.success;
    } else if (percentage >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
