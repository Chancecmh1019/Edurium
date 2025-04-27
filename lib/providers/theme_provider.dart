import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType {
  system,
  light,
  dark,
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  static const String _secondaryColorKey = 'secondary_color';
  static const String _accentColorKey = 'accent_color';
  
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  ThemeType _themeType = ThemeType.system;
  
  // 默認顏色
  static const Color _defaultPrimaryColor = Colors.blue;
  static const Color _defaultSecondaryColor = Colors.blueGrey;
  static const Color _defaultAccentColor = Colors.orange;
  
  Color _primaryColor = _defaultPrimaryColor;
  Color _secondaryColor = _defaultSecondaryColor;
  Color _accentColor = _defaultAccentColor;

  ThemeMode get themeMode => _themeMode;
  ThemeType get themeType => _themeType;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;

  ThemeProvider() {
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    // 載入主題模式
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      if (savedTheme == 'ThemeMode.light') {
        _themeMode = ThemeMode.light;
        _themeType = ThemeType.light;
      } else if (savedTheme == 'ThemeMode.dark') {
        _themeMode = ThemeMode.dark;
        _themeType = ThemeType.dark;
      } else {
        _themeMode = ThemeMode.system;
        _themeType = ThemeType.system;
      }
    }
    
    // 載入顏色
    final primaryColorValue = _prefs.getInt(_primaryColorKey);
    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    }
    
    final secondaryColorValue = _prefs.getInt(_secondaryColorKey);
    if (secondaryColorValue != null) {
      _secondaryColor = Color(secondaryColorValue);
    }
    
    final accentColorValue = _prefs.getInt(_accentColorKey);
    if (accentColorValue != null) {
      _accentColor = Color(accentColorValue);
    }
    
    notifyListeners();
  }

  bool isDarkMode(BuildContext context) {
    return _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  // 設置主題
  Future<void> setTheme(ThemeType themeType) async {
    _themeType = themeType;
    switch (themeType) {
      case ThemeType.light:
        _themeMode = ThemeMode.light;
        await _prefs.setString(_themeKey, 'ThemeMode.light');
        break;
      case ThemeType.dark:
        _themeMode = ThemeMode.dark;
        await _prefs.setString(_themeKey, 'ThemeMode.dark');
        break;
      case ThemeType.system:
        _themeMode = ThemeMode.system;
        await _prefs.setString(_themeKey, 'ThemeMode.system');
        break;
    }
    notifyListeners();
  }
  
  // 切換明暗主題
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setTheme(ThemeType.dark);
    } else {
      await setTheme(ThemeType.light);
    }
  }
  
  // 設置主要顏色
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await _prefs.setInt(_primaryColorKey, color.toARGB32());
    notifyListeners();
  }
  
  // 設置次要顏色
  Future<void> setSecondaryColor(Color color) async {
    _secondaryColor = color;
    await _prefs.setInt(_secondaryColorKey, color.toARGB32());
    notifyListeners();
  }
  
  // 設置強調顏色
  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    await _prefs.setInt(_accentColorKey, color.toARGB32());
    notifyListeners();
  }
  
  // 重置所有顏色
  Future<void> resetColors() async {
    _primaryColor = _defaultPrimaryColor;
    _secondaryColor = _defaultSecondaryColor;
    _accentColor = _defaultAccentColor;
    
    await _prefs.remove(_primaryColorKey);
    await _prefs.remove(_secondaryColorKey);
    await _prefs.remove(_accentColorKey);
    
    notifyListeners();
  }
} 