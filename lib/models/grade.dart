import 'package:hive/hive.dart';
import 'subject.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';

part 'grade.g.dart';

@HiveType(typeId: 7)
enum GradeType {
  @HiveField(0)
  exam,
  
  @HiveField(1)
  assignment,
  
  @HiveField(2)
  project,
  
  @HiveField(3)
  quiz,
  
  @HiveField(4)
  other,

  @HiveField(5)
  midtermExam,

  @HiveField(6)
  finalExam,

  @HiveField(7)
  presentation,

  @HiveField(8)
  participation
}

@HiveType(typeId: 4)
class Grade extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String subjectId;
  
  @HiveField(2)
  String title;
  
  @HiveField(3)
  double score;
  
  @HiveField(4)
  double maxScore;
  
  @HiveField(5)
  DateTime date;
  
  @HiveField(6)
  GradeType gradeType;
  
  @HiveField(7)
  String? description;

  @HiveField(8)
  DateTime? gradedDate;

  @HiveField(9)
  double? totalPoints;

  @HiveField(10)
  double? weight;

  @HiveField(11)
  String? semester;
  
  @HiveField(12)
  String? note;
  
  // 非持久化屬性，用於緩存關聯的科目
  Subject? _subject;
  
  Grade({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.date,
    required this.gradeType,
    GradeType? type,  // 添加 type 參數以兼容舊代碼
    this.description,
    this.gradedDate,
    this.totalPoints,
    this.weight,
    this.semester,
    this.note,
  }) {
    // 如果提供了 type 參數，則優先使用它
    if (type != null) {
      this.gradeType = type;
    }
  }

  // 計算分數百分比
  double getPercentage() {
    return (score / maxScore) * 100;
  }
  
  // 獲取關聯科目
  Subject? getSubject(BuildContext context) {
    if (_subject != null) return _subject;
    
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    _subject = subjectProvider.getSubjectById(subjectId);
    return _subject;
  }
  
  // 科目 getter
  Subject? get subject {
    return _subject;
  }
  
  // 設置科目參考
  set subject(Subject? subject) {
    _subject = subject;
    if (subject != null) {
      subjectId = subject.id;
    }
  }
  
  // 取得成績類型
  GradeType get type => gradeType;
} 