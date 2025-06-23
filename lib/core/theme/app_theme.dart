import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppPallete.primaryMain,
    scaffoldBackgroundColor: AppPallete.white,
    dividerColor: AppPallete.grey500,
    disabledColor: AppPallete.grey600,
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
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppPallete.grey800),
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppPallete.primaryMain,
      primaryFixedDim: AppPallete.primaryLight,
      primaryContainer: AppPallete.primaryDark,
      secondary: AppPallete.secondaryMain,
      secondaryFixedDim: AppPallete.secondaryLight,
      secondaryContainer: AppPallete.secondaryDark,
      error: AppPallete.errorDark,
      errorContainer: AppPallete.errorLight,
      surface: AppPallete.grey200,
      tertiary: AppPallete.grey900,
      surfaceContainer: AppPallete.grey300,
      surfaceDim: AppPallete.grey300,
    ),
    shadowColor: AppPallete.black.withOpacity(0.5),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppPallete.grey500),
        borderRadius: BorderRadius.circular(7),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
      ),
    ),
    hoverColor: AppPallete.grey300,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            side: BorderSide(color: AppPallete.grey400, width: 1),
          ),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: AppPallete.grey500, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(5)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      dividerColor: AppPallete.grey500,
      dayStyle: AppTypography.bodyMedium,
      headerHeadlineStyle: AppTypography.headingMedium,
      yearStyle: AppTypography.bodyMedium,
      weekdayStyle: AppTypography.bodyMedium,
      confirmButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        backgroundColor: const WidgetStatePropertyAll(AppPallete.grey800),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.white),
      ),
      cancelButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.grey500),
      ),
    ),
    switchTheme: const SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(AppPallete.white),
      trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStatePropertyAll(AppPallete.grey400),
    ),
  );

// Theme Data for Dark Mode
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppPallete.primaryMain,
    scaffoldBackgroundColor: AppPallete.grey900,
    dividerColor: AppPallete.grey600,
    disabledColor: AppPallete.grey500,
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
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppPallete.white),
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppPallete.primaryDark,
      primaryFixedDim: AppPallete.primaryLight,
      primaryContainer: AppPallete.primaryLighter,
      secondary: AppPallete.secondaryDark,
      secondaryFixedDim: AppPallete.secondaryDarker,
      secondaryContainer: AppPallete.secondaryLighter,
      error: AppPallete.errorLight,
      errorContainer: AppPallete.errorMain,
      surface: AppPallete.grey800,
      tertiary: AppPallete.white,
      surfaceContainer: AppPallete.containerColor,
      surfaceDim: AppPallete.grey700,
    ),
    shadowColor: AppPallete.containerColor,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppPallete.grey500),
        borderRadius: BorderRadius.circular(7),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
      ),
    ),
    hoverColor: const Color.fromARGB(255, 33, 41, 49),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            side: BorderSide(color: AppPallete.grey600, width: 1.5),
          ),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: AppPallete.grey500, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(5)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      dividerColor: AppPallete.grey500,
      dayStyle: AppTypography.bodyMedium,
      headerHeadlineStyle: AppTypography.headingMedium,
      yearStyle: AppTypography.bodyMedium,
      weekdayStyle: AppTypography.bodyMedium,
      confirmButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        backgroundColor: const WidgetStatePropertyAll(AppPallete.white),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.grey800),
      ),
      cancelButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.grey500),
      ),
    ),
    switchTheme: const SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(AppPallete.black),
      trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStatePropertyAll(AppPallete.white),
    ),
  );
}
