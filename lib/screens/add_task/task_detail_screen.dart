import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/models/task.dart';
import 'package:edurium/providers/task_provider.dart';
import 'package:edurium/providers/subject_provider.dart';
import 'package:edurium/utils/date_util.dart';
import 'package:edurium/screens/add_task/add_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final task = taskProvider.getTaskById(taskId);
    
    if (task == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('任務不存在'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '找不到該任務，可能已被刪除',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }
    
    final subject = task.subjectId != null ? subjectProvider.getSubjectById(task.subjectId!) : null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('任務詳情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '編輯任務',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(taskToEdit: task),
                ),
              );
              
              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('任務已更新'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '刪除任務',
            onPressed: () => _showDeleteConfirmation(context, task),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 任務標題和狀態
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (task.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '已完成',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 任務基本信息
              _buildInfoCard(
                context: context,
                title: '基本信息',
                children: [
                  _buildInfoRow(
                    context: context, 
                    icon: Icons.category, 
                    label: '類型', 
                    value: _getTaskTypeName(task.taskType),
                  ),
                  _buildInfoRow(
                    context: context, 
                    icon: Icons.bookmark, 
                    label: '優先級', 
                    value: _getPriorityName(task.priority),
                    valueColor: _getPriorityColor(task.priority, context),
                  ),
                  if (subject != null)
                    _buildInfoRow(
                      context: context, 
                      icon: Icons.book, 
                      label: '科目', 
                      value: subject.name,
                      onTap: () {
                        // TODO: 導航到科目詳情頁面
                      },
                    ),
                  _buildInfoRow(
                    context: context, 
                    icon: Icons.calendar_today, 
                    label: '截止日期', 
                    value: DateUtil.formatDateTime(task.dueDate),
                    valueColor: task.dueDate.isBefore(DateTime.now()) && !task.isCompleted
                        ? theme.colorScheme.error
                        : null,
                  ),
                  if (task.reminderTime != null)
                    _buildInfoRow(
                      context: context, 
                      icon: Icons.notifications, 
                      label: '提醒時間', 
                      value: DateUtil.formatDateTime(task.reminderTime!),
                    ),
                  _buildInfoRow(
                    context: context, 
                    icon: Icons.check_circle, 
                    label: '完成狀態', 
                    value: task.isCompleted ? '已完成' : '未完成',
                    valueColor: task.isCompleted 
                        ? theme.colorScheme.tertiary 
                        : theme.colorScheme.error,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 標籤
              if (task.tags.isNotEmpty)
                _buildInfoCard(
                  context: context,
                  title: '標籤',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: task.tags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // 重複設置
              if (task.repeatType != RepeatType.none)
                _buildInfoCard(
                  context: context,
                  title: '重複設置',
                  children: [
                    _buildInfoRow(
                      context: context,
                      icon: Icons.repeat,
                      label: '重複類型',
                      value: _getRepeatTypeName(task.repeatType),
                    ),
                    if (task.repeatConfig != null)
                      _buildInfoRow(
                        context: context,
                        icon: Icons.settings,
                        label: '重複配置',
                        value: _formatRepeatConfig(task.repeatConfig!),
                      ),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // 學習追蹤
              _buildInfoCard(
                context: context,
                title: '學習追蹤',
                children: [
                  if (task.estimatedDuration > 0)
                    _buildInfoRow(
                      context: context,
                      icon: Icons.timer,
                      label: '預計時間',
                      value: '${task.estimatedDuration} 分鐘',
                    ),
                  if (task.actualDuration > 0)
                    _buildInfoRow(
                      context: context,
                      icon: Icons.timer_outlined,
                      label: '實際時間',
                      value: '${task.actualDuration} 分鐘',
                    ),
                  if (task.actualDuration > 0 && task.estimatedDuration > 0)
                    _buildInfoRow(
                      context: context,
                      icon: Icons.speed,
                      label: '學習效率',
                      value: '${(task.learningEfficiency * 100).toStringAsFixed(1)}%',
                      valueColor: _getEfficiencyColor(task.learningEfficiency, context),
                    ),
                  if (task.learningGoals != null)
                    _buildInfoRow(
                      context: context,
                      icon: Icons.flag,
                      label: '學習目標',
                      value: _formatLearningGoals(task.learningGoals!),
                    ),
                  _buildInfoRow(
                    context: context,
                    icon: Icons.trending_up,
                    label: '學習進度',
                    value: '${(task.progress * 100).toStringAsFixed(1)}%',
                    valueColor: _getProgressColor(task.progress, context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 任務描述
              if (task.description != null && task.description!.isNotEmpty) ...[
                _buildInfoCard(
                  context: context,
                  title: '任務描述',
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        task.description!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // 快捷操作
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '快捷操作',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            context: context,
                            icon: task.isCompleted ? Icons.replay : Icons.check_circle,
                            label: task.isCompleted ? '標記為未完成' : '標記為已完成',
                            onTap: () {
                              _toggleTaskCompletion(context, task);
                            },
                            color: task.isCompleted ? colorScheme.primary : colorScheme.tertiary,
                          ),
                          _buildActionButton(
                            context: context,
                            icon: Icons.edit,
                            label: '編輯任務',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTaskScreen(taskToEdit: task),
                                ),
                              );
                            },
                            color: colorScheme.primary,
                          ),
                          _buildActionButton(
                            context: context,
                            icon: Icons.delete,
                            label: '刪除任務',
                            onTap: () {
                              _showDeleteConfirmation(context, task);
                            },
                            color: colorScheme.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _toggleTaskCompletion(BuildContext context, Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.toggleTaskCompletion(task.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(task.isCompleted ? '已將任務標記為未完成' : '已將任務標記為已完成'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除任務'),
        content: Text('確定要刪除 "${task.title}" 嗎？這個操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask(context, task);
            },
            child: const Text('刪除'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
  
  void _deleteTask(BuildContext context, Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.deleteTask(task.id);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('任務已刪除'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  String _getTaskTypeName(TaskType type) {
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
  
  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return '低';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.high:
        return '高';
      case TaskPriority.urgent:
        return '緊急';
    }
  }
  
  Color _getPriorityColor(TaskPriority priority, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return colorScheme.error;
      case TaskPriority.urgent:
        return Colors.deepPurple;
    }
  }
  
  String _getRepeatTypeName(RepeatType type) {
    switch (type) {
      case RepeatType.none:
        return '不重複';
      case RepeatType.daily:
        return '每天';
      case RepeatType.weekly:
        return '每週';
      case RepeatType.monthly:
        return '每月';
      case RepeatType.custom:
        return '自定義';
    }
  }

  String _formatRepeatConfig(Map<String, dynamic> config) {
    final interval = config['interval'] as int;
    final unit = config['unit'] as String;
    switch (unit) {
      case 'days':
        return '每 $interval 天';
      case 'weeks':
        return '每 $interval 週';
      case 'months':
        return '每 $interval 月';
      default:
        return '自定義重複';
    }
  }

  String _formatLearningGoals(Map<String, dynamic> goals) {
    final List<String> formattedGoals = [];
    goals.forEach((key, value) {
      formattedGoals.add('$key: $value');
    });
    return formattedGoals.join('\n');
  }

  Color _getEfficiencyColor(double efficiency, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (efficiency >= 1.2) return Colors.green;
    if (efficiency >= 0.8) return Colors.orange;
    return colorScheme.error;
  }

  Color _getProgressColor(double progress, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return colorScheme.error;
  }
} 