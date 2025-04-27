import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/providers/task_provider.dart';
import 'package:edurium/providers/subject_provider.dart';
import 'package:edurium/models/task.dart';
import 'package:edurium/utils/date_util.dart';
import 'package:edurium/utils/constants.dart' as utils;
import 'package:intl/intl.dart';
import 'package:edurium/widgets/calendar/calendar_view_selector.dart';
import 'package:edurium/widgets/common/empty_state.dart';
import 'package:edurium/utils/date_utils.dart' as date_utils;

/// 行事曆事件列表
class CalendarEventList extends StatelessWidget {
  /// 選中的日期
  final DateTime selectedDay;
  
  /// 視圖模式
  final ViewMode viewMode;
  
  const CalendarEventList({
    super.key,
    required this.selectedDay,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, SubjectProvider>(
      builder: (context, taskProvider, subjectProvider, child) {
        // 根據視圖模式獲取任務
        final tasks = _getTasksForViewMode(taskProvider);
        
        // 檢查是否有任務
        if (tasks.isEmpty) {
          return _buildEmptyState(context);
        }
        
        // 根據視圖模式顯示不同的標題
        final sectionTitle = _getSectionTitle(context);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                sectionTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            
            // 事件列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return _buildTaskItem(context, tasks[index], subjectProvider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 根據視圖模式獲取任務
  List<Task> _getTasksForViewMode(TaskProvider taskProvider) {
    switch (viewMode) {
      case ViewMode.calendar:
      case ViewMode.month:
        return taskProvider.getTasksForDay(selectedDay);
      case ViewMode.week:
        final firstDay = date_utils.AppDateUtils.getFirstDayOfWeek(selectedDay);
        final lastDay = date_utils.AppDateUtils.getLastDayOfWeek(selectedDay);
        return taskProvider.getTasksForRange(firstDay, lastDay);
      case ViewMode.list:
        return taskProvider.getUpcomingTasks(limit: 20);
      default:
        return [];
    }
  }

  // 獲取標題
  String _getSectionTitle(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode == 'zh';
    
    switch (viewMode) {
      case ViewMode.calendar:
      case ViewMode.month:
        final dateFormatter = DateFormat.yMMMd(locale.toString());
        final date = dateFormatter.format(selectedDay);
        return isZh ? '$date 事項' : 'Events on $date';
      case ViewMode.week:
        final firstDay = date_utils.AppDateUtils.getFirstDayOfWeek(selectedDay);
        final lastDay = date_utils.AppDateUtils.getLastDayOfWeek(selectedDay);
        final startFormatter = DateFormat('MMM d', locale.toString());
        final endFormatter = DateFormat('MMM d', locale.toString());
        final start = startFormatter.format(firstDay);
        final end = endFormatter.format(lastDay);
        return isZh ? '$start 至 $end 的事項' : 'Events from $start to $end';
      case ViewMode.list:
        return isZh ? '即將到來的事項' : 'Upcoming Events';
      default:
        return '';
    }
  }

  // 構建空狀態
  Widget _buildEmptyState(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode == 'zh';
    
    String message = '';
    String subMessage = '';
    
    switch (viewMode) {
      case ViewMode.calendar:
      case ViewMode.month:
        message = isZh ? '這一天沒有任何事項' : 'No events on this day';
        subMessage = isZh ? '點擊右下角按鈕新增事項' : 'Click the button below to add a new event';
        break;
      case ViewMode.week:
        message = isZh ? '這一週沒有任何事項' : 'No events this week';
        subMessage = isZh ? '點擊右下角按鈕新增事項' : 'Click the button below to add a new event';
        break;
      case ViewMode.list:
        message = isZh ? '沒有即將到來的事項' : 'No upcoming events';
        subMessage = isZh ? '輕鬆一下吧！' : 'Time to relax!';
        break;
      default:
        message = isZh ? '沒有事項' : 'No events';
        subMessage = isZh ? '點擊右下角按鈕新增事項' : 'Click the button below to add a new event';
        break;
    }
    
    return EmptyState(
      icon: Icons.event_available,
      message: message,
      subMessage: subMessage,
      actionButton: viewMode != ViewMode.list
          ? ElevatedButton.icon(
              onPressed: () {
                // TODO: 導航到新增任務頁面，並預設選擇的日期
                Navigator.pushNamed(context, '/add_task', arguments: {
                  'date': selectedDay,
                });
              },
              icon: const Icon(Icons.add),
              label: Text(isZh ? '新增事項' : 'Add Event'),
            )
          : null,
    );
  }

  // 構建任務項
  Widget _buildTaskItem(BuildContext context, Task task, SubjectProvider subjectProvider) {
    final theme = Theme.of(context);
    
    // 獲取科目
    final subject = task.subjectId != null
        ? subjectProvider.getSubjectById(task.subjectId!)
        : null;
    
    // 獲取任務顏色和圖標
    Color taskColor;
    IconData taskIcon;
    
    switch (task.taskType) {
      case TaskType.homework:
        taskColor = theme.colorScheme.primary;
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
      default:
        taskColor = Colors.grey.shade700;
        taskIcon = Icons.event_note;
        break;
    }
    
    // 構建任務卡片
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () {
          // 導航到任務詳情頁面
          Navigator.pushNamed(
            context,
            '/task_detail',
            arguments: {'taskId': task.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 任務類型圖標
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: taskColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      taskIcon,
                      color: taskColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 任務標題和描述
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (task.description != null && task.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              task.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 任務信息行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 科目
                  if (subject != null)
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.book,
                            size: 16,
                            color: theme.colorScheme.primary.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              subject.name,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // 到期日期/時間
                  Row(
                    children: [
                      Icon(
                        task.hasTime ? Icons.access_time : Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getFormattedDueDate(context, task),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  // 優先級
                  Row(
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: _getPriorityColor(task.priority, theme),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getPriorityText(task.priority, context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getPriorityColor(task.priority, theme),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // 附件指示器
              if (task.hasAttachments)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '附件',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 獲取格式化的到期日期
  String _getFormattedDueDate(BuildContext context, Task task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    
    final locale = Localizations.localeOf(context).toString();
    final dateFormatter = DateFormat.yMMMd(locale);
    final timeFormatter = DateFormat.Hm(locale);
    
    String formattedDate;
    
    if (taskDate.isAtSameMomentAs(today)) {
      formattedDate = '今天';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      formattedDate = '明天';
    } else {
      formattedDate = dateFormatter.format(task.dueDate);
    }
    
    // 如果任務有時間，添加時間
    if (task.hasTime && task.extras != null && task.extras!.containsKey('time')) {
      final timeString = timeFormatter.format(task.dueDate);
      formattedDate = '$formattedDate $timeString';
    }
    
    return formattedDate;
  }
  
  // 獲取優先級顏色
  Color _getPriorityColor(TaskPriority priority, ThemeData theme) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade700;
      case TaskPriority.medium:
        return Colors.orange.shade700;
      case TaskPriority.low:
        return theme.colorScheme.onSurface.withOpacity(0.7);
      case TaskPriority.urgent:
        return Colors.deepPurple.shade700;
    }
  }
  
  // 獲取優先級文本
  String _getPriorityText(TaskPriority priority, BuildContext context) {
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    
    switch (priority) {
      case TaskPriority.high:
        return isZh ? '高' : 'High';
      case TaskPriority.medium:
        return isZh ? '中' : 'Medium';
      case TaskPriority.low:
        return isZh ? '低' : 'Low';
      case TaskPriority.urgent:
        return isZh ? '緊急' : 'Urgent';
    }
  }
} 