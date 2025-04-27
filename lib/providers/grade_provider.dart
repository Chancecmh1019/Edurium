import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import 'package:edurium/utils/constants.dart';

class GradeProvider extends ChangeNotifier {
  // 獲取成績盒子
  Box<Grade> get _gradeBox => Hive.box<Grade>(AppConstants.gradeBoxName);
  
  List<Grade> _grades = [];
  
  GradeProvider() {
    _loadGrades();
  }
  
  // 獲取所有成績
  List<Grade> get grades => _grades;
  
  // 獲取所有成績
  List<Grade> getGrades() {
    return _gradeBox.values.toList();
  }
  
  // 按課程獲取成績
  List<Grade> getGradesBySubject(String subjectId) {
    return _gradeBox.values
        .where((grade) => grade.subjectId == subjectId)
        .toList();
  }
  
  // 獲取平均成績
  double? getAverageGrade(String subjectId) {
    final grades = getGradesBySubject(subjectId);
    if (grades.isEmpty) return null;
    
    double totalPercentage = 0;
    for (final grade in grades) {
      totalPercentage += (grade.score / grade.maxScore) * 100;
    }
    
    return totalPercentage / grades.length;
  }
  
  // 計算整體GPA（假設滿分為4.0）
  double calculateOverallGPA() {
    if (_grades.isEmpty) {
      return 0.0;
    }
    
    // 將百分制成績轉換為GPA
    double totalWeightedGPA = 0.0;
    double totalWeight = 0.0;
    
    for (final grade in _grades) {
      final weight = grade.weight ?? 1.0;
      final percentage = grade.getPercentage();
      final gpa = _percentageToGPA(percentage);
      
      totalWeightedGPA += gpa * weight;
      totalWeight += weight;
    }
    
    return totalWeight > 0 ? totalWeightedGPA / totalWeight : 0.0;
  }
  
  // 將百分制成績轉換為GPA
  double _percentageToGPA(double percentage) {
    if (percentage >= 90) return 4.0;
    if (percentage >= 85) return 3.7;
    if (percentage >= 80) return 3.3;
    if (percentage >= 75) return 3.0;
    if (percentage >= 70) return 2.7;
    if (percentage >= 65) return 2.3;
    if (percentage >= 60) return 2.0;
    if (percentage >= 55) return 1.7;
    if (percentage >= 50) return 1.0;
    return 0.0;
  }
  
  // 獲取按類型分組的成績
  Map<String, List<Grade>> getGradesByType() {
    final Map<String, List<Grade>> typedGrades = {};
    
    for (final grade in _grades) {
      final type = grade.type.toString().split('.').last;
      if (!typedGrades.containsKey(type)) {
        typedGrades[type] = [];
      }
      typedGrades[type]!.add(grade);
    }
    
    return typedGrades;
  }
  
  // 獲取成績通過ID
  Grade? getGradeById(String id) {
    return _gradeBox.get(id);
  }
  
  // 從存儲中加載所有成績（私有方法）
  void _loadGrades() {
    _grades = _gradeBox.values.toList();
    notifyListeners();
  }
  
  // 加載所有成績（公共方法，可從其他地方調用）
  Future<void> loadGrades() async {
    _loadGrades();
    // 如需從服務器加載數據，可以在這裡添加代碼
  }
  
  // 添加成績
  Future<void> addGrade(Grade grade) async {
    await _gradeBox.add(grade);
    _loadGrades();
  }
  
  // 更新成績
  Future<void> updateGrade(Grade grade) async {
    await grade.save();
    _loadGrades();
  }
  
  // 刪除成績
  Future<void> deleteGrade(Grade grade) async {
    await grade.delete();
    _loadGrades();
  }
  
  // 批量刪除成績
  Future<void> deleteGrades(List<String> gradeIds) async {
    for (final id in gradeIds) {
      await _gradeBox.delete(id);
    }
    _loadGrades();
  }
  
  // 清除所有成績
  Future<void> clearAllGrades() async {
    await _gradeBox.clear();
    _loadGrades();
  }
  
