import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../widgets/widgets.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/utils.dart';
import 'package:edurium/models/task.dart';
import 'package:edurium/providers/locale_provider.dart';
import 'package:edurium/utils/date_util.dart';
import 'package:edurium/widgets/task_card.dart';

class TodayTasksSection extends StatelessWidget {
  final List<Task> tasks;
  final List<Task> overdueTasks;

  const TodayTasksSection({
    Key? key,
    required this.tasks,
    required this.overdueTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final String sectionTitle = locale.languageCode == 'zh' ? '今日待辦' : 'Today\'s Tasks';
    final String noTasksText = locale.languageCode == 'zh' 
        ? '今天沒有待辦事項' 
        : 'No tasks for today';
    final String overdueText = locale.languageCode == 'zh' 
        ? '逾期待辦' 
        : 'Overdue Tasks';
    final String viewAllText = locale.languageCode == 'zh' 
        ? '查看全部' 
        : 'View All';
    
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
            if (tasks.isNotEmpty || overdueTasks.isNotEmpty)
              TextButton(
                onPressed: () {
                  // 導航到任務列表
                },
                child: Text(
                  viewAllText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // 逾期任務
        if (overdueTasks.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      overdueText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${overdueTasks.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 顯示最多3個逾期任務
                ...overdueTasks.take(3).map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${DateUtil.daysBetween(task.dueDate, DateTime.now())}${locale.languageCode == 'zh' ? '天前' : ' days ago'}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                if (overdueTasks.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      locale.languageCode == 'zh'
                          ? '還有 ${overdueTasks.length - 3} 個逾期項目'
                          : '${overdueTasks.length - 3} more overdue items',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
        
        // 今日任務
        if (tasks.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.check_circle_outline,
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
              for (int i = 0; i < tasks.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == tasks.length - 1 ? 0 : 12),
                  child: TaskCard(
                    task: tasks[i],
                    onTap: () {
                      // 導航到任務詳情
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
} 