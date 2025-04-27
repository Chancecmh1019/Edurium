import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/providers/locale_provider.dart';

/// 行事曆視圖模式
enum ViewMode {
  /// 日期視圖
  calendar,
  
  /// 週視圖
  week,
  
  /// 月視圖
  month,
  
  /// 列表視圖
  list,
}

/// 行事曆視圖選擇器
class CalendarViewSelector extends StatelessWidget {
  /// 當前視圖模式
  final ViewMode viewMode;
  
  /// 視圖模式改變回調
  final void Function(ViewMode) onViewModeChanged;
  
  const CalendarViewSelector({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isZh = localeProvider.locale.languageCode == 'zh';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewModeButton(
                context,
                label: isZh ? '日曆' : 'Calendar',
                icon: Icons.calendar_month,
                mode: ViewMode.calendar,
              ),
              _buildViewModeButton(
                context,
                label: isZh ? '週' : 'Week',
                icon: Icons.view_week,
                mode: ViewMode.week,
              ),
              _buildViewModeButton(
                context,
                label: isZh ? '月' : 'Month',
                icon: Icons.calendar_view_month,
                mode: ViewMode.month,
              ),
              _buildViewModeButton(
                context,
                label: isZh ? '列表' : 'List',
                icon: Icons.view_list,
                mode: ViewMode.list,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required ViewMode mode,
  }) {
    final theme = Theme.of(context);
    final isSelected = viewMode == mode;
    
    return InkWell(
      onTap: () => onViewModeChanged(mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 