  // 成績分析：獲取各分數段的統計
  Map<String, int> getGradeDistribution() {
    final Map<String, int> distribution = {
      '90-100': 0,
      '80-89': 0,
      '70-79': 0,
      '60-69': 0,
      '0-59': 0,
    };
    
    for (final grade in _grades) {
      final percentage = grade.getPercentage();
      
      if (percentage >= 90) {
        distribution['90-100'] = (distribution['90-100'] ?? 0) + 1;
      } else if (percentage >= 80) {
        distribution['80-89'] = (distribution['80-89'] ?? 0) + 1;
      } else if (percentage >= 70) {
        distribution['70-79'] = (distribution['70-79'] ?? 0) + 1;
      } else if (percentage >= 60) {
        distribution['60-69'] = (distribution['60-69'] ?? 0) + 1;
      } else {
        distribution['0-59'] = (distribution['0-59'] ?? 0) + 1;
      }
    }
    
    return distribution;
  }
  
  // 獲取所有學期
  List<String> getAllSemesters() {
    final Set<String> semesters = {};
    
    for (final grade in _grades) {
      if (grade.semester != null && grade.semester!.isNotEmpty) {
        semesters.add(grade.semester!);
      }
    }
    
    return semesters.toList()..sort((a, b) => b.compareTo(a)); // 按新到舊排序
  }
  
  // 成績排名：計算某一科目相對於全班的排名
  int calculateRank(String gradeId) {
    final grade = getGradeById(gradeId);
    if (grade == null) return 0;
    
    final subjectGrades = getGradesBySubject(grade.subjectId);
    subjectGrades.sort((a, b) => b.getPercentage().compareTo(a.getPercentage()));
    
    for (int i = 0; i < subjectGrades.length; i++) {
      if (subjectGrades[i].id == gradeId) {
        return i + 1;
      }
    }
    
    return 0;
  }
  
  // 獲取最近的成績
  List<Grade> getRecentGrades({int limit = 5}) {
    final sortedGrades = List<Grade>.from(_grades);
    // 按日期從新到舊排序
    sortedGrades.sort((a, b) => b.date.compareTo(a.date));
    
    // 取前limit個
    return sortedGrades.take(limit).toList();
  }
  
  // 獲取平均分數
  double getAverageScore() {
    if (_grades.isEmpty) return 0.0;
    
    double totalPercentage = 0.0;
    for (final grade in _grades) {
      totalPercentage += grade.getPercentage();
    }
    
    return totalPercentage / _grades.length;
  }
  
  // 獲取GPA
  double getGPA() {
    return calculateOverallGPA();
  }
  
  // 獲取分數趨勢
  Map<DateTime, double> getScoreTrend() {
    final Map<DateTime, double> trend = {};
    final sortedGrades = List<Grade>.from(_grades);
    
    // 按日期從舊到新排序
    sortedGrades.sort((a, b) => a.date.compareTo(b.date));
    
    for (final grade in sortedGrades) {
      // 使用日期作為鍵，使用百分比作為值
      final date = DateTime(grade.date.year, grade.date.month, grade.date.day);
      
      // 如果同一天有多個成績，取平均值
      if (trend.containsKey(date)) {
        trend[date] = (trend[date]! + grade.getPercentage()) / 2;
      } else {
        trend[date] = grade.getPercentage();
      }
    }
    
    return trend;
  }
  
  // 獲取分數分佈
  Map<String, double> getScoreDistribution() {
    final Map<String, double> distribution = {};
    
    if (_grades.isEmpty) {
      return {
        'A': 0.0,
        'B': 0.0,
        'C': 0.0,
        'D': 0.0,
        'F': 0.0,
      };
    }
    
    int countA = 0, countB = 0, countC = 0, countD = 0, countF = 0;
    
    for (final grade in _grades) {
      final percentage = grade.getPercentage();
      
      if (percentage >= 90) {
        countA++;
      } else if (percentage >= 80) {
        countB++;
      } else if (percentage >= 70) {
        countC++;
      } else if (percentage >= 60) {
        countD++;
      } else {
        countF++;
      }
    }
    
    final total = _grades.length;
    distribution['A'] = countA / total;
    distribution['B'] = countB / total;
    distribution['C'] = countC / total;
    distribution['D'] = countD / total;
    distribution['F'] = countF / total;
    
    return distribution;
  }
} 