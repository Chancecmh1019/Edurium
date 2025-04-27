import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:edurium/providers/task_provider.dart' hide isSameDay;
import 'package:edurium/models/task.dart';
import 'package:edurium/utils/date_utils.dart' as app_date_utils;
import 'package:edurium/widgets/calendar/calendar_event_list.dart';
import 'package:edurium/utils/navigation_handler.dart';

// 視圖模式枚舉
enum CalendarViewMode {
  calendar,
  list
}

enum CalendarViewType {
  day,
  week,
  month,
  schedule
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarViewMode _viewMode = CalendarViewMode.calendar;
  CalendarViewType _calendarViewType = CalendarViewType.month;
  
  // 控制器用於滾動到特定時間點
  final ScrollController _timeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    
    // 滾動到當前時間
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_calendarViewType == CalendarViewType.day) {
        _scrollToCurrentTime();
      }
    });
  }
  
  @override
  void dispose() {
    _timeScrollController.dispose();
    super.dispose();
  }
  
  // 滾動到當前時間
  void _scrollToCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    if (_timeScrollController.hasClients) {
      _timeScrollController.animateTo(
        hour * 60.0, // 假設每小時高度為60
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '行事曆',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('yyyy年M月').format(_focusedDay),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        centerTitle: false,
        scrolledUnderElevation: 0,
        actions: [
          // 今天按鈕
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: '今天',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _focusedDay;
                if (_calendarViewType == CalendarViewType.day) {
                  _scrollToCurrentTime();
                }
              });
            },
          ),
          
          // 搜尋按鈕
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜尋',
            onPressed: () {
              // 顯示搜尋對話框
              showSearch(
                context: context,
                delegate: CalendarSearchDelegate(
                  taskProvider: Provider.of<TaskProvider>(context, listen: false),
                ),
              );
            },
          ),
          
          // 視圖選擇器
          PopupMenuButton<CalendarViewType>(
            icon: const Icon(Icons.view_agenda),
            tooltip: '切換視圖',
            onSelected: (CalendarViewType viewType) {
              setState(() {
                _calendarViewType = viewType;
                
                switch (viewType) {
                  case CalendarViewType.day:
                    _calendarFormat = CalendarFormat.week;
                    _viewMode = CalendarViewMode.calendar;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToCurrentTime();
                    });
                    break;
                  case CalendarViewType.week:
                    _calendarFormat = CalendarFormat.week;
                    _viewMode = CalendarViewMode.calendar;
                    break;
                  case CalendarViewType.month:
                    _calendarFormat = CalendarFormat.month;
                    _viewMode = CalendarViewMode.calendar;
                    break;
                  case CalendarViewType.schedule:
                    _viewMode = CalendarViewMode.list;
                    break;
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<CalendarViewType>>[
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.day,
                child: Text('日視圖'),
              ),
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.week,
                child: Text('週視圖'),
              ),
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.month,
                child: Text('月視圖'),
              ),
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.schedule,
                child: Text('行程視圖'),
              ),
            ],
          ),
          
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          if (_viewMode == CalendarViewMode.calendar) _buildCalendar(),
          Expanded(
            child: _calendarViewType == CalendarViewType.day
                ? _buildDayView()
                : _buildEventList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 導航到新增任務頁面，預設設置選中的日期
          NavigationHandler.navigateTo(
            context, 
            '/add_task',
            arguments: _selectedDay ?? _focusedDay,
          );
        },
        tooltip: '新增行程',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  // 構建事件列表
  Widget _buildEventList() {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.getTasksForDay(_selectedDay ?? _focusedDay);
    
    if (tasks.isEmpty) {
      return const Center(
        child: Text('沒有待辦事項'),
      );
    }
    
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(task, context);
      },
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            app_date_utils.AppDateUtils.formatMonthYear(_focusedDay),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    if (_calendarViewType == CalendarViewType.day) {
                      _focusedDay = _focusedDay.subtract(const Duration(days: 1));
                      _selectedDay = _focusedDay;
                    } else if (_calendarViewType == CalendarViewType.week) {
                      _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                      _selectedDay = _focusedDay;
                    } else {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    if (_calendarViewType == CalendarViewType.day) {
                      _focusedDay = _focusedDay.add(const Duration(days: 1));
                      _selectedDay = _focusedDay;
                    } else if (_calendarViewType == CalendarViewType.week) {
                      _focusedDay = _focusedDay.add(const Duration(days: 7));
                      _selectedDay = _focusedDay;
                    } else {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                if (_calendarViewType == CalendarViewType.day) {
                  _calendarViewType = CalendarViewType.day;
                }
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerSize: 6.0,
              markersMaxCount: 3,
              weekendTextStyle: const TextStyle(color: Colors.red),
              outsideDaysVisible: _calendarFormat == CalendarFormat.month,
            ),
            eventLoader: (day) {
              return taskProvider.getTasksForDay(day);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildEventIcons(events, context),
                  ),
                );
              },
            ),
            availableCalendarFormats: const {
              CalendarFormat.month: '月',
              CalendarFormat.week: '週',
            },
          ),
        );
      },
    );
  }
  
  Widget _buildDayView() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // 獲取當日事件
        final tasks = taskProvider.getTasksForDay(_selectedDay ?? _focusedDay);
        
        // 按照時間排序
        tasks.sort((a, b) {
          if (a is Task && b is Task) {
            return a.dueDate.compareTo(b.dueDate);
          }
          return 0;
        });
        
        // 按小時分組
        final Map<int, List<Task>> hourlyTasks = {};
        for (int i = 0; i < 24; i++) {
          hourlyTasks[i] = [];
        }
        
        for (var task in tasks) {
          if (task is Task) {
            final hour = task.dueDate.hour;
            hourlyTasks[hour]?.add(task);
          }
        }
        
        // 創建時間表視圖
        return ListView.builder(
          controller: _timeScrollController,
          itemCount: 24,
          itemBuilder: (context, hour) {
            final tasksAtHour = hourlyTasks[hour] ?? [];
            final isCurrentHour = DateTime.now().hour == hour && 
                                 isSameDay(DateTime.now(), _selectedDay ?? _focusedDay);
            
            return Column(
              children: [
                // 小時標題
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isCurrentHour 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentHour 
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                      ),
                      
                      // 當前時間指示器
                      if (isCurrentHour)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // 事件列表
                ...tasksAtHour.map((task) => _buildTaskItem(task, context)).toList(),
                
                // 小時分隔線
                const Divider(height: 1),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildTaskItem(Task task, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // 獲取任務顏色
    Color taskColor;
    switch (task.taskType) {
      case TaskType.homework:
        taskColor = theme.colorScheme.primary;
        break;
      case TaskType.exam:
        taskColor = theme.colorScheme.error;
        break;
      case TaskType.project:
        taskColor = theme.colorScheme.tertiary;
        break;
      default:
        taskColor = theme.colorScheme.secondary;
    }
    
    return Container(
      margin: const EdgeInsets.fromLTRB(60, 0, 16, 8),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? taskColor.withOpacity(0.3)
            : taskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: taskColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(
          _getTaskIcon(task.taskType),
          color: taskColor,
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.subjectId != null && task.subjectId!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('科目: ${task.subjectName ?? task.subjectId}'),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${DateFormat('HH:mm').format(task.dueDate)} - ${task.duration != null ? DateFormat('HH:mm').format(task.dueDate.add(Duration(minutes: task.duration!))) : '未設定結束時間'}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: () {
          // 顯示任務詳情
          // 在這裡實現任務詳情對話框
        },
      ),
    );
  }
  
  List<Widget> _buildEventIcons(List<dynamic> events, BuildContext context) {
    // 對任務進行分類
    final Map<TaskType, int> taskTypeCounts = {};
    
    for (var event in events) {
      if (event is Task) {
        taskTypeCounts[event.taskType] = (taskTypeCounts[event.taskType] ?? 0) + 1;
      }
    }
    
    // 顯示不超過3種任務類型的圖標
    final displayTaskTypes = taskTypeCounts.keys.take(3).toList();
    
    return displayTaskTypes.map((taskType) {
      return Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: _getTaskColor(taskType, context),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            _getTaskIcon(taskType),
            size: 8,
            color: Colors.white,
          ),
        ),
      );
    }).toList();
  }
  
  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.homework:
        return Icons.assignment;
      case TaskType.exam:
        return Icons.quiz;
      case TaskType.project:
        return Icons.work;
      case TaskType.reading:
        return Icons.menu_book;
      case TaskType.meeting:
        return Icons.people_outline;
      case TaskType.reminder:
        return Icons.notifications_outlined;
      case TaskType.other:
        return Icons.event;
    }
  }
  
  Color _getTaskColor(TaskType type, BuildContext context) {
    final theme = Theme.of(context);
    
    switch (type) {
      case TaskType.homework:
        return theme.colorScheme.primary;
      case TaskType.exam:
        return theme.colorScheme.error;
      case TaskType.project:
        return theme.colorScheme.tertiary;
      case TaskType.reading:
        return Colors.green;
      case TaskType.meeting:
        return Colors.purple;
      case TaskType.reminder:
        return Colors.orange;
      case TaskType.other:
        return theme.colorScheme.secondary;
    }
  }
}

