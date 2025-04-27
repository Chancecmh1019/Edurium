import 'package:flutter/material.dart';

/// 一個通用的卡片小部件，統一卡片UI風格
class AppCard extends StatelessWidget {
  /// 卡片標題
  final String? title;
  
  /// 標題前的圖標
  final IconData? titleIcon;
  
  /// 標題的顏色
  final Color? titleColor;
  
  /// 右側操作按鈕
  final Widget? actionButton;
  
  /// 卡片內容
  final Widget child;
  
  /// 卡片高度
  final double? height;
  
  /// 卡片內邊距
  final EdgeInsetsGeometry padding;
  
  /// 卡片顏色
  final Color? color;
  
  /// 卡片邊框顏色
  final Color? borderColor;
  
  /// 是否顯示卡片外陰影
  final bool showShadow;
  
  /// 點擊事件
  final VoidCallback? onTap;
  
  /// 長按事件
  final VoidCallback? onLongPress;
  
  /// 卡片外邊距
  final EdgeInsetsGeometry margin;
  
  /// 卡片邊框
  final Border? border;

  /// 卡片高度
  final double elevation;

  /// 卡片形狀
  final ShapeBorder? shape;

  /// 卡片點擊時的波紋顏色
  final Color? splashColor;

  /// 卡片高亮時的顏色
  final Color? highlightColor;

  /// 卡片的內容對齊方式
  final CrossAxisAlignment contentAlignment;
  
  const AppCard({
    super.key,
    this.title,
    this.titleIcon,
    this.titleColor,
    this.actionButton,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.showShadow = true,
    this.onTap,
    this.onLongPress,
    this.margin = EdgeInsets.zero,
    this.border,
    this.elevation = 1.0,
    this.shape,
    this.splashColor,
    this.highlightColor,
    this.contentAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Material 3 風格的卡片
    return Card(
      margin: margin,
      color: color ?? colorScheme.surface,
      elevation: showShadow ? elevation : 0,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: showShadow ? colorScheme.surfaceTint : Colors.transparent,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: border?.top ?? (borderColor != null 
          ? BorderSide(color: borderColor!, width: 1) 
          : isDark ? BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1) : BorderSide.none),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: splashColor ?? colorScheme.primary.withOpacity(0.1),
        highlightColor: highlightColor ?? colorScheme.primary.withOpacity(0.05),
        child: Container(
          height: height,
          padding: title != null ? EdgeInsets.zero : padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: contentAlignment,
            children: [
              // 卡片標題區域
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 標題與圖標
                      Expanded(
                        child: Row(
                          children: [
                            if (titleIcon != null) ...[
                              Icon(
                                titleIcon,
                                size: 20,
                                color: titleColor ?? colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                title!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: titleColor ?? colorScheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                const Divider(height: 1),
              ],
              
              // 主要內容
              title != null 
                  ? Padding(
                      padding: padding,
                      child: child,
                    )
                  : child,
            ],
          ),
        ),
      ),
    );
  }
} 