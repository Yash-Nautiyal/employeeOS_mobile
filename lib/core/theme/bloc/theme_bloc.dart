import 'package:bloc/bloc.dart';
import 'package:employeeos/core/theme/app_pallete.dart' show Presets;
import 'package:employeeos/core/theme/app_theme.dart' show buildTheme;
import 'package:employeeos/core/theme/app_typography.dart'
    show AppTypography, Fonts;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;

  ThemeBloc._(this._prefs, ThemeState initial) : super(initial) {
    on<ToggleBrightnessEvent>(_onToggleBrightness);
    on<ChangePresetEvent>(_onChangePreset);
    on<ChangeFontEvent>(_onChangeFont);
  }

  static Future<ThemeBloc> create() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPreset =
        Presets.values[prefs.getInt('theme_preset') ?? Presets.green.index];
    final savedIsDark = prefs.getBool('theme_isDark') ?? false;
    final savedFont =
        Fonts.values[prefs.getInt('theme_font') ?? Fonts.publicSans.index];
    final brightness = savedIsDark ? Brightness.dark : Brightness.light;
    final theme = buildTheme(
      preset: savedPreset,
      brightness: brightness,
      font: savedFont,
    );

    return ThemeBloc._(
      prefs,
      ThemeState(
        themeData: theme,
        preset: savedPreset,
        brightness: brightness,
        font: savedFont,
      ),
    );
  }

  void _onToggleBrightness(
    ToggleBrightnessEvent event,
    Emitter<ThemeState> emit,
  ) {
    final newBrightness = state.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    _prefs.setBool('theme_isDark', newBrightness == Brightness.dark);
    final newTheme = buildTheme(
      preset: state.preset,
      brightness: newBrightness,
    );
    emit(state.copyWith(themeData: newTheme, brightness: newBrightness));
  }

  void _onChangePreset(ChangePresetEvent event, Emitter<ThemeState> emit) {
    _prefs.setInt('theme_preset', event.preset.index);
    final newTheme = buildTheme(
      preset: event.preset,
      brightness: state.brightness,
    );
    emit(state.copyWith(themeData: newTheme, preset: event.preset));
  }

  void _onChangeFont(ChangeFontEvent event, Emitter<ThemeState> emit) {
    _prefs.setInt('theme_font', event.font.index);
    AppTypography.setPrimaryFont(event.font);

    final newTheme = buildTheme(
      preset: state.preset,
      brightness: state.brightness,
      font: event.font,
    );

    emit(state.copyWith(themeData: newTheme, font: event.font));
  }
}
