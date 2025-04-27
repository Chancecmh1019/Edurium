import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider extends ChangeNotifier {
  static const String _highContrastKey = 'high_contrast';
  static const String _boldTextKey = 'bold_text';
  static const String _reduceAnimationKey = 'reduce_animation';
  static const String _increasedTouchTargetKey = 'increased_touch_target_preference';
  static const String _screenReaderKey = 'screen_reader_preference';
  
  late SharedPreferences _prefs;
  bool _isHighContrast = false;
  bool _isBoldText = false;
  bool _isReduceAnimation = false;
  bool _isIncreasedTouchTarget = false;
  bool _isScreenReaderEnabled = false;
  
  // 獲取當前高對比度狀態
  bool get isHighContrast => _isHighContrast;
  
  // 獲取當前粗體文字狀態
  bool get isBoldText => _isBoldText;
  
  // 獲取當前減少動畫狀態
  bool get isReduceAnimation => _isReduceAnimation;
  
  // 獲取當前增大觸控目標狀態
  bool get isIncreasedTouchTarget => _isIncreasedTouchTarget;
  
  // 獲取當前螢幕閱讀器支援狀態
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  
  AccessibilityProvider() {
    _loadAccessibilitySettings();
  }
  
  // 從本地儲存載入無障礙設置
  Future<void> _loadAccessibilitySettings() async {
    _prefs = await SharedPreferences.getInstance();
    _isHighContrast = _prefs.getBool(_highContrastKey) ?? false;
    _isBoldText = _prefs.getBool(_boldTextKey) ?? false;
    _isReduceAnimation = _prefs.getBool(_reduceAnimationKey) ?? false;
    _isIncreasedTouchTarget = _prefs.getBool(_increasedTouchTargetKey) ?? false;
    _isScreenReaderEnabled = _prefs.getBool(_screenReaderKey) ?? false;
    notifyListeners();
  }
  
  // 設置高對比度狀態
  Future<void> setHighContrast(bool value) async {
    _isHighContrast = value;
    await _prefs.setBool(_highContrastKey, value);
    notifyListeners();
  }
  
  // 設置粗體文字狀態
  Future<void> setBoldText(bool value) async {
    _isBoldText = value;
    await _prefs.setBool(_boldTextKey, value);
    notifyListeners();
  }
  
  // 設置減少動畫狀態
  Future<void> setReduceAnimation(bool value) async {
    _isReduceAnimation = value;
    await _prefs.setBool(_reduceAnimationKey, value);
    notifyListeners();
  }
  
  // 設置增大觸控目標
  Future<void> setIncreasedTouchTarget(bool value) async {
    _isIncreasedTouchTarget = value;
    await _prefs.setBool(_increasedTouchTargetKey, value);
    notifyListeners();
  }
  
  // 設置螢幕閱讀器支援
  Future<void> setScreenReaderEnabled(bool value) async {
    _isScreenReaderEnabled = value;
    await _prefs.setBool(_screenReaderKey, value);
    notifyListeners();
  }
  
  // 獲取高對比度顏色
  Color getHighContrastColor(Color original, Color highContrastColor) {
    return _isHighContrast ? highContrastColor : original;
  }
  
  // 獲取文字對比度顏色
  Color getTextColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_isHighContrast) {
      return isDarkMode ? Colors.yellow : Colors.black;
    } else {
      return isDarkMode ? Colors.white : Colors.black;
    }
  }
  
  // 獲取背景對比度顏色
  Color getBackgroundColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_isHighContrast) {
      return isDarkMode ? Colors.black : Colors.white;
    } else {
      return isDarkMode 
          ? Theme.of(context).scaffoldBackgroundColor 
          : Theme.of(context).scaffoldBackgroundColor;
    }
  }
  
  // 獲取字體粗細
  FontWeight getFontWeight(FontWeight original) {
    if (_isBoldText) {
      return FontWeight.bold;
    }
    return original;
  }
  
  // 獲取按鈕大小調整
  double getButtonSize(double original) {
    if (_isIncreasedTouchTarget) {
      return original * 1.2;
    }
    return original;
  }
  
  // 獲取元素間距調整
  double getSpacing(double original) {
    if (_isIncreasedTouchTarget) {
      return original * 1.5;
    }
    return original;
  }
  
  // 是否顯示動畫
  bool shouldShowAnimation() {
    return !_isReduceAnimation;
  }
  
  // 獲取動畫持續時間
  Duration getAnimationDuration(Duration original) {
    if (_isReduceAnimation) {
      return Duration.zero;
    }
    return original;
  }
} 