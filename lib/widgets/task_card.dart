import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import 'common/app_card.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showSubject;
  final bool showTeacher;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onLongPress,
    this.showSubject = true,
    this.showTeacher = false,
  });

  // 獲取任務類型的圖標
  IconData _getTaskTypeIcon() {
    switch (task.taskType) {
      case TaskType.exam:
        return Icons.note_alt_rounded;
      case TaskType.homework:
        return Icons.assignment_rounded;
      case TaskType.project:
        return Icons.science_rounded;
      case TaskType.reading:
        return Icons.menu_book_rounded;
      case TaskType.meeting:
        return Icons.people_alt_rounded;
      case TaskType.reminder:
        return Icons.notifications_rounded;
      case TaskType.other:
        return Icons.checklist_rounded;
    }
  }

  // 獲取任務類型的名稱
  String _getTaskTypeName(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    
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

  // 顯示距離截止日期還有多久
  Widget _buildDueDate(BuildContext context) {
    final now = DateTime.now();
    final dueDate = task.dueDate;
    final difference = dueDate.difference(now);
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    final colorScheme = Theme.of(context).colorScheme;
    
    Color textColor;
    String text;
    
    if (task.isCompleted) {
      textColor = Colors.grey;
      text = locale.languageCode == 'zh' ? '已完成' : 'Completed';
    } else if (difference.isNegative) {
      // 已逾期
      final days = difference.inDays.abs();
      textColor = colorScheme.error;
      
      if (days == 0) {
        text = locale.languageCode == 'zh' ? '今天逾期' : 'Overdue today';
      } else {
        text = locale.languageCode == 'zh' 
            ? '逾期$days天' 
            : 'Overdue by $days ${days == 1 ? 'day' : 'days'}';
      }
    } else {
      // 尚未逾期
      final days = difference.inDays;
      
      if (days == 0) {
        textColor = colorScheme.error;
        text = locale.languageCode == 'zh' ? '今天截止' : 'Due today';
      } else if (days == 1) {
        textColor = colorScheme.tertiary;
        text = locale.languageCode == 'zh' ? '明天截止' : 'Due tomorrow';
      } else if (days < 7) {
        textColor = colorScheme.tertiary;
        text = locale.languageCode == 'zh' 
            ? '$days天後截止' 
            : 'Due in $days days';
      } else {
        textColor = colorScheme.primary;
        text = DateUtil.formatDateFriendly(dueDate, locale: locale);
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_rounded,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 獲取課程和老師信息
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final subject = task.subjectId != null ? subjectProvider.getSubjectById(task.subjectId!) : null;
    final teacher = task.teacherId != null ? teacherProvider.getTeacherById(task.teacherId!) : null;
    final colorScheme = Theme.of(context).colorScheme;
    
    // 獲取課程顏色
    Color subjectColor;
    if (subject?.color != null) {
      if (subject!.color is int) {
        subjectColor = Color(subject.color as int);
      } else if (subject.color is String) {
        try {
          subjectColor = Color(int.parse((subject.color as String).replaceAll('#', '0xFF')));
        } catch (e) {
          subjectColor = colorScheme.primary;
        }
      } else {
        subjectColor = colorScheme.primary;
      }
    } else {
      subjectColor = colorScheme.primary;
    }
    
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      color: task.isCompleted ? colorScheme.surfaceVariant.withOpacity(0.5) : null,
      borderColor: task.isCompleted ? colorScheme.outline.withOpacity(0.3) : null,
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 任務狀態和類型
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: task.isCompleted 
                      ? colorScheme.surfaceVariant
                      : subjectColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getTaskTypeIcon(),
                    color: task.isCompleted ? colorScheme.outline : subjectColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // 任務標題和描述
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 任務標題行
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted 
                                ? colorScheme.onSurfaceVariant.withOpacity(0.8)
                                : colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    if (task.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: task.isCompleted ? colorScheme.onSurfaceVariant.withOpacity(0.7) : colorScheme.onSurfaceVariant,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // 標籤和截止日期
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // 課程標籤
                        if (showSubject && subject != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: task.isCompleted 
                                ? colorScheme.surfaceVariant
                                : subjectColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              subject.name,
                              style: TextStyle(
                                color: task.isCompleted 
                                  ? colorScheme.onSurfaceVariant.withOpacity(0.8)
                                  : subjectColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        
                        // 老師標籤
                        if (showTeacher && teacher != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              teacher.name,
                              style: TextStyle(
                                color: colorScheme.onTertiaryContainer,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        
                        // 類型標籤
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: task.isCompleted 
                                ? colorScheme.surfaceVariant
                                : colorScheme.secondaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTaskTypeName(context),
                            style: TextStyle(
                              color: task.isCompleted 
                                ? colorScheme.onSurfaceVariant.withOpacity(0.8)
                                : colorScheme.onSecondaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 截止時間
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildDueDate(context),
            ],
          ),
        ],
      ),
    );
  }
}