// 行事曆搜尋代理
class CalendarSearchDelegate extends SearchDelegate<String> {
  final TaskProvider taskProvider;
  
  CalendarSearchDelegate({required this.taskProvider});
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // 過濾符合搜尋條件的任務
    final results = taskProvider.searchTasks(query);
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final task = results[index];
        return ListTile(
          leading: Icon(_getTaskIcon(task.taskType)),
          title: Text(task.title),
          subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(task.dueDate)),
          onTap: () {
            // 導航到任務詳情或者選擇該日期
            close(context, task.id);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // 過濾符合搜尋條件的任務
    final results = taskProvider.searchTasks(query);
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final task = results[index];
        return ListTile(
          leading: Icon(_getTaskIcon(task.taskType)),
          title: Text(task.title),
          subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(task.dueDate)),
          onTap: () {
            // 導航到任務詳情或者選擇該日期
            close(context, task.id);
          },
        );
      },
    );
  }
  
  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.homework:
        return Icons.assignment;
      case TaskType.exam:
        return Icons.quiz;
      case TaskType.project:
        return Icons.work;
      case TaskType.reading:
        return Icons.menu_book;
      case TaskType.meeting:
        return Icons.people_outline;
      case TaskType.reminder:
        return Icons.notifications_outlined;
      case TaskType.other:
        return Icons.event;
    }
  }
} 