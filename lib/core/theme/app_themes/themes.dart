// lib/core/theme/app_themes/themes.dart

import 'package:flutter/material.dart';
import 'package:trading_advisor/core/constants/sizes/sizes.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';
import 'package:trading_advisor/core/theme/custom_theme/appbar_theme.dart';
import 'package:trading_advisor/core/theme/custom_theme/bottom_sheet_theme.dart';
import 'package:trading_advisor/core/theme/custom_theme/checkbox_theme.dart';
import 'package:trading_advisor/core/theme/custom_theme/chip_theme.dart';
import 'package:trading_advisor/core/theme/custom_theme/elevated_button_theme.dart';
import 'package:trading_advisor/core/theme/custom_theme/outlined_button_theme.dart';
import 'package:trading_advisor/core/theme/custom_theme/text_field_theme.dart';
import 'package:trading_advisor/core/theme/custom_theme/text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    textTheme: AppTextTheme.lightTextTheme,
    chipTheme: AppChipTheme.lightChipTheme,
    scaffoldBackgroundColor: AppColors.white,
    appBarTheme: AppAppBarTheme.lightAppBarTheme,
    checkboxTheme: AppCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: AppTextFormFieldTheme.lightInputDecorationTheme,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiaryColor,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.black,
      surface: AppColors.white,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardSurface,
      elevation: AppSizes.cardElevation,
      margin: EdgeInsets.zero,
      shadowColor: AppColors.softGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.darkGrey,
      indicatorColor: AppColors.primary,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: AppTextTheme.darkTextTheme,
    appBarTheme: AppAppBarTheme.darkAppBarTheme,
    checkboxTheme: AppCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: AppBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: AppTextFormFieldTheme.darkInputDecorationTheme,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.black,
      surface: AppColors.darkSurface,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: AppSizes.cardElevation,
      margin: EdgeInsets.zero,
      shadowColor: AppColors.fullBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        side: const BorderSide(color: AppColors.darkSurfaceBorder, width: 1),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.grey,
      indicatorColor: AppColors.primary,
    ),
  );
}
