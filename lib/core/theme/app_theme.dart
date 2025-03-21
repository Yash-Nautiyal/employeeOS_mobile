import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppPallete.primaryMain,
    scaffoldBackgroundColor: AppPallete.white,
    dividerColor: AppPallete.grey300,
    fontFamily: AppTypography.primaryFont,
    textTheme: TextTheme(
      displayLarge:
          AppTypography.headingLarge.copyWith(color: AppPallete.grey800),
      displayMedium:
          AppTypography.headingMedium.copyWith(color: AppPallete.grey800),
      displaySmall:
          AppTypography.headingSmall.copyWith(color: AppPallete.grey800),
      titleLarge:
          AppTypography.subtitleLarge.copyWith(color: AppPallete.grey800),
      titleMedium:
          AppTypography.subtitleMedium.copyWith(color: AppPallete.grey800),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppPallete.grey800),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppPallete.grey600),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppPallete.grey500),
      labelLarge: AppTypography.button.copyWith(color: AppPallete.grey800),
    ),
    cardColor: AppPallete.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.white,
      iconTheme: IconThemeData(color: AppPallete.grey800),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppPallete.primaryMain,
      primaryFixedDim: AppPallete.primaryLight,
      primaryContainer: AppPallete.primaryLighter,
      secondary: AppPallete.secondaryMain,
      secondaryFixedDim: AppPallete.secondaryLight,
      secondaryContainer: AppPallete.secondaryLighter,
      error: AppPallete.errorMain,
      errorContainer: AppPallete.errorLighter,
      surface: AppPallete.white,
    ),
    shadowColor: AppPallete.black.withOpacity(0.2),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            side: BorderSide(color: AppPallete.grey300, width: 1),
          ),
        ),
      ),
    ),
  );

// Theme Data for Dark Mode
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppPallete.primaryDark,
    scaffoldBackgroundColor: AppPallete.grey900,
    dividerColor: AppPallete.grey700,
    fontFamily: AppTypography.primaryFont,
    textTheme: TextTheme(
      displayLarge:
          AppTypography.headingLarge.copyWith(color: AppPallete.white),
      displayMedium:
          AppTypography.headingMedium.copyWith(color: AppPallete.white),
      displaySmall:
          AppTypography.headingSmall.copyWith(color: AppPallete.white),
      titleLarge: AppTypography.subtitleLarge.copyWith(color: AppPallete.white),
      titleMedium:
          AppTypography.subtitleMedium.copyWith(color: AppPallete.white),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppPallete.white),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppPallete.grey500),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppPallete.grey600),
      labelLarge: AppTypography.button.copyWith(color: AppPallete.white),
    ),
    cardColor: AppPallete.grey800,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.grey900,
      iconTheme: IconThemeData(color: AppPallete.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppPallete.primaryDark,
      primaryFixedDim: AppPallete.primaryDarker,
      primaryContainer: AppPallete.primaryLighter,
      secondary: AppPallete.secondaryDark,
      secondaryFixedDim: AppPallete.secondaryDarker,
      secondaryContainer: AppPallete.secondaryLighter,
      error: AppPallete.errorDark,
      errorContainer: AppPallete.errorLighter,
      surface: AppPallete.grey800,
    ),
    shadowColor: AppPallete.black.withOpacity(0.1),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            side: BorderSide(color: AppPallete.grey300, width: 1),
          ),
        ),
      ),
    ),
  );
}
