import 'package:flutter/material.dart';

/// 空狀態顯示組件
/// 
/// 用於顯示沒有數據的情況，支持自定義圖標、消息和按鈕
class EmptyState extends StatelessWidget {
  /// 顯示的圖標
  final IconData icon;
  
  /// 主要消息
  final String message;
  
  /// 次要消息，支持多行
  final String? subMessage;
  
  /// 圖標大小
  final double iconSize;
  
  /// 圖標顏色
  final Color? iconColor;
  
  /// 操作按鈕
  final Widget? actionButton;
  
  /// 是否使用緊湊模式顯示
  final bool compact;
  
  /// 建構函數
  const EmptyState({
    Key? key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.iconSize = 80.0,
    this.iconColor,
    this.actionButton,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: compact ? iconSize * 0.6 : iconSize,
              color: iconColor ?? colorScheme.primary.withOpacity(0.6),
            ),
            SizedBox(height: compact ? 12 : 24),
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: compact ? 16 : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              SizedBox(height: compact ? 6 : 12),
              Text(
                subMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: compact ? 12 : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButton != null) ...[
              SizedBox(height: compact ? 16 : 32),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
} 