import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  // ... (existing code)
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _selectedFilter = 'all';
  String _selectedSort = 'dueDate';
  List<String> _selectedTags = [];
  bool _showCompleted = false;
  bool _showImportant = false;
  TaskType? _selectedType;
  TaskPriority? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final isZh = Provider.of<LocaleProvider>(context).locale.languageCode == 'zh';
    
    List<Task> filteredTasks = taskProvider.tasks;

    // 應用過濾器
    if (_selectedFilter == 'today') {
      final today = DateTime.now();
      filteredTasks = filteredTasks.where((task) {
        return task.dueDate.year == today.year &&
               task.dueDate.month == today.month &&
               task.dueDate.day == today.day;
      }).toList();
    } else if (_selectedFilter == 'week') {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      filteredTasks = filteredTasks.where((task) {
        return task.dueDate.isAfter(weekStart) && task.dueDate.isBefore(weekEnd);
      }).toList();
    } else if (_selectedFilter == 'month') {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);
      filteredTasks = filteredTasks.where((task) {
        return task.dueDate.isAfter(monthStart) && task.dueDate.isBefore(monthEnd);
      }).toList();
    }

    // 應用標籤過濾
    if (_selectedTags.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) {
        return _selectedTags.every((tag) => task.tags.contains(tag));
      }).toList();
    }

    // 應用完成狀態過濾
    if (!_showCompleted) {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    }

    // 應用重要標記過濾
    if (_showImportant) {
      filteredTasks = filteredTasks.where((task) => task.isImportant).toList();
    }

    // 應用類型過濾
    if (_selectedType != null) {
      filteredTasks = filteredTasks.where((task) => task.type == _selectedType).toList();
    }

    // 應用優先級過濾
    if (_selectedPriority != null) {
      filteredTasks = filteredTasks.where((task) => task.priority == _selectedPriority).toList();
    }

    // 應用排序
    switch (_selectedSort) {
      case 'dueDate':
        filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'priority':
        filteredTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'type':
        filteredTasks.sort((a, b) => a.type.index.compareTo(b.type.index));
        break;
      case 'progress':
        filteredTasks.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'duration':
        filteredTasks.sort((a, b) => b.estimatedDuration.compareTo(a.estimatedDuration));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isZh ? '任務列表' : 'Task List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedTags.isNotEmpty || _showImportant || _selectedType != null || _selectedPriority != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._selectedTags.map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() {
                        _selectedTags.remove(tag);
                      });
                    },
                  )),
                  if (_showImportant)
                    Chip(
                      label: Text(isZh ? '重要' : 'Important'),
                      onDeleted: () {
                        setState(() {
                          _showImportant = false;
                        });
                      },
                    ),
                  if (_selectedType != null)
                    Chip(
                      label: Text(_getTaskTypeName(_selectedType!, isZh)),
                      onDeleted: () {
                        setState(() {
                          _selectedType = null;
                        });
                      },
                    ),
                  if (_selectedPriority != null)
                    Chip(
                      label: Text(_getPriorityName(_selectedPriority!, isZh)),
                      onDeleted: () {
                        setState(() {
                          _selectedPriority = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Text(
                      isZh ? '沒有找到任務' : 'No tasks found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(filteredTasks[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    final isZh = Provider.of<LocaleProvider>(context).locale.languageCode == 'zh';
    final taskProvider = Provider.of<TaskProvider>(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isZh ? '過濾任務' : 'Filter Tasks'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isZh ? '時間範圍' : 'Time Range',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(isZh ? '全部' : 'All'),
                    selected: _selectedFilter == 'all',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'all';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ChoiceChip(
                    label: Text(isZh ? '今天' : 'Today'),
                    selected: _selectedFilter == 'today',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'today';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ChoiceChip(
                    label: Text(isZh ? '本週' : 'This Week'),
                    selected: _selectedFilter == 'week',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'week';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ChoiceChip(
                    label: Text(isZh ? '本月' : 'This Month'),
                    selected: _selectedFilter == 'month',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = 'month';
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                isZh ? '標籤' : 'Tags',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: taskProvider.tagCounts.entries.map((entry) {
                  return FilterChip(
                    label: Text('${entry.key} (${entry.value})'),
                    selected: _selectedTags.contains(entry.key),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(entry.key);
                        } else {
                          _selectedTags.remove(entry.key);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                isZh ? '任務類型' : 'Task Type',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskType.values.map((type) {
                  return ChoiceChip(
                    label: Text(_getTaskTypeName(type, isZh)),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? type : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                isZh ? '優先級' : 'Priority',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((priority) {
                  return ChoiceChip(
                    label: Text(_getPriorityName(priority, isZh)),
                    selected: _selectedPriority == priority,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriority = selected ? priority : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(isZh ? '顯示已完成' : 'Show Completed'),
                value: _showCompleted,
                onChanged: (value) {
                  setState(() {
                    _showCompleted = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text(isZh ? '僅顯示重要' : 'Show Important Only'),
                value: _showImportant,
                onChanged: (value) {
                  setState(() {
                    _showImportant = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
                _selectedTags = [];
                _showCompleted = false;
                _showImportant = false;
                _selectedType = null;
                _selectedPriority = null;
              });
              Navigator.pop(context);
            },
            child: Text(isZh ? '重置' : 'Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isZh ? '關閉' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    final isZh = Provider.of<LocaleProvider>(context).locale.languageCode == 'zh';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isZh ? '排序方式' : 'Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(isZh ? '截止日期' : 'Due Date'),
              value: 'dueDate',
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(isZh ? '優先級' : 'Priority'),
              value: 'priority',
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(isZh ? '任務類型' : 'Task Type'),
              value: 'type',
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(isZh ? '學習進度' : 'Learning Progress'),
              value: 'progress',
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(isZh ? '預計時間' : 'Estimated Duration'),
              value: 'duration',
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isZh ? '關閉' : 'Close'),
          ),
        ],
      ),
    );
  }

  String _getTaskTypeName(TaskType type, bool isZh) {
    switch (type) {
      case TaskType.homework:
        return isZh ? '作業' : 'Homework';
      case TaskType.exam:
        return isZh ? '考試' : 'Exam';
      case TaskType.project:
        return isZh ? '專案' : 'Project';
      case TaskType.reminder:
        return isZh ? '提醒' : 'Reminder';
    }
  }

  String _getPriorityName(TaskPriority priority, bool isZh) {
    switch (priority) {
      case TaskPriority.low:
        return isZh ? '低' : 'Low';
      case TaskPriority.medium:
        return isZh ? '中' : 'Medium';
      case TaskPriority.high:
        return isZh ? '高' : 'High';
    }
  }

  Widget _buildTaskCard(Task task) {
    final isZh = Provider.of<LocaleProvider>(context).locale.languageCode == 'zh';
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    
    final subject = task.subjectId != null 
        ? subjectProvider.getSubjectById(task.subjectId!)
        : null;
    final teacher = task.teacherId != null
        ? teacherProvider.getTeacherById(task.teacherId!)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToTaskDetail(task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getTaskTypeIcon(task.type),
                    color: _getTaskTypeColor(task.type),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (task.isImportant)
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.yMMMd(isZh ? 'zh_TW' : 'en_US').format(task.dueDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.Hm(isZh ? 'zh_TW' : 'en_US').format(task.dueDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: task.tags.map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
              if (task.repeatType != RepeatType.none) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getRepeatTypeText(task.repeatType, task.repeatConfig, isZh),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
              if (task.estimatedDuration > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isZh 
                          ? '預計時間：${task.estimatedDuration}分鐘'
                          : 'Estimated: ${task.estimatedDuration}min',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
              if (task.progress > 0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(task.progress),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(task.progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
              if (subject != null || teacher != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (subject != null) ...[
                      Icon(
                        Icons.book,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subject.name,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (teacher != null) ...[
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        teacher.name ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getRepeatTypeText(RepeatType type, Map<String, dynamic>? config, bool isZh) {
    switch (type) {
      case RepeatType.daily:
        return isZh ? '每天重複' : 'Repeats daily';
      case RepeatType.weekly:
        return isZh ? '每週重複' : 'Repeats weekly';
      case RepeatType.monthly:
        return isZh ? '每月重複' : 'Repeats monthly';
      case RepeatType.custom:
        if (config != null) {
          final interval = config['interval'] as int;
          final unit = config['unit'] as String;
          final unitText = isZh
              ? (unit == 'days' ? '天' : unit == 'weeks' ? '週' : '月')
              : (unit == 'days' ? 'days' : unit == 'weeks' ? 'weeks' : 'months');
          return isZh
              ? '每$interval$unitText重複'
              : 'Repeats every $interval $unitText';
        }
        return isZh ? '自定義重複' : 'Custom repeat';
      default:
        return '';
    }
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // ... (rest of the existing code)
} 