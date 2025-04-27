import 'package:hive/hive.dart';

part 'subject.g.dart';

// 添加科目類型枚舉
@HiveType(typeId: 5)
enum SubjectType {
  @HiveField(0)
  math,
  
  @HiveField(1)
  science,
  
  @HiveField(2)
  language,
  
  @HiveField(3)
  socialStudies,
  
  @HiveField(4)
  art,
  
  @HiveField(5)
  physicalEd,
  
  @HiveField(6)
  other
}

@HiveType(typeId: 2)
class Subject extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  String? teacherId;
  
  @HiveField(4)
  dynamic color;

  @HiveField(5)
  String? classroom;

  @HiveField(6)
  Map<String, dynamic>? schedule;

  @HiveField(7)
  DateTime? startTime;

  @HiveField(8)
  DateTime? endTime;
  
  @HiveField(9)
  Map<String, double>? gradeComponents;
  
  // 新增屬性
  @HiveField(10)
  SubjectType type;
  
  @HiveField(11)
  String? location;
  
  @HiveField(12)
  String? teacher;
  
  @HiveField(13)
  bool hasHomework;
  
  @HiveField(14)
  bool hasExam;
  
  Subject({
    required this.id,
    required this.name,
    this.description,
    this.teacherId,
    this.color,
    this.classroom,
    this.schedule,
    this.startTime,
    this.endTime,
    this.gradeComponents,
    this.type = SubjectType.other,
    this.location,
    this.teacher,
    this.hasHomework = false,
    this.hasExam = false,
  });
  
  // 創建一個帶有當前值的新實例，但使用提供的值覆蓋
  Subject copyWith({
    String? id,
    String? name,
    String? description,
    String? teacherId,
    dynamic color,
    String? classroom,
    Map<String, dynamic>? schedule,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, double>? gradeComponents,
    SubjectType? type,
    String? location,
    String? teacher,
    bool? hasHomework,
    bool? hasExam,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      color: color ?? this.color,
      classroom: classroom ?? this.classroom,
      schedule: schedule ?? this.schedule,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      gradeComponents: gradeComponents ?? this.gradeComponents,
      type: type ?? this.type,
      location: location ?? this.location,
      teacher: teacher ?? this.teacher,
      hasHomework: hasHomework ?? this.hasHomework,
      hasExam: hasExam ?? this.hasExam,
    );
  }
} 