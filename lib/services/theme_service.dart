// lib/services/theme_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static const String _system = 'system';
  static const String _light = 'light';
  static const String _dark = 'dark';

  Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? _system;
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  // Вспомогательные методы для удобства
  bool isSystem(String mode) => mode == _system;
  bool isLight(String mode) => mode == _light;
  bool isDark(String mode) => mode == _dark;
}
