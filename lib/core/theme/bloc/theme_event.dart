// theme_event.dart
part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class ToggleBrightnessEvent extends ThemeEvent {}

class ChangePresetEvent extends ThemeEvent {
  final Presets preset;
  ChangePresetEvent(this.preset);
}

class ChangeFontEvent extends ThemeEvent {
  final Fonts font;
  ChangeFontEvent(this.font);
}
