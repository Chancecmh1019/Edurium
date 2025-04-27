import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../utils/constants.dart' as utils;
import '../utils/date_util.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // 任務顏色
    Color getTaskColor() {
      switch (task.taskType) {
        case TaskType.homework:
          return utils.AppColorConstants.homeworkColor;
        case TaskType.exam:
          return utils.AppColorConstants.examColor;
        case TaskType.project:
          return utils.AppColorConstants.projectColor;
        case TaskType.reading:
          return utils.AppColorConstants.readingColor;
        case TaskType.meeting:
          return utils.AppColorConstants.meetingColor;
        case TaskType.reminder:
          return utils.AppColorConstants.reminderColor;
        case TaskType.other:
          return utils.AppColorConstants.otherColor;
      }
    }
    
    // 任務圖標
    IconData getTaskIcon() {
      switch (task.taskType) {
        case TaskType.homework:
          return Icons.assignment;
        case TaskType.exam:
          return Icons.note_alt;
        case TaskType.project:
          return Icons.science;
        case TaskType.reading:
          return Icons.menu_book;
        case TaskType.meeting:
          return Icons.people;
        case TaskType.reminder:
          return Icons.notifications;
        case TaskType.other:
          return Icons.checklist;
      }
    }
    
    final taskColor = getTaskColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: task.isCompleted 
              ? Colors.grey.withOpacity(0.3) 
              : taskColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 任務類型圖標
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: task.isCompleted 
                      ? Colors.grey.withOpacity(0.2) 
                      : taskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  getTaskIcon(),
                  color: task.isCompleted ? Colors.grey : taskColor,
                  size: 22,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 任務標題和到期日期
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                        color: task.isCompleted 
                            ? Colors.grey 
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateUtil.formatDateFriendly(task.dueDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 完成按鈕
              if (onComplete != null)
                IconButton(
                  icon: Icon(
                    task.isCompleted 
                        ? Icons.check_circle 
                        : Icons.radio_button_unchecked,
                    color: task.isCompleted 
                        ? Colors.green 
                        : Colors.grey,
                  ),
                  onPressed: onComplete,
                  tooltip: task.isCompleted ? '標記為未完成' : '標記為完成',
                ),
              
              // 刪除按鈕
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: '刪除任務',
                ),
            ],
          ),
        ),
      ),
    );
  }
} 