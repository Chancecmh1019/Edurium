import 'package:hive/hive.dart';

part 'task_model.g.dart';

enum TaskType {
  exam,     // 考試
  homework, // 作業
  project,  // 專案
  meeting,  // 會議
  reminder  // 提醒
}

enum TaskPriority {
  low,     // 低
  medium,  // 中
  high     // 高
}

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime dueDate;
  
  @HiveField(4)
  final TaskType type;
  
  @HiveField(5)
  final TaskPriority priority;
  
  @HiveField(6)
  final bool isCompleted;
  
  @HiveField(7)
  final String? subjectId; // 相關課程ID
  
  @HiveField(8)
  final String? teacherId; // 相關老師ID
  
  @HiveField(9)
  final DateTime createdAt;
  
  @HiveField(10)
  final DateTime? reminderTime; // 提醒時間
  
  @HiveField(11)
  final double? score; // 成績分數
  
  @HiveField(12)
  final Map<String, dynamic>? extras; // 額外資訊
  
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.type,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.subjectId,
    this.teacherId,
    DateTime? createdAt,
    this.reminderTime,
    this.score,
    this.extras,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskType? type,
    TaskPriority? priority,
    bool? isCompleted,
    String? subjectId,
    String? teacherId,
    DateTime? createdAt,
    DateTime? reminderTime,
    double? score,
    Map<String, dynamic>? extras,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      score: score ?? this.score,
      extras: extras ?? this.extras,
    );
  }
} 