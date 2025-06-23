import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _themeKey = 'is_dark_mode';

  ThemeBloc() : super(const ThemeState(isDarkMode: false)) {
    // 1️⃣ Register toggle handler
    on<ToggleThemeEvent>(_onToggleTheme);
    // 2️⃣ Load the saved theme right away
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    // ignore: invalid_use_of_visible_for_testing_member
    emit(ThemeState(isDarkMode: isDark));
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent _,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final newIsDark = !state.isDarkMode;
    await prefs.setBool(_themeKey, newIsDark);
    emit(ThemeState(isDarkMode: newIsDark));
  }
}
