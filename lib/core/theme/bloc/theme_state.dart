// theme_state.dart
part of 'theme_bloc.dart';

class ThemeState {
  final ThemeData themeData;
  final Presets preset;
  final Brightness brightness;
  final Fonts font;

  const ThemeState({
    required this.themeData,
    required this.preset,
    required this.brightness,
    required this.font,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    Presets? preset,
    Brightness? brightness,
    Fonts? font,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      preset: preset ?? this.preset,
      brightness: brightness ?? this.brightness,
      font: font ?? this.font,
    );
  }
}
