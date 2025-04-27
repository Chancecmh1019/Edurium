import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'subject.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
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

@HiveType(typeId: 2)
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

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  DateTime dueDate;
  
  @HiveField(4)
  bool isCompleted;
  
  @HiveField(5)
  TaskType taskType;
  
  @HiveField(6)
  TaskPriority priority;
  
  @HiveField(7)
  String? subjectId;
  
  @HiveField(8)
  String? teacherId;
  
  @HiveField(9)
  DateTime? reminderTime;
  
  @HiveField(10)
  DateTime createdAt;
  
  @HiveField(11)
  DateTime? updatedAt;
  
  @HiveField(12)
  bool isRecurring;
  
  @HiveField(13)
  int? recurringInterval; // 以天為單位
  
  @HiveField(14)
  DateTime? completedAt;
  
  @HiveField(15)
  bool isArchived;
  
  @HiveField(16)
  String? notes;
  
  @HiveField(17)
  List<String>? tags;
  
  @HiveField(18)
  String? attachmentPath;
  
  @HiveField(19)
  String? subjectName; // 科目名稱，用於顯示
  
  @HiveField(20)
  int? duration; // 任務持續時間（分鐘），用於計算結束時間
  
  @HiveField(21)
  Map<String, dynamic>? extras; // 額外屬性
  
  @HiveField(22)
  bool hasTime = false; // 是否有時間
  
  @HiveField(23)
  bool hasAttachments = false; // 是否有附件
  
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
    String? id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.taskType = TaskType.other,
    this.priority = TaskPriority.medium,
    this.subjectId,
    this.teacherId,
    this.reminderTime,
    DateTime? createdAt,
    this.updatedAt,
    this.isRecurring = false,
    this.recurringInterval,
    this.completedAt,
    this.isArchived = false,
    this.notes,
    this.tags,
    this.attachmentPath,
    this.subjectName,
    this.duration,
    this.extras,
    this.hasTime = false,
    this.hasAttachments = false,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TaskType? taskType,
    TaskPriority? priority,
    String? subjectId,
    String? teacherId,
    DateTime? reminderTime,
    DateTime? updatedAt,
    bool? isRecurring,
    int? recurringInterval,
    DateTime? completedAt,
    bool? isArchived,
    String? notes,
    List<String>? tags,
    String? attachmentPath,
    String? subjectName,
    int? duration,
    Map<String, dynamic>? extras,
    bool? hasTime,
    bool? hasAttachments,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      taskType: taskType ?? this.taskType,
      priority: priority ?? this.priority,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      completedAt: completedAt ?? (isCompleted == true && this.completedAt == null ? DateTime.now() : this.completedAt),
      isArchived: isArchived ?? this.isArchived,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      subjectName: subjectName ?? this.subjectName,
      duration: duration ?? this.duration,
      extras: extras ?? this.extras,
      hasTime: hasTime ?? this.hasTime,
      hasAttachments: hasAttachments ?? this.hasAttachments,
    );
  }
  
  @override
  String toString() {
    return 'Task{id: $id, title: $title, dueDate: $dueDate, isCompleted: $isCompleted}';
  }
} 