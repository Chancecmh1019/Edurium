import 'package:flutter/material.dart';

/// 底部導航項
class BottomNavItem {
  /// 圖標
  final IconData icon;
  
  /// 激活時的圖標
  final IconData activeIcon;
  
  /// 標籤文字
  final String label;
  
  /// 是否有未讀消息
  final bool hasNotification;
  
  /// 未讀數量
  final int notificationCount;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.hasNotification = false,
    this.notificationCount = 0,
  });
} 