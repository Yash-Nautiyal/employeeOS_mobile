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
  final bool isDark = brightness == Brightness.dark;

  final colorscheme = AppPallete.primaryPresets.entries
      .firstWhere((entry) => entry.key == preset)
      .value;
  final secondaryScheme = AppPallete.secondaryPresets.entries
      .firstWhere((entry) => entry.key == preset)
      .value;

  final baseTextTheme = TextTheme(
    displayLarge: AppTypography.displayLarge.copyWith(
      color: isDark ? AppPallete.white : AppPallete.grey800,
    ),
    displayMedium: AppTypography.displayMedium.copyWith(
      color: isDark ? AppPallete.white : AppPallete.grey800,
    ),
    displaySmall: AppTypography.displaySmall.copyWith(
      color: isDark ? AppPallete.white : AppPallete.grey800,
    ),
    titleLarge: AppTypography.titleLarge.copyWith(
      color: isDark ? AppPallete.white : AppPallete.grey800,
    ),
    titleMedium: AppTypography.titleMedium.copyWith(
      color: isDark ? AppPallete.white : AppPallete.grey800,
    ),
    bodyLarge: AppTypography.bodyLarge.copyWith(
      color: isDark ? AppPallete.white : AppPallete.grey800,
    ),
    bodyMedium: AppTypography.bodyMedium.copyWith(
      color: isDark ? AppPallete.grey500 : AppPallete.grey600,
    ),
    bodySmall: AppTypography.bodySmall.copyWith(
      color: isDark ? AppPallete.grey600 : AppPallete.grey500,
    ),
    labelLarge: AppTypography.buttonLarge.copyWith(
      color: isDark ? AppPallete.white : AppPallete.grey800,
    ),
    labelMedium: AppTypography.buttonMedium.copyWith(
      color: isDark ? AppPallete.white : AppPallete.grey800,
    ),
    labelSmall: AppTypography.buttonSmall.copyWith(
      color: isDark ? AppPallete.white : AppPallete.grey800,
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
    primaryColorDark: colorscheme["Dark"],
    primaryColorLight: colorscheme["Light"],
    scaffoldBackgroundColor: isDark ? AppPallete.grey900 : AppPallete.white,
    dividerColor: isDark ? AppPallete.grey600 : AppPallete.grey500,
    disabledColor: isDark ? AppPallete.grey500 : AppPallete.grey600,
    cardColor: isDark ? AppPallete.grey800 : AppPallete.white,
    shadowColor: isDark
        ? AppPallete.black.withOpacity(.09)
        // ignore: deprecated_member_use
        : AppPallete.black.withOpacity(.08),
    indicatorColor: AppPallete.infoMain,
    hoverColor:
        isDark ? const Color.fromARGB(255, 33, 41, 49) : AppPallete.grey300,
    //-------------------------------------------------------------------------------------

    //Text Theme
    fontFamily: AppTypography.primaryFont,
    textTheme: googleTextTheme,
    //-------------------------------------------------------------------------------------

    //AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: isDark ? AppPallete.white : AppPallete.grey800,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    ),
    colorScheme: isDark
        ? ColorScheme.dark(
            //--------Primary Colors--------
            primary: colorscheme["Main"],
            primaryFixed: colorscheme["Lighter"],
            primaryFixedDim: colorscheme["Light"],
            primaryContainer: colorscheme["Lighter"],
            onPrimaryContainer: colorscheme['Darker']!,
            onPrimary: AppPallete.white,

            //--------Secondary Colors--------
            secondary: secondaryScheme["Main"],
            secondaryFixed: secondaryScheme["Lighter"],
            secondaryFixedDim: secondaryScheme["Darker"],
            secondaryContainer: secondaryScheme["Lighter"],
            onSecondaryContainer: secondaryScheme['Darker']!,
            onSecondary: AppPallete.white,

            //--------Error Colors--------
            error: AppPallete.errorMain,
            errorContainer: AppPallete.errorDark,
            onError: AppPallete.white,

            //--------Surface Colors--------
            surface: AppPallete.grey800,
            surfaceDim: AppPallete.containerDark,
            surfaceBright: AppPallete.grey700,
            surfaceContainer: AppPallete.containerColor,
            surfaceContainerLow: AppPallete.containerColor,
            surfaceContainerHigh: AppPallete.grey700,

            //--------Tertiary Colors--------
            tertiary: AppPallete.infoMain,
            onTertiary: AppPallete.white,

            // Text / icon on surfaces
            onSurface: AppPallete.white,
            onSurfaceVariant: AppPallete.grey400,

            // Borders
            outline: AppPallete.grey600,
            outlineVariant: AppPallete.grey700,

            // Misc
            shadow: AppPallete.black,
            scrim: AppPallete.black,
            inverseSurface: AppPallete.grey100,
            onInverseSurface: AppPallete.grey800,
            inversePrimary: colorscheme['Dark']!,
          )
        : ColorScheme.light(
            //--------Primary Colors--------
            primary: colorscheme["Main"],
            primaryFixed: colorscheme["Dark"],
            primaryFixedDim: colorscheme["Darker"],
            primaryContainer: colorscheme["Lighter"],
            onPrimaryContainer: colorscheme['Darker']!,
            onPrimary: AppPallete.white,

            //--------Secondary Colors--------
            secondary: secondaryScheme["Main"],
            secondaryFixed: secondaryScheme['Lighter']!,
            secondaryFixedDim: secondaryScheme["Light"],
            secondaryContainer: secondaryScheme["Dark"],
            onSecondaryContainer: secondaryScheme['Darker']!,
            onSecondary: AppPallete.white,

            //--------Error Colors--------
            error: AppPallete.errorMain,
            errorContainer: AppPallete.errorLight,

            //--------Tertiary Colors--------
            tertiary: AppPallete.infoMain,
            onTertiary: AppPallete.white,

            // Text / icon on surfaces
            onSurface: AppPallete.grey900,
            onSurfaceVariant: AppPallete.grey600,

            //--------Surface Colors--------
            surface: AppPallete.grey200,
            surfaceDim: AppPallete.grey100,
            surfaceBright: AppPallete.white,
            surfaceContainer: AppPallete.grey300,
            surfaceContainerLow: AppPallete.grey50,
            surfaceContainerHigh: AppPallete.grey300,
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
              color: isDark ? AppPallete.grey600 : AppPallete.grey300,
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
          isDark ? AppPallete.white : AppPallete.grey800,
        ),
        foregroundColor: WidgetStatePropertyAll(
          isDark ? AppPallete.grey800 : AppPallete.white,
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
            ? isDark
                ? AppPallete.grey800
                : AppPallete.white
            : isDark
                ? AppPallete.white
                : AppPallete.grey800,
      ),
      dayPeriodColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? isDark
                ? AppPallete.white
                : AppPallete.grey800
            : isDark
                ? AppPallete.grey800
                : AppPallete.white,
      ),
    ),
    //-------------------------------------------------------------------------------------

    //DatePicker Theme
    datePickerTheme: DatePickerThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
          isDark ? AppPallete.white : AppPallete.grey800,
        ),
        foregroundColor: WidgetStatePropertyAll(
          isDark ? AppPallete.grey800 : AppPallete.white,
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
        isDark ? AppPallete.black : AppPallete.white,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStatePropertyAll(
        isDark ? AppPallete.white : AppPallete.grey400,
      ),
    ),
    //-------------------------------------------------------------------------------------

    //Tab Bar Theme
    tabBarTheme: TabBarTheme(
      labelStyle: AppTypography.buttonLarge.copyWith(
        color: isDark ? AppPallete.white : AppPallete.grey800,
      ),
      unselectedLabelColor: isDark ? AppPallete.grey500 : AppPallete.grey600,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: isDark ? AppPallete.white : AppPallete.grey800,
        ),
        insets: const EdgeInsets.symmetric(horizontal: 4),
      ),
    ),
  );
}
