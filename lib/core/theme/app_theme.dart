import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class AppTheme {
  static ThemeData lightTheme = buildTheme(brightness: Brightness.light);

  // Theme Data for Dark Mode
  static ThemeData darkTheme = buildTheme(brightness: Brightness.dark);
}

ThemeData buildTheme({
  Presets preset = Presets.green,
  Brightness brightness = Brightness.light,
  Fonts font = Fonts.publicSans,
}) {
  final colorscheme = AppPallete.primaryPresets.entries
      .firstWhere((entry) => entry.key == preset)
      .value;

  final baseTextTheme = TextTheme(
    displayLarge: AppTypography.displayLarge.copyWith(
      color:
          brightness == Brightness.dark ? AppPallete.white : AppPallete.grey800,
    ),
    displayMedium: AppTypography.displayMedium.copyWith(
      color:
          brightness == Brightness.dark ? AppPallete.white : AppPallete.grey800,
    ),
    displaySmall: AppTypography.displaySmall.copyWith(
      color:
          brightness == Brightness.dark ? AppPallete.white : AppPallete.grey800,
    ),
    titleLarge: AppTypography.titleLarge.copyWith(
      color:
          brightness == Brightness.dark ? AppPallete.white : AppPallete.grey800,
    ),
    titleMedium: AppTypography.titleMedium.copyWith(
      color:
          brightness == Brightness.dark ? AppPallete.white : AppPallete.grey800,
    ),
    bodyLarge: AppTypography.bodyLarge.copyWith(
      color:
          brightness == Brightness.dark ? AppPallete.white : AppPallete.grey800,
    ),
    bodyMedium: AppTypography.bodyMedium.copyWith(
      color: brightness == Brightness.dark
          ? AppPallete.grey500
          : AppPallete.grey600,
    ),
    bodySmall: AppTypography.bodySmall.copyWith(
      color: brightness == Brightness.dark
          ? AppPallete.grey600
          : AppPallete.grey500,
    ),
    labelLarge: AppTypography.button.copyWith(
      color:
          brightness == Brightness.dark ? AppPallete.white : AppPallete.grey800,
    ),
  );
  final googleTextTheme = GoogleFonts.getTextTheme(
    AppTypography.fontFamily(font),
    baseTextTheme,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    primaryColor: colorscheme["Main"],
    scaffoldBackgroundColor:
        brightness == Brightness.dark ? AppPallete.grey900 : AppPallete.white,
    dividerColor:
        brightness == Brightness.dark ? AppPallete.grey600 : AppPallete.grey500,
    disabledColor:
        brightness == Brightness.dark ? AppPallete.grey500 : AppPallete.grey600,
    cardColor:
        brightness == Brightness.dark ? AppPallete.grey800 : AppPallete.white,
    shadowColor: brightness == Brightness.dark
        ? AppPallete.grey900
        // ignore: deprecated_member_use
        : AppPallete.black.withOpacity(.08),
    indicatorColor: brightness == Brightness.dark
        ? AppPallete.infoDark
        : AppPallete.infoMain,
    hoverColor: brightness == Brightness.dark
        ? const Color.fromARGB(255, 33, 41, 49)
        : AppPallete.grey300,
    //-------------------------------------------------------------------------------------

    //Text Theme
    fontFamily: AppTypography.primaryFont,
    textTheme: googleTextTheme,
    //-------------------------------------------------------------------------------------

    //AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: brightness == Brightness.dark
            ? AppPallete.white
            : AppPallete.grey800,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    ),
    //-------------------------------------------------------------------------------------

    //Color Scheme
    colorScheme: brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: colorscheme["Main"],
            primaryFixedDim: colorscheme["Light"],
            primaryContainer: colorscheme["Lighter"],
            primaryFixed: colorscheme["Lighter"],
            secondary: preset != Presets.purple
                ? AppPallete.secondaryDark
                : AppPallete.primaryDark,
            secondaryFixedDim: preset != Presets.purple
                ? AppPallete.secondaryDarker
                : AppPallete.primaryDarker,
            secondaryContainer: preset != Presets.purple
                ? AppPallete.secondaryLighter
                : AppPallete.primaryLighter,
            error: AppPallete.errorMain,
            errorContainer: AppPallete.errorMain,
            surface: AppPallete.grey800,
            tertiary: AppPallete.white,
            surfaceContainer: AppPallete.containerColor,
            surfaceDim: AppPallete.grey700,
          )
        : ColorScheme.light(
            primary: colorscheme["Main"],
            primaryFixedDim: colorscheme["Dark"],
            primaryContainer: colorscheme["Lighter"],
            primaryFixed: colorscheme["Dark"],
            secondary: preset != Presets.purple
                ? AppPallete.secondaryMain
                : AppPallete.primaryMain,
            secondaryFixedDim: preset != Presets.purple
                ? AppPallete.secondaryLight
                : AppPallete.primaryLight,
            secondaryContainer: preset != Presets.purple
                ? AppPallete.secondaryDark
                : AppPallete.primaryDark,
            error: AppPallete.errorMain,
            errorContainer: AppPallete.errorLight,
            surface: AppPallete.grey200,
            tertiary: AppPallete.grey900,
            surfaceContainer: AppPallete.grey300,
            surfaceDim: AppPallete.grey300,
          ),

    //-------------------------------------------------------------------------------------

    //TextField Theme
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppPallete.grey500),
        borderRadius: BorderRadius.circular(7),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
    ),

    //-------------------------------------------------------------------------------------

    //Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            side: BorderSide(
              color: brightness == Brightness.dark
                  ? AppPallete.grey600
                  : AppPallete.grey300,
              width: 1.3,
            ),
          ),
        ),
      ),
    ),
    //-------------------------------------------------------------------------------------

    //Check Box Theme
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: AppPallete.grey500, width: 1.5),
      checkColor: const WidgetStatePropertyAll(AppPallete.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    //-------------------------------------------------------------------------------------

    //Icon Button Theme
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(24, 24)),
        maximumSize: WidgetStatePropertyAll(Size(35, 35)),
        padding: WidgetStatePropertyAll(EdgeInsets.all(5)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    //-------------------------------------------------------------------------------------

    //TimePicker Theme
    timePickerTheme: TimePickerThemeData(
      confirmButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        backgroundColor: WidgetStatePropertyAll(
          brightness == Brightness.dark ? AppPallete.white : AppPallete.grey800,
        ),
        foregroundColor: WidgetStatePropertyAll(
          brightness == Brightness.dark ? AppPallete.grey800 : AppPallete.white,
        ),
      ),
      cancelButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.grey500),
      ),
      dayPeriodTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? brightness == Brightness.dark
                ? AppPallete.grey800
                : AppPallete.white
            : brightness == Brightness.dark
                ? AppPallete.white
                : AppPallete.grey800,
      ),
      dayPeriodColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? brightness == Brightness.dark
                ? AppPallete.white
                : AppPallete.grey800
            : brightness == Brightness.dark
                ? AppPallete.grey800
                : AppPallete.white,
      ),
    ),
    //-------------------------------------------------------------------------------------

    //DatePicker Theme
    datePickerTheme: DatePickerThemeData(
      dividerColor: AppPallete.grey500,
      dayStyle: AppTypography.bodyMedium,
      headerHeadlineStyle: AppTypography.displayMedium,
      yearStyle: AppTypography.bodyMedium,
      weekdayStyle: AppTypography.bodyMedium,
      confirmButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        backgroundColor: WidgetStatePropertyAll(
          brightness == Brightness.dark ? AppPallete.white : AppPallete.grey800,
        ),
        foregroundColor: WidgetStatePropertyAll(
          brightness == Brightness.dark ? AppPallete.grey800 : AppPallete.white,
        ),
      ),
      cancelButtonStyle: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppPallete.grey500),
      ),
      rangeSelectionBackgroundColor: (colorscheme["Main"] as Color).withOpacity(
        .15,
      ),
      rangePickerShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    //-------------------------------------------------------------------------------------

    //Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(
        brightness == Brightness.dark ? AppPallete.black : AppPallete.white,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStatePropertyAll(
        brightness == Brightness.dark ? AppPallete.white : AppPallete.grey400,
      ),
    ),
    //-------------------------------------------------------------------------------------

    //Tab Bar Theme
    tabBarTheme: TabBarTheme(
      labelStyle: AppTypography.button.copyWith(
        color: brightness == Brightness.dark
            ? AppPallete.white
            : AppPallete.grey800,
      ),
      unselectedLabelColor: brightness == Brightness.dark
          ? AppPallete.grey500
          : AppPallete.grey600,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: brightness == Brightness.dark
              ? AppPallete.white
              : AppPallete.grey800,
        ),
        insets: const EdgeInsets.symmetric(horizontal: 4),
      ),
    ),
  );
}
