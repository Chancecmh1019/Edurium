import 'package:flutter/material.dart';

class AppAssets {
  // 應用程式圖標
  static const String appIcon = 'assets/images/app_icon.png';
  
  // 啟動屏幕動畫
  static const String splashAnimation = 'assets/animations/splash_animation.json';
  
  // 圖片
  static const String onboardingImage1 = 'assets/images/onboarding_1.png';
  static const String onboardingImage2 = 'assets/images/onboarding_2.png';
  static const String onboardingImage3 = 'assets/images/onboarding_3.png';
  static const String onboardingImage4 = 'assets/images/onboarding_4.png';
  
  // 圖標
  static const IconData taskIcon = Icons.assignment;
  static const IconData examIcon = Icons.note_alt;
  static const IconData projectIcon = Icons.science;
  static const IconData reminderIcon = Icons.notifications;
  
  // 顏色
  static const MaterialColor primaryColor = Colors.blue;
  static const MaterialColor secondaryColor = Colors.orange;
  
  // 載入應用資源
  static Future<void> preloadAssets() async {
    // 預加載資源的邏輯
    await Future.delayed(const Duration(milliseconds: 500));
  }
} 