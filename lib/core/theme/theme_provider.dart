import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeMode _themeMode;
  late double _fontSize;
  late String _quoteDisplayStyle;

  final _settingsBox = Hive.box<String>('app_settings');

  ThemeProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  String get quoteDisplayStyle => _quoteDisplayStyle;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Get device theme
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void _loadSettings() {
    final darkModeValue = _settingsBox.get('dark_mode', defaultValue: 'system');
    _themeMode = _getThemeMode(darkModeValue!);

    _fontSize = double.parse(
      _settingsBox.get('font_size', defaultValue: '16.0')!,
    );

    _quoteDisplayStyle = _settingsBox.get('quote_style', defaultValue: 'Card')!;
  }

  ThemeMode _getThemeMode(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void setDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _settingsBox.put('dark_mode', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    _settingsBox.put('font_size', size.toString());
    notifyListeners();
  }

  void setQuoteStyle(String style) {
    _quoteDisplayStyle = style;
    _settingsBox.put('quote_style', style);
    notifyListeners();
  }
}
