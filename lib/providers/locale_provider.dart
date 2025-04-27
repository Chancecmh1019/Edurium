import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  
  // 支援的語言
  static const Map<String, Locale> supportedLocales = {
    'zh_TW': Locale('zh', 'TW'), // 繁體中文
    'zh_CN': Locale('zh', 'CN'), // 簡體中文
    'en': Locale('en'),          // 英文
    'ja': Locale('ja'),          // 日文
    'ko': Locale('ko'),          // 韓文
  };
  
  // 語言名稱
  static const Map<String, String> localeNames = {
    'zh_TW': '繁體中文',
    'zh_CN': '简体中文',
    'en': 'English',
    'ja': '日本語',
    'ko': '한국어',
  };
  
  late SharedPreferences _prefs;
  Locale _locale = const Locale('zh', 'TW');
  
  LocaleProvider() {
    _loadLocale();
  }
  
  // 獲取當前語言
  Locale get locale => _locale;
  
  // 獲取當前語言代碼 (如 zh_TW)
  String get localeCode {
    return _locale.languageCode + (_locale.countryCode != null ? '_${_locale.countryCode}' : '');
  }
  
  // 獲取當前語言名稱
  String get localeName {
    final key = '${_locale.languageCode}${_locale.countryCode != null ? '_${_locale.countryCode}' : ''}';
    return localeNames[key] ?? key;
  }
  
  // 設置語言
  Future<void> setLocale(String localeCode) async {
    if (supportedLocales.containsKey(localeCode)) {
      _locale = supportedLocales[localeCode]!;
      await _prefs.setString(_localeKey, localeCode);
      notifyListeners();
    }
  }
  
  // 從本地儲存載入語言設置
  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLocale = _prefs.getString(_localeKey);
    if (savedLocale != null && supportedLocales.containsKey(savedLocale)) {
      _locale = supportedLocales[savedLocale]!;
      notifyListeners();
    }
  }
  
  // 獲取所有支援的語言
  List<Map<String, dynamic>> getSupportedLocales() {
    return supportedLocales.entries.map((entry) {
      return {
        'key': entry.key,
        'locale': entry.value,
        'name': localeNames[entry.key] ?? entry.key
      };
    }).toList();
  }
  
  // 檢查是否為中文系語言
  bool get isChineseLanguage {
    return _locale.languageCode == 'zh';
  }
  
  // 檢查是否為日文
  bool get isJapanese {
    return _locale.languageCode == 'ja';
  }
  
  // 檢查是否為韓文
  bool get isKorean {
    return _locale.languageCode == 'ko';
  }
} 