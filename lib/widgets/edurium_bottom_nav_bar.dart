import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class EduriumBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double iconSize;
  final double height;
  final bool showLabels;
  final double? elevation;
  final double indicatorSize;

  const EduriumBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.iconSize = 24.0,
    this.height = 80.0,
    this.showLabels = true,
    this.elevation,
    this.indicatorSize = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 使用 Material 3 的 NavigationBar
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      height: height,
      labelBehavior: showLabels 
          ? NavigationDestinationLabelBehavior.alwaysShow
          : NavigationDestinationLabelBehavior.alwaysHide,
      elevation: elevation ?? 3,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      animationDuration: const Duration(milliseconds: 300),
      destinations: items.map((item) => 
        NavigationDestination(
          icon: Icon(
            item.icon,
            size: iconSize,
            color: unselectedItemColor ?? colorScheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            item.activeIcon ?? item.icon,
            size: iconSize,
            color: selectedItemColor ?? colorScheme.primary,
          ),
          label: item.label,
          tooltip: item.tooltip,
        )
      ).toList(),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? tooltip;

  BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.tooltip,
  });
} 