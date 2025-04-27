import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/utils.dart';

class UpcomingEventsSection extends StatelessWidget {
  final List<Task> tasks;

  const UpcomingEventsSection({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final String sectionTitle = locale.languageCode == 'zh' ? '即將到來' : 'Upcoming Events';
    final String noTasksText = locale.languageCode == 'zh' 
        ? '未來7天沒有待辦事項' 
        : 'No upcoming tasks';
    final String viewAllText = locale.languageCode == 'zh' 
        ? '查看全部' 
        : 'View All';
    
    // 按日期分組任務
    final Map<DateTime, List<Task>> groupedTasks = {};
    final now = DateTime.now();
    
    for (final task in tasks) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      
      if (!groupedTasks.containsKey(taskDate)) {
        groupedTasks[taskDate] = [];
      }
      
      groupedTasks[taskDate]!.add(task);
    }
    
    // 對日期進行排序
    final sortedDates = groupedTasks.keys.toList()..sort();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sectionTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (tasks.isNotEmpty)
              TextButton(
                onPressed: () {
                  // 導航到任務列表
                },
                child: Text(
                  viewAllText,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // 任務列表
        if (tasks.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  noTasksText,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < sortedDates.length; i++)
                _buildDaySection(context, sortedDates[i], groupedTasks[sortedDates[i]]!, i == sortedDates.length - 1),
            ],
          ),
      ],
    );
  }
  
  Widget _buildDaySection(BuildContext context, DateTime date, List<Task> dayTasks, bool isLast) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期標題
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? AppColors.primaryDark.withOpacity(0.2) 
                      : AppColors.primaryLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateUtil.formatDateFriendly(date, locale: locale),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateUtil.getWeekdayShortName(date, locale: locale),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 6),
        
        // 任務列表
        Container(
          margin: const EdgeInsets.only(left: 11),
          padding: const EdgeInsets.only(left: 11),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isDarkMode 
                    ? AppColors.primaryDark.withOpacity(0.3) 
                    : AppColors.primaryLight.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < dayTasks.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == dayTasks.length - 1 ? 0 : 10),
                  child: _buildTaskItem(context, dayTasks[i]),
                ),
            ],
          ),
        ),
        
        if (!isLast)
          const SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildTaskItem(BuildContext context, Task task) {
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final subject = task.subjectId != null ? subjectProvider.getSubjectById(task.subjectId!) : null;
    final locale = Provider.of<LocaleProvider>(context).locale;
    
    // 獲取任務類型的圖標
    IconData getTaskTypeIcon() {
      switch (task.taskType) {
        case TaskType.exam:
          return Icons.note_alt_outlined;
        case TaskType.homework:
          return Icons.assignment_outlined;
        case TaskType.project:
          return Icons.science_outlined;
        case TaskType.reading:
          return Icons.menu_book_outlined;
        case TaskType.meeting:
          return Icons.people_outline;
        case TaskType.reminder:
          return Icons.notification_important_outlined;
        case TaskType.other:
          return Icons.task_alt;
      }
    }
    
    // 獲取任務類型的名稱
    String getTaskTypeName() {
      switch (task.taskType) {
        case TaskType.exam:
          return locale.languageCode == 'zh' ? '考試' : 'Exam';
        case TaskType.homework:
          return locale.languageCode == 'zh' ? '作業' : 'Homework';
        case TaskType.project:
          return locale.languageCode == 'zh' ? '專案' : 'Project';
        case TaskType.reading:
          return locale.languageCode == 'zh' ? '閱讀' : 'Reading';
        case TaskType.meeting:
          return locale.languageCode == 'zh' ? '會議' : 'Meeting';
        case TaskType.reminder:
          return locale.languageCode == 'zh' ? '提醒' : 'Reminder';
        case TaskType.other:
          return locale.languageCode == 'zh' ? '其他' : 'Other';
      }
    }
    
    // 獲取課程顏色
    Color subjectColor;
    if (subject?.color != null) {
      if (subject!.color is int) {
        subjectColor = Color(subject.color as int);
      } else if (subject.color is String) {
        try {
          subjectColor = Color(int.parse((subject.color as String).replaceAll('#', '0xFF')));
        } catch (e) {
          subjectColor = AppColors.primaryLight;
        }
      } else {
        subjectColor = AppColors.primaryLight;
      }
    } else {
      subjectColor = AppColors.primaryLight;
    }
    
    return InkWell(
      onTap: () {
        // 導航到任務詳情
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 任務類型圖標
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                getTaskTypeIcon(),
                color: subjectColor,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 任務標題和時間
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (subject != null) ...[
                        Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: subjectColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      Text(
                        getTaskTypeName(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 時間
            Text(
              DateUtil.formatTime(task.dueDate),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 