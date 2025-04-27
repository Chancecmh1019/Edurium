import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/providers/task_provider.dart';
import 'package:edurium/providers/subject_provider.dart';
import 'package:edurium/models/task.dart';
import 'package:edurium/utils/date_util.dart';
import 'package:edurium/screens/add_task/add_task_screen.dart';
import 'package:edurium/screens/add_task/task_detail_screen.dart';
import 'package:edurium/screens/calendar/calendar_screen.dart';
import 'package:edurium/utils/date_utils.dart' as date_utils;
import 'package:edurium/widgets/common/app_card.dart';
import 'package:edurium/widgets/common/empty_state.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;

/// 首頁上的即將到來任務卡片
class UpcomingTasksCard extends StatelessWidget {
  /// 最大顯示數量
  final int maxItems;
  
  /// 卡片高度
  final double? height;
  
  const UpcomingTasksCard({
    super.key,
    this.maxItems = 5,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // 獲取待辦任務
        final upcomingTasks = taskProvider.getUpcomingTasks(limit: maxItems);
        final overdueTasks = taskProvider.getOverdueTasks(limit: 3);
        final hasTasks = upcomingTasks.isNotEmpty || overdueTasks.isNotEmpty;
        
        return AppCard(
          title: '代辦事項',
          titleIcon: Icons.event_note,
          actionButton: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
            child: Text(hasTasks ? '查看全部' : '新增'),
          ),
          height: height,
          child: hasTasks 
              ? _buildTasksList(context, overdueTasks, upcomingTasks)
              : const EmptyState(
                  icon: Icons.task_alt,
                  message: '目前沒有待辦事項',
                  subMessage: '輕鬆一下，或點擊右上角新增任務',
                ),
        );
      },
    );
  }

  Widget _buildTasksList(
    BuildContext context,
    List<Task> overdueTasks,
    List<Task> upcomingTasks,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 逾期任務
        if (overdueTasks.isNotEmpty) ...[
          _buildSectionTitle(context, '已逾期', Colors.red),
          ...overdueTasks.map((task) => _buildTaskItem(context, task, isOverdue: true)),
        ],
        
        // 即將到來任務
        if (upcomingTasks.isNotEmpty) ...[
          if (overdueTasks.isNotEmpty)
            const SizedBox(height: 16),
          _buildSectionTitle(context, '即將到來', Colors.green),
          ...upcomingTasks.map((task) => _buildTaskItem(context, task)),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, {bool isOverdue = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 根據任務類型獲取顏色
    Color taskColor;
    IconData taskIcon;
    
    switch (task.taskType) {
      case TaskType.homework:
        taskColor = colorScheme.primary;
        taskIcon = Icons.assignment;
        break;
      case TaskType.exam:
        taskColor = Colors.red.shade700;
        taskIcon = Icons.quiz;
        break;
      case TaskType.project:
        taskColor = Colors.purple;
        taskIcon = Icons.work;
        break;
      case TaskType.reading:
        taskColor = Colors.blue;
        taskIcon = Icons.menu_book;
        break;
      case TaskType.meeting:
        taskColor = Colors.amber.shade700;
        taskIcon = Icons.people;
        break;
      case TaskType.reminder:
        taskColor = Colors.teal;
        taskIcon = Icons.notifications;
        break;
      case TaskType.other:
        taskColor = Colors.grey.shade700;
        taskIcon = Icons.event_note;
        break;
    }
    
    // 時間格式化
    final formatter = DateFormat('MMMd', Platform.localeName);
    final dueDate = formatter.format(task.dueDate);
    final daysLeft = date_utils.AppDateUtils.getDaysLeft(task.dueDate);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 查看任務詳情
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: taskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: taskColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // 圖標
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: taskColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    taskIcon,
                    color: taskColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // 任務內容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 科目標籤
                          if (task.subject?.name != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: taskColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.subject!.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: taskColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          
                          // 任務類型
                          Text(
                            _getTaskTypeText(task.taskType),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // 任務標題
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isOverdue 
                              ? Colors.red.shade700
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // 截止日期
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: isOverdue 
                                ? Colors.red.shade700
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue
                                ? '已逾期 ${daysLeft.abs()} 天'
                                : '$dueDate${daysLeft == 0 ? " (今天)" : daysLeft == 1 ? " (明天)" : " ($daysLeft 天後)"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue 
                                  ? Colors.red.shade700
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 任務優先級
                _buildPriorityIndicator(task.priority),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 任務優先級指示器
  Widget _buildPriorityIndicator(TaskPriority priority) {
    Color color;
    String label;
    
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red.shade700;
        label = '高';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        label = '中';
        break;
      case TaskPriority.low:
        color = Colors.green;
        label = '低';
        break;
      case TaskPriority.urgent:
        color = Colors.deepPurple.shade700;
        label = '緊急';
        break;
    }
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  // 獲取任務類型文字
  String _getTaskTypeText(TaskType type) {
    switch (type) {
      case TaskType.homework:
        return '作業';
      case TaskType.exam:
        return '考試';
      case TaskType.project:
        return '專案';
      case TaskType.reading:
        return '閱讀';
      case TaskType.meeting:
        return '會議';
      case TaskType.reminder:
        return '提醒';
      case TaskType.other:
        return '其他';
    }
  }
} 