import 'package:flutter/material.dart';
import 'bottom_nav_item.dart';

class EduriumBottomNavBar extends StatelessWidget {
  /// 當前索引
  final int currentIndex;
  
  /// 導航項
  final List<BottomNavItem> items;
  
  /// 點擊回調
  final Function(int) onTap;
  
  /// 高度
  final double height;
  
  /// 背景顏色
  final Color? backgroundColor;
  
  /// 選中項顏色
  final Color? selectedItemColor;
  
  /// 未選中項顏色
  final Color? unselectedItemColor;
  
  const EduriumBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.height = 65,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  }) : assert(items.length >= 2, '至少需要2個導航項');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: height + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          return _buildNavItem(
            context,
            item: items[index],
            isSelected: index == currentIndex,
            index: index,
          );
        }),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required BottomNavItem item,
    required bool isSelected,
    required int index,
  }) {
    final theme = Theme.of(context);
    final selectedColor = selectedItemColor ?? theme.colorScheme.primary;
    final unselectedColor = unselectedItemColor ?? theme.colorScheme.onSurface.withOpacity(0.6);
    
    return InkWell(
      onTap: () => onTap(index),
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width / items.length,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 圖標與通知標記
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 圖標
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected ? selectedColor : unselectedColor,
                  size: isSelected ? 26 : 24,
                ),
                
                // 通知標記
                if (item.hasNotification)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: item.notificationCount > 0 ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: item.notificationCount > 0 ? BorderRadius.circular(8) : null,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: item.notificationCount > 0
                          ? Center(
                              child: Text(
                                item.notificationCount > 99 ? '99+' : '${item.notificationCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // 標籤文字
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
} 