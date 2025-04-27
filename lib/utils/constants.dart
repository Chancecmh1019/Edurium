import 'package:flutter/material.dart';

/// 應用程式常數
class AppConstants {
  // 應用信息
  static const String appName = 'Edurium';
  static const String appVersion = '1.0.0';
  
  // 默認動畫持續時間
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // 任務相關
  static const int defaultTaskDueHour = 23;
  static const int defaultTaskDueMinute = 59;
  
  // Hive 盒子名稱
  static const String taskBoxName = 'tasks';
  static const String subjectBoxName = 'subjects';
  static const String teacherBoxName = 'teachers';
  static const String gradeBoxName = 'grades';
  static const String settingsBoxName = 'settings';
  static const String userBoxName = 'users';
  
  // 默認設定
  static const bool defaultDarkMode = false;
  static const String defaultLanguage = 'en';
  
  // 共享存儲鍵名
  static const String themeKey = 'theme_preference';
  static const String localeKey = 'locale_preference';
  static const String fontSizeKey = 'font_size_preference';
  static const String highContrastKey = 'high_contrast_preference';
  static const String boldTextKey = 'bold_text_preference';
  static const String reduceAnimationKey = 'reduce_animation_preference';
}

/// 應用程式顏色
class AppColorConstants {
  // 主題顏色
  static const Color primaryColor = Color(0xFF5D70EA);
  static const Color secondaryColor = Color(0xFF7F53AC);

  // 背景顏色
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color darkBackgroundColor = Color(0xFF121212);
  
  // 卡片顏色
  static const Color lightCardColor = Colors.white;
  static const Color darkCardColor = Color(0xFF1E1E1E);

  // 文字顏色
  static const Color lightTextColor = Color(0xFF1A1A1A);
  static const Color darkTextColor = Color(0xFFF5F5F5);
  static const Color lightSecondaryTextColor = Color(0xFF757575);
  static const Color darkSecondaryTextColor = Color(0xFFBDBDBD);

  // 任務類型顏色
  static const Color homeworkColor = Color(0xFF4CAF50);  // 綠色
  static const Color examColor = Color(0xFFF44336);      // 紅色
  static const Color projectColor = Color(0xFF2196F3);   // 藍色
  static const Color readingColor = Color(0xFF795548);   // 棕色
  static const Color meetingColor = Color(0xFF9C27B0);   // 紫色
  static const Color reminderColor = Color(0xFFFF9800);  // 橙色
  static const Color otherColor = Color(0xFF607D8B);     // 藍灰色
  
  // 科目顏色
  static const List<Color> subjectColors = [
    Color(0xFF1976D2),  // 藍色
    Color(0xFFD32F2F),  // 紅色
    Color(0xFF388E3C),  // 綠色
    Color(0xFF7B1FA2),  // 紫色
    Color(0xFFC2185B),  // 粉紅色
    Color(0xFF00796B),  // 藍綠色
    Color(0xFFE64A19),  // 橙色
    Color(0xFF5D4037),  // 棕色
    Color(0xFF455A64),  // 藍灰色
    Color(0xFF616161),  // 灰色
  ];
  
  // 成績等級顏色
  static const Color gradeAColor = Color(0xFF4CAF50);    // 綠色
  static const Color gradeBColor = Color(0xFF8BC34A);    // 淺綠色
  static const Color gradeCColor = Color(0xFFFFEB3B);    // 黃色
  static const Color gradeDColor = Color(0xFFFF9800);    // 橙色
  static const Color gradeFColor = Color(0xFFF44336);    // 紅色
}

// 任務類型顏色常量在AppColorConstants中已定義，移除這個擴展以避免命名衝突
//extension AppColors on Colors {
//  static const Color homeworkColor = Color(0xFF4CAF50); // 作業顏色 - 綠色
//  static const Color examColor = Color(0xFFE53935);     // 考試顏色 - 紅色
//  static const Color projectColor = Color(0xFF3F51B5);  // 專案顏色 - 藍色
//  static const Color reminderColor = Color(0xFFFF9800); // 提醒顏色 - 橙色
//  static const Color meetingColor = Color(0xFF9C27B0);  // 會議顏色 - 紫色
//  
//  // 主色調相關
//  static const Color primaryColor = Color(0xFF6B8F71);     // 主色調
//  static const Color secondaryColor = Color(0xFFF0B67F);   // 次要色調
//} 