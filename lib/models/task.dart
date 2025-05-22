import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'subject.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskType {
  @HiveField(0)
  homework,
  
  @HiveField(1)
  exam,
  
  @HiveField(2)
  project,
  
  @HiveField(3)
  reading,
  
  @HiveField(4)
  meeting,
  
  @HiveField(5)
  reminder,
  
  @HiveField(6)
  other
}

@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent
}

@HiveType(typeId: 2)
enum RepeatType {
  @HiveField(0)
  none,
  
  @HiveField(1)
  daily,
  
  @HiveField(2)
  weekly,
  
  @HiveField(3)
  monthly,
  
  @HiveField(4)
  custom
}

@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  TaskType taskType;
  
  @HiveField(4)
  DateTime dueDate;
  
  @HiveField(5)
  TaskPriority priority;
  
  @HiveField(6)
  String? subjectId;
  
  @HiveField(7)
  String? teacherId;
  
  @HiveField(8)
  DateTime? reminderTime;
  
  @HiveField(9)
  bool isCompleted;
  
  @HiveField(10)
  DateTime createdAt;
  
  @HiveField(11)
  DateTime updatedAt;
  
  @HiveField(12)
  List<String> tags;
  
  @HiveField(13)
  RepeatType repeatType;
  
  @HiveField(14)
  Map<String, dynamic>? repeatConfig;
  
  @HiveField(15)
  int estimatedDuration; // 預計完成時間（分鐘）
  
  @HiveField(16)
  int actualDuration; // 實際完成時間（分鐘）
  
  @HiveField(17)
  Map<String, dynamic>? learningGoals;
  
  @HiveField(18)
  double progress; // 學習進度（0-1）
  
  @HiveField(19)
  Map<String, dynamic>? extras;
  
  @HiveField(20)
  bool hasTime = false; // 是否有時間
  
  @HiveField(21)
  bool hasAttachments = false; // 是否有附件
  
  @HiveField(22)
  String? subjectName; // 科目名稱，用於顯示
  
  @HiveField(23)
  int? duration; // 任務持續時間（分鐘），用於計算結束時間
  
  Subject? _subject;
  
  Subject? get subject => _subject;
  
  set subject(Subject? value) {
    _subject = value;
  }
  
  // 判斷任務是否已過期
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    return dueDate.isBefore(now);
  }
  
  Task({
    required this.id,
    required this.title,
    this.description,
    required this.taskType,
    required this.dueDate,
    required this.priority,
    this.subjectId,
    this.teacherId,
    this.reminderTime,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    List<String>? tags,
    this.repeatType = RepeatType.none,
    this.repeatConfig,
    this.estimatedDuration = 0,
    this.actualDuration = 0,
    this.learningGoals,
    this.progress = 0.0,
    this.extras,
    this.hasTime = false,
    this.hasAttachments = false,
    this.subjectName,
    this.duration,
    bool? isImportant,
  }) : tags = tags ?? [];
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? taskType,
    DateTime? dueDate,
    TaskPriority? priority,
    String? subjectId,
    String? teacherId,
    DateTime? reminderTime,
    bool? isCompleted,
    List<String>? tags,
    RepeatType? repeatType,
    Map<String, dynamic>? repeatConfig,
    int? estimatedDuration,
    int? actualDuration,
    Map<String, dynamic>? learningGoals,
    double? progress,
    Map<String, dynamic>? extras,
    bool? hasTime,
    bool? hasAttachments,
    String? subjectName,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
      repeatType: repeatType ?? this.repeatType,
      repeatConfig: repeatConfig ?? this.repeatConfig,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      learningGoals: learningGoals ?? this.learningGoals,
      progress: progress ?? this.progress,
      extras: extras ?? this.extras,
      hasTime: hasTime ?? this.hasTime,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      subjectName: subjectName ?? this.subjectName,
      duration: duration ?? this.duration,
    );
  }
  
  @override
  String toString() {
    return 'Task{id: $id, title: $title, dueDate: $dueDate, isCompleted: $isCompleted}';
  }
  
  // 計算學習效率
  double get learningEfficiency {
    if (estimatedDuration == 0 || actualDuration == 0) return 0.0;
    return estimatedDuration / actualDuration;
  }
  
  // 檢查是否需要重複
  bool get needsRepeat {
    if (repeatType == RepeatType.none) return false;
    if (!isCompleted) return false;
    
    final now = DateTime.now();
    switch (repeatType) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return now.difference(dueDate).inDays >= 7;
      case RepeatType.monthly:
        return now.difference(dueDate).inDays >= 30;
      case RepeatType.custom:
        if (repeatConfig == null) return false;
        final interval = repeatConfig!['interval'] as int;
        final unit = repeatConfig!['unit'] as String;
        switch (unit) {
          case 'days':
            return now.difference(dueDate).inDays >= interval;
          case 'weeks':
            return now.difference(dueDate).inDays >= interval * 7;
          case 'months':
            return now.difference(dueDate).inDays >= interval * 30;
          default:
            return false;
        }
      default:
        return false;
    }
  }
  
  // 生成下一個重複任務
  Task? generateNextRepeatTask() {
    if (!needsRepeat) return null;

    final nextDueDate = _calculateNextDueDate();
    if (nextDueDate == null) return null;

    return copyWith(
      id: const Uuid().v4(),
      dueDate: nextDueDate,
      isCompleted: false,
      actualDuration: 0,
      progress: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  DateTime? _calculateNextDueDate() {
    final now = DateTime.now();
    switch (repeatType) {
      case RepeatType.daily:
        return DateTime(now.year, now.month, now.day + 1);
      case RepeatType.weekly:
        return DateTime(now.year, now.month, now.day + 7);
      case RepeatType.monthly:
        return DateTime(now.year, now.month + 1, now.day);
      case RepeatType.custom:
        if (repeatConfig == null) return null;
        final interval = repeatConfig!['interval'] as int;
        final unit = repeatConfig!['unit'] as String;
        switch (unit) {
          case 'days':
            return DateTime(now.year, now.month, now.day + interval);
          case 'weeks':
            return DateTime(now.year, now.month, now.day + interval * 7);
          case 'months':
            return DateTime(now.year, now.month + interval, now.day);
          default:
            return null;
        }
      default:
        return null;
    }
  }
} 