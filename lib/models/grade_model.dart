import 'package:hive/hive.dart';

part 'grade_model.g.dart';

enum GradeType {
  exam,           // 考試
  quiz,           // 測驗
  assignment,     // 作業
  project,        // 專案
  presentation,   // 報告
  participation,  // 參與度
  finalExam,      // 期末考試
  midtermExam,    // 期中考試
  other           // 其他
}

@HiveType(typeId: 3)
class Grade {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String? subjectId; // 課程ID
  
  @HiveField(2)
  final String? title; // 標題（例如：期中考、作業1等）
  
  @HiveField(3)
  final double score; // 獲得的分數
  
  @HiveField(4)
  final double? totalPoints; // 滿分值
  
  @HiveField(5)
  final double? weight; // 佔總成績的比重 (如 0.3 表示佔30%)
  
  @HiveField(6)
  final String? note; // 備註
  
  @HiveField(7)
  final DateTime gradedDate; // 獲得成績的日期
  
  @HiveField(8)
  final GradeType type; // 成績類型
  
  @HiveField(9)
  final DateTime createdAt; // 創建時間
  
  @HiveField(10)
  final String semester; // 學期（例如：2023-1表示2023年第1學期）
  
  Grade({
    required this.id,
    this.subjectId,
    this.title,
    required this.score,
    this.totalPoints = 100.0,
    this.weight,
    this.note,
    required this.gradedDate,
    required this.type,
    required this.semester,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // 計算百分比成績
  double getPercentage() {
    if (totalPoints == null || totalPoints == 0) return 0;
    return (score / totalPoints!) * 100;
  }
  
  // 計算貢獻到總成績的分數（考慮權重）
  double getWeightedScore() {
    return score * (weight ?? 1.0);
  }
  
  Grade copyWith({
    String? id,
    String? subjectId,
    String? title,
    double? score,
    double? totalPoints,
    double? weight,
    String? note,
    DateTime? gradedDate,
    GradeType? type,
    String? semester,
    DateTime? createdAt,
  }) {
    return Grade(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      score: score ?? this.score,
      totalPoints: totalPoints ?? this.totalPoints,
      weight: weight ?? this.weight,
      note: note ?? this.note,
      gradedDate: gradedDate ?? this.gradedDate,
      type: type ?? this.type,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 