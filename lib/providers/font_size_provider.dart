import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

enum FontSizeType {
  small,
  normal,
  large,
  extraLarge,
}

class FontSizeProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'font_size';
  
  // 字體大小因子
  static const Map<FontSizeType, double> fontSizeFactors = {
    FontSizeType.small: 0.85,
    FontSizeType.normal: 1.0,
    FontSizeType.large: 1.15,
    FontSizeType.extraLarge: 1.3,
  };
  
  late SharedPreferences _prefs;
  FontSizeType _fontSizeType = FontSizeType.normal;
  
  // 獲取當前字體大小類型
  FontSizeType get fontSizeType => _fontSizeType;
  
  // 獲取當前字體大小因子
  double get fontSizeFactor => fontSizeFactors[_fontSizeType]!;
  
  FontSizeProvider() {
    _loadFontSize();
  }
  
  // 從本地存儲載入字體大小設定
  Future<void> _loadFontSize() async {
    _prefs = await SharedPreferences.getInstance();
    final fontSizeIndex = _prefs.getInt(_fontSizeKey);
    if (fontSizeIndex != null && fontSizeIndex < FontSizeType.values.length) {
      _fontSizeType = FontSizeType.values[fontSizeIndex];
      notifyListeners();
    }
  }
  
  // 設置字體大小
  Future<void> setFontSize(FontSizeType fontSizeType) async {
    _fontSizeType = fontSizeType;
    await _prefs.setInt(_fontSizeKey, fontSizeType.index);
    notifyListeners();
  }
  
  // 獲取字體大小名稱
  String getFontSizeName(BuildContext context) {
    return getFontSizeTypeName(_fontSizeType, context);
  }
  
  // 獲取字體大小類型名稱
  static String getFontSizeTypeName(FontSizeType fontSizeType, BuildContext context) {
    switch (fontSizeType) {
      case FontSizeType.small:
        return '小';
      case FontSizeType.normal:
        return '標準';
      case FontSizeType.large:
        return '大';
      case FontSizeType.extraLarge:
        return '特大';
    }
  }
} 