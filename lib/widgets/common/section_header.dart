import 'package:flutter/material.dart';

/// 一個通用的區段標題小部件
class SectionHeader extends StatelessWidget {
  /// 標題
  final String title;
  
  /// 副標題
  final String? subtitle;
  
  /// 前導圖標
  final IconData? icon;
  
  /// 右側操作按鈕
  final Widget? actionButton;
  
  /// 標題顏色
  final Color? color;
  
  /// 圖標顏色
  final Color? iconColor;
  
  /// 點擊事件
  final VoidCallback? onTap;
  
  /// 內邊距
  final EdgeInsetsGeometry padding;
  
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionButton,
    this.color,
    this.iconColor,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = color ?? theme.colorScheme.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 左側標題部分
            Expanded(
              child: Row(
                children: [
                  // 前導圖標
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: iconColor ?? titleColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // 標題和副標題
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 主標題
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // 副標題
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 右側按鈕
            if (actionButton != null) actionButton!,
          ],
        ),
      ),
    );
  }
} 