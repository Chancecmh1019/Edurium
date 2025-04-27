import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class GradeProvider extends ChangeNotifier {
  late Box<Grade> _gradeBox;
  List<Grade> _grades = [];
  
  GradeProvider() {
    _gradeBox = DatabaseService.getGradeBox();
    _loadGrades();
  }
  
  // 獲取所有成績
  List<Grade> get grades => _grades;
  
  // 按學期獲取成績
  List<Grade> getGradesBySemester(String semester) {
    return _grades.where((grade) => grade.semester == semester).toList();
  }
  
  // 按類型獲取成績
  List<Grade> getGradesByType(String type) {
    return _grades.where((grade) => grade.type == type).toList();
  }
  
  // 按課程獲取成績
  List<Grade> getGradesBySubject(String subjectId) {
    return _grades.where((grade) => grade.subjectId == subjectId).toList();
  }
  
  // 獲取特定課程特定學期的成績
  List<Grade> getGradesBySubjectAndSemester(String subjectId, String semester) {
    return _grades.where((grade) => 
      grade.subjectId == subjectId && grade.semester == semester
    ).toList();
  }
  
  // 計算特定課程特定學期的平均分數
  double? getAverageGradeForSubject(String subjectId, String semester) {
    final grades = getGradesBySubjectAndSemester(subjectId, semester);
    
    if (grades.isEmpty) {
      return null;
    }
    
    double totalWeight = 0;
    double weightedSum = 0;
    
    for (final grade in grades) {
      if (grade.score != null && grade.weight != null) {
        weightedSum += grade.score! * grade.weight!;
        totalWeight += grade.weight!;
      }
    }
    
    if (totalWeight == 0) {
      return null;
    }
    
    return weightedSum / totalWeight;
  }
  
  // 獲取特定課程的所有成績類型
  List<String> getGradeTypesForSubject(String subjectId) {
    final subjectGrades = getGradesBySubject(subjectId);
    final Set<String> types = {};
    
    for (final grade in subjectGrades) {
      types.add(grade.type);
    }
    
    return types.toList();
  }
  
  // 獲取成績通過ID
  Grade? getGradeById(String id) {
    return _gradeBox.get(id);
  }
  
  // 獲取所有學期
  List<String> getAllSemesters() {
    final Set<String> semesters = {};
    
    for (final grade in _grades) {
      semesters.add(grade.semester);
    }
    
    return semesters.toList()..sort();
  }
  
  // 加載所有成績
  void _loadGrades() {
    _grades = _gradeBox.values.toList();
    notifyListeners();
  }
  
  // 添加成績
  Future<void> addGrade(Grade grade) async {
    await _gradeBox.put(grade.id, grade);
    _loadGrades();
  }
  
  // 創建並添加新成績
  Future<Grade> createGrade({
    required String subjectId,
    required String type,
    required String semester,
    required double score,
    double? weight,
    String? description,
    DateTime? date,
    String? taskId,
  }) async {
    final id = const Uuid().v4();
    final grade = Grade(
      id: id,
      subjectId: subjectId,
      type: type,
      semester: semester,
      score: score,
      weight: weight,
      description: description,
      date: date ?? DateTime.now(),
      taskId: taskId,
    );
    
    await addGrade(grade);
    return grade;
  }
  
  // 更新成績
  Future<void> updateGrade(Grade grade) async {
    await _gradeBox.put(grade.id, grade);
    _loadGrades();
  }
  
  // 刪除成績
  Future<void> deleteGrade(String gradeId) async {
    await _gradeBox.delete(gradeId);
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
  
  // 根據科目ID和學期獲取成績分佈（各分數段的數量）
  Map<String, int> getGradeDistribution(String subjectId, String semester) {
    final grades = getGradesBySubjectAndSemester(subjectId, semester);
    final Map<String, int> distribution = {
      'A': 0, // 90-100
      'B': 0, // 80-89
      'C': 0, // 70-79
      'D': 0, // 60-69
      'F': 0, // 0-59
    };
    
    for (final grade in grades) {
      if (grade.score != null) {
        if (grade.score! >= 90) {
          distribution['A'] = (distribution['A'] ?? 0) + 1;
        } else if (grade.score! >= 80) {
          distribution['B'] = (distribution['B'] ?? 0) + 1;
        } else if (grade.score! >= 70) {
          distribution['C'] = (distribution['C'] ?? 0) + 1;
        } else if (grade.score! >= 60) {
          distribution['D'] = (distribution['D'] ?? 0) + 1;
        } else {
          distribution['F'] = (distribution['F'] ?? 0) + 1;
        }
      }
    }
    
    return distribution;
  }
} 