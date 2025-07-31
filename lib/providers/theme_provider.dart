import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // ALTERAÇÃO AQUI: removido o sublinhado para tornar a variável pública
  static const String themePrefKey = 'theme_mode';
  ThemeMode _themeMode;

  ThemeProvider({required ThemeMode initialTheme}) : _themeMode = initialTheme;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    // 👇 ALTERAÇÃO AQUI: usando a nova variável pública
    await prefs.setString(themePrefKey, themeMode.name);
  }
  
  // Este método pode ser removido, pois a lógica de troca está no diálogo
  void toggleTheme() {}
}