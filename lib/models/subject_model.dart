import 'package:hive/hive.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 1)
class Subject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name; // 課程名稱
  
  @HiveField(2)
  final String? teacherId; // 授課老師ID
  
  @HiveField(3)
  final String? classroom; // 教室
  
  @HiveField(4)
  final String? description; // 課程描述
  
  @HiveField(5)
  final String? color; // 課程顏色
  
  @HiveField(6)
  final Map<String, dynamic>? schedule; // 課程時間表
  
  @HiveField(7)
  final Map<String, double>? gradeComponents; // 成績組成 (如：期中30%, 期末40%, 作業30%)
  
  @HiveField(8)
  final DateTime createdAt; // 創建時間
  
  @HiveField(9)
  final Map<String, dynamic>? extras; // 額外資訊
  
  Subject({
    required this.id,
    required this.name,
    this.teacherId,
    this.classroom,
    this.description,
    this.color,
    this.schedule,
    this.gradeComponents,
    DateTime? createdAt,
    this.extras,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Subject copyWith({
    String? id,
    String? name,
    String? teacherId,
    String? classroom,
    String? description,
    String? color,
    Map<String, dynamic>? schedule,
    Map<String, double>? gradeComponents,
    DateTime? createdAt,
    Map<String, dynamic>? extras,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      classroom: classroom ?? this.classroom,
      description: description ?? this.description,
      color: color ?? this.color,
      schedule: schedule ?? this.schedule,
      gradeComponents: gradeComponents ?? this.gradeComponents,
      createdAt: createdAt ?? this.createdAt,
      extras: extras ?? this.extras,
    );
  }
} 