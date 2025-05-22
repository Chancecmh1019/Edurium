import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import 'package:edurium/utils/constants.dart';
import 'package:edurium/utils/date_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _taskBox;
  List<Task> _tasks = [];
  List<String> _tags = [];
  Map<String, int> _tagCounts = {};
  
  TaskProvider() {
    _initBox();
  }
  
  Future<void> _initBox() async {
    _taskBox = await Hive.openBox<Task>('tasks');
    await _loadTasks();
    _updateTagStats();
  }
  
  // 獲取所有任務
  List<Task> get tasks => _tasks;
  
  // 獲取所有標籤
  List<String> get tags => _tags;
  
  // 獲取標籤統計
  Map<String, int> get tagCounts => _tagCounts;
  
  // 獲取未完成任務
  List<Task> get incompleteTasks => _tasks.where((task) => !task.isCompleted).toList();
  
  // 獲取已完成任務
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  
  // 獲取所有本周任務
  List<Task> getAllTasksThisWeek() {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return _tasks.where((task) {
      return task.dueDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
             task.dueDate.isBefore(endOfWeek);
    }).toList();
  }
  
  // 按日期獲取任務
  List<Task> getTasksByDate(DateTime date) {
    return _tasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
  }
  
  // 為日曆獲取特定日期的任務
  List<Task> getTasksForDay(DateTime date) {
    return _tasks.where((task) {
      return isSameDay(task.dueDate, date);
    }).toList();
  }
  
  // 按類型獲取任務
  List<Task> getTasksByType(TaskType type) {
    return _tasks.where((task) => task.taskType == type).toList();
  }
  
  // 按優先級獲取任務
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }
  
  // 按課程獲取任務
  List<Task> getTasksBySubject(String subjectId) {
    return _tasks.where((task) => task.subjectId == subjectId).toList();
  }
  
  // 按老師獲取任務
  List<Task> getTasksByTeacher(String teacherId) {
    return _tasks.where((task) => task.teacherId == teacherId).toList();
  }
  
  // 獲取即將到期的任務（未來7天）
  List<Task> getUpcomingTasksNoLimit() {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    
    return _tasks.where((task) {
      return !task.isCompleted && 
             task.dueDate.isAfter(now) && 
             task.dueDate.isBefore(sevenDaysLater);
    }).toList();
  }
  
  // 獲取今日任務
  List<Task> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _tasks.where((task) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return !task.isCompleted && 
             taskDate.isAtSameMomentAs(today);
    }).toList();
  }
  
  // 獲取逾期任務
  List<Task> getOverdueTasks({int? limit}) {
    final now = DateTime.now();
    
    var filteredTasks = _tasks.where((task) {
      return !task.isCompleted && task.dueDate.isBefore(now);
    }).toList();
    
    // 按日期排序 (最近過期的排在前面)
    filteredTasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    
    // 應用限制（如果有）
    if (limit != null && filteredTasks.length > limit) {
      return filteredTasks.take(limit).toList();
    }
    
    return filteredTasks;
  }
  
  // 加載所有任務
  Future<void> _loadTasks() async {
    _tasks = _taskBox.values.toList();
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }
  
  // 公共方法：加載所有任務
  Future<void> loadTasks() async {
    _loadTasks();
  }
  
  // 添加任務
  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
    _loadTasks();
    _updateTagStats();
  }
  
  // 獲取本週完成的任務
  List<Task> getCompletedTasksThisWeek() {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return _tasks.where((task) {
      return task.isCompleted && 
             task.dueDate.isAfter(startOfWeek) && 
             task.dueDate.isBefore(endOfWeek);
    }).toList();
  }
  
  // 添加缺失的方法：獲取指定日期範圍內的任務
  List<Task> getTasksForRange(DateTime start, DateTime end) {
    // 將日期標準化為僅包含年月日，不含時分秒
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    
    return _tasks.where((task) {
      final taskDate = task.dueDate;
      return taskDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
             taskDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  // 獲取即將到期的任務，帶有數量限制
  List<Task> getUpcomingTasks({int? limit}) {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    
    var filteredTasks = _tasks.where((task) {
      return !task.isCompleted && 
             task.dueDate.isAfter(now) && 
             task.dueDate.isBefore(sevenDaysLater);
    }).toList();
    
    // 按日期排序
    filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    
    // 應用限制（如果有）
    if (limit != null && filteredTasks.length > limit) {
      return filteredTasks.take(limit).toList();
    }
    
    return filteredTasks;
  }
  
  // 創建並添加新任務
  Future<Task> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskType taskType,
    TaskPriority priority = TaskPriority.medium,
    String? subjectId,
    String? teacherId,
    DateTime? reminderTime,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final task = Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      taskType: taskType,
      priority: priority,
      subjectId: subjectId,
      teacherId: teacherId,
      reminderTime: reminderTime,
      createdAt: now,
      updatedAt: now,
    );
    await addTask(task);
    return task;
  }
  
  // 更新任務
  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
    _loadTasks();
    _updateTagStats();
  }
  
  // 更新任務完成狀態
  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _taskBox.get(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    }
  }
  
  // 獲取指定ID的任務
  Task? getTaskById(String taskId) {
    return _taskBox.get(taskId);
  }
  
  // 刪除任務
  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
    _loadTasks();
    _updateTagStats();
  }
  
  // 批量刪除任務
  Future<void> deleteTasks(List<String> taskIds) async {
    for (final id in taskIds) {
      await _taskBox.delete(id);
    }
    _loadTasks();
    _updateTagStats();
  }
  
  // 清除所有任務
  Future<void> clearAllTasks() async {
    await _taskBox.clear();
    _loadTasks();
    _updateTagStats();
  }
  
  // 設置任務狀態
  Future<void> setTaskCompleted(Task task, bool isCompleted) async {
    task.isCompleted = isCompleted;
    await task.save();
    notifyListeners();
  }

  // 按任務狀態獲取任務
  List<Task> getTasksByStatus(bool isCompleted) {
    return _tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  // 搜索任務
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return [];
    
    query = query.toLowerCase();
    
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(query) || 
             (task.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // 更新標籤統計
  void _updateTagStats() {
    _tagCounts.clear();
    for (var task in _tasks) {
      for (var tag in task.tags) {
        _tagCounts[tag] = (_tagCounts[tag] ?? 0) + 1;
      }
    }
    _tags = _tagCounts.keys.toList()..sort();
    notifyListeners();
  }
}

// 檢查兩個日期是否為同一天
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
} 