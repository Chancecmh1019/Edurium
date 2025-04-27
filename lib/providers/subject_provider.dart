import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import 'package:edurium/utils/constants.dart';

class SubjectProvider extends ChangeNotifier {
  List<Subject> _subjects = [];
  
  // 獲取所有科目
  List<Subject> get subjects => _subjects;
  
  // 獲取科目盒子
  Box<Subject> get _subjectBox => Hive.box<Subject>(AppConstants.subjectBoxName);
  
  SubjectProvider() {
    _loadSubjects();
    _ensureDefaultSubjects();
  }
  
  // 獲取所有科目
  List<Subject> getSubjects() {
    return _subjects;
  }
  
  // 按老師獲取課程
  List<Subject> getSubjectsByTeacher(String teacherId) {
    return _subjects.where((subject) => subject.teacherId == teacherId).toList();
  }
  
  // 根據課程顏色映射課程
  Map<String, Color> getSubjectColorMap() {
    final Map<String, Color> colorMap = {};
    
    for (final subject in _subjects) {
      if (subject.color != null) {
        // 解析顏色
        try {
          final colorString = subject.color!;
          final colorValue = int.parse(colorString.replaceAll('#', '0xFF'));
          colorMap[subject.id] = Color(colorValue);
        } catch (e) {
          // 如果顏色解析失敗，使用預設顏色
          colorMap[subject.id] = Colors.grey;
        }
      } else {
        colorMap[subject.id] = Colors.grey;
      }
    }
    
    return colorMap;
  }
  
  // 根據ID獲取科目
  Subject? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((subject) => subject.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // 加載所有課程
  void _loadSubjects() {
    _subjects = _subjectBox.values.toList();
    notifyListeners();
  }
  
  // 加載所有課程（公開方法）
  Future<void> loadSubjects() async {
    try {
      // 確保預設科目
      await _ensureDefaultSubjects();
      // 重新加載科目
      _loadSubjects();
    } catch (e) {
      print('載入科目時發生錯誤: $e');
      // 確保有至少一個預設科目
      if (_subjects.isEmpty) {
        final defaultSubject = Subject(
          id: 'default_fallback',
          name: '預設科目',
          type: SubjectType.other,
        );
        await _subjectBox.put(defaultSubject.id, defaultSubject);
        _loadSubjects();
      }
    }
  }
  
  // 添加科目
  Future<void> addSubject(Subject subject) async {
    await _subjectBox.add(subject);
    _loadSubjects();
  }
  
  // 創建並添加新課程
  Future<Subject> createSubject({
    required String name,
    String? teacherId,
    String? classroom,
    String? description,
    String? color,
    Map<String, dynamic>? schedule,
    Map<String, double>? gradeComponents,
  }) async {
    final id = const Uuid().v4();
    final subject = Subject(
      id: id,
      name: name,
      teacherId: teacherId,
      classroom: classroom,
      description: description,
      color: color,
      schedule: schedule,
      gradeComponents: gradeComponents,
    );
    
    await addSubject(subject);
    return subject;
  }
  
  // 更新科目
  Future<void> updateSubject(Subject subject) async {
    await subject.save();
    _loadSubjects();
  }
  
  // 刪除科目
  Future<void> deleteSubject(dynamic subject) async {
    if (subject is Subject) {
      await subject.delete();
    } else if (subject is String) {
      // 如果傳入的是ID字符串，查找並刪除對應科目
      final subjectToDelete = _subjects.firstWhere(
        (s) => s.id == subject,
        orElse: () => throw Exception('科目未找到: $subject'),
      );
      await subjectToDelete.delete();
    } else {
      throw ArgumentError('參數必須是 Subject 對象或科目ID字符串');
    }
    _loadSubjects();
  }
  
  // 批量刪除課程
  Future<void> deleteSubjects(List<String> subjectIds) async {
    for (final id in subjectIds) {
      await _subjectBox.delete(id);
    }
    _loadSubjects();
  }
  
  // 清除所有課程
  Future<void> clearAllSubjects() async {
    await _subjectBox.clear();
    _loadSubjects();
  }
  
  // 獲取今日課程
  List<Subject> getTodaySchedule() {
    final DateTime now = DateTime.now();
    final int weekday = now.weekday; // 1-7，代表週一到週日
    
    final List<Subject> todaySubjects = [];
    
    for (final subject in _subjects) {
      if (subject.schedule != null) {
        subject.schedule!.forEach((key, value) {
          try {
            final parts = key.split('-');
            if (parts.length == 2) {
              final dayOfWeek = int.parse(parts[0]);
              
              if (dayOfWeek == weekday) {
                // 確保這個課程沒有被添加過
                if (!todaySubjects.contains(subject)) {
                  todaySubjects.add(subject);
                }
              }
            }
          } catch (e) {
            // 忽略格式錯誤的課程時間
          }
        });
      }
    }
    
    // 根據課程時段排序
    todaySubjects.sort((a, b) {
      int aEarliestPeriod = _getEarliestPeriod(a, weekday);
      int bEarliestPeriod = _getEarliestPeriod(b, weekday);
      return aEarliestPeriod.compareTo(bEarliestPeriod);
    });
    
    return todaySubjects;
  }
  
  // 獲取指定星期的課程
  List<Subject> getSubjectsForDay(int weekday) {
    final List<Subject> daySubjects = [];
    
    for (final subject in _subjects) {
      if (subject.schedule != null) {
        subject.schedule!.forEach((key, value) {
          try {
            final parts = key.split('-');
            if (parts.length == 2) {
              final dayOfWeek = int.parse(parts[0]);
              
              if (dayOfWeek == weekday) {
                // 確保這個課程沒有被添加過
                if (!daySubjects.contains(subject)) {
                  daySubjects.add(subject);
                }
              }
            }
          } catch (e) {
            // 忽略格式錯誤的課程時間
          }
        });
      }
    }
    
    // 根據課程時段排序
    daySubjects.sort((a, b) {
      int aEarliestPeriod = _getEarliestPeriod(a, weekday);
      int bEarliestPeriod = _getEarliestPeriod(b, weekday);
      return aEarliestPeriod.compareTo(bEarliestPeriod);
    });
    
    return daySubjects;
  }
  
  // 獲取指定星期的課程（別名）
  List<Subject> getSubjectsForWeekday(int weekday) {
    return getSubjectsForDay(weekday);
  }
  
  // 獲取課程在指定星期的最早時段
  int _getEarliestPeriod(Subject subject, int weekday) {
    int earliestPeriod = 99; // 預設一個很大的值
    
    if (subject.schedule != null) {
      subject.schedule!.forEach((key, value) {
        try {
          final parts = key.split('-');
          if (parts.length == 2) {
            final dayOfWeek = int.parse(parts[0]);
            final period = int.parse(parts[1]);
            
            if (dayOfWeek == weekday && period < earliestPeriod) {
              earliestPeriod = period;
            }
          }
        } catch (e) {
          // 忽略格式錯誤的課程時間
        }
      });
    }
    
    return earliestPeriod == 99 ? 0 : earliestPeriod;
  }
  
  // 獲取課程時間表
  Map<int, Map<int, Subject>> getWeeklySchedule() {
    // 創建一個空的每週課程表：外層Map的key是星期幾（1-7），內層Map的key是課程時段（1-12）
    final Map<int, Map<int, Subject>> weeklySchedule = {};
    
    // 初始化每一天
    for (int weekday = 1; weekday <= 7; weekday++) {
      weeklySchedule[weekday] = {};
    }
    
    // 遍歷所有課程，將有時間表的課程添加到課程表中
    for (final subject in _subjects) {
      if (subject.schedule != null) {
        // schedule的格式例如：{"1-3": [1, 2, 3], "2-4": [1, 2, 3]}
        // 其中"1-3"表示週一第3節課，[1, 2, 3]表示第1-3週有課
        subject.schedule!.forEach((key, value) {
          try {
            final parts = key.split('-');
            if (parts.length == 2) {
              final weekday = int.parse(parts[0]);
              final period = int.parse(parts[1]);
              
              if (weekday >= 1 && weekday <= 7 && period >= 1 && period <= 12) {
                weeklySchedule[weekday]![period] = subject;
              }
            }
          } catch (e) {
            // 忽略格式錯誤的課程時間
          }
        });
      }
    }
    
    return weeklySchedule;
  }
  
  // 搜索科目
  List<Subject> searchSubjects(String query) {
    if (query.isEmpty) return [];
    
    query = query.toLowerCase();
    
    return _subjects.where((subject) {
      return subject.name.toLowerCase().contains(query) || 
             (subject.teacher?.toLowerCase().contains(query) ?? false) ||
             (subject.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }
  
  // 確保預設科目存在
  Future<void> _ensureDefaultSubjects() async {
    // 日期格式： {"weekday-period": [week numbers]}
    // 例如： {"1-3": [1, 2, 3]} 表示每週一第3節課，第1-3週上課
    final defaultSchedule1 = {
      "1-1": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      "3-3": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      "5-5": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    };
    
    final defaultSchedule2 = {
      "2-2": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      "4-4": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    };
    
    final defaultSchedule3 = {
      "1-5": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      "4-1": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    };
    
    final defaultSchedule4 = {
      "2-5": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      "5-2": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    };
    
    final defaultSubjects = [
      Subject(
        id: 'default_math',
        name: '數學',
        color: '#2196F3', // 藍色
        teacher: '張老師',
        classroom: 'A101',
        schedule: defaultSchedule1,
        type: SubjectType.math,
      ),
      Subject(
        id: 'default_science',
        name: '科學',
        color: '#4CAF50', // 綠色
        teacher: '王老師',
        classroom: 'A102',
        schedule: defaultSchedule2,
        type: SubjectType.science,
      ),
      Subject(
        id: 'default_english',
        name: '英文',
        color: '#F44336', // 紅色
        teacher: '李老師',
        classroom: 'A103',
        schedule: defaultSchedule3,
        type: SubjectType.language,
      ),
      Subject(
        id: 'default_chinese',
        name: '國文',
        color: '#FF9800', // 橘色
        teacher: '陳老師',
        classroom: 'A104',
        schedule: defaultSchedule4,
        type: SubjectType.language,
      ),
      Subject(
        id: 'default_history',
        name: '歷史',
        color: '#795548', // 褐色
        teacher: '吳老師',
        classroom: 'B101',
        type: SubjectType.socialStudies,
      ),
      Subject(
        id: 'default_geography',
        name: '地理',
        color: '#009688', // 藍綠色
        teacher: '黃老師',
        classroom: 'B102',
        type: SubjectType.socialStudies,
      ),
      Subject(
        id: 'default_physics',
        name: '物理',
        color: '#9C27B0', // 紫色
        teacher: '劉老師',
        classroom: 'C101',
        type: SubjectType.science,
      ),
      Subject(
        id: 'default_chemistry',
        name: '化學',
        color: '#673AB7', // 深紫色
        teacher: '林老師',
        classroom: 'C102',
        type: SubjectType.science,
      ),
      Subject(
        id: 'default_biology',
        name: '生物',
        color: '#8BC34A', // 淺綠色
        teacher: '周老師',
        classroom: 'C103',
        type: SubjectType.science,
      ),
      Subject(
        id: 'default_music',
        name: '音樂',
        color: '#E91E63', // 粉色
        teacher: '楊老師',
        classroom: 'D101',
        type: SubjectType.art,
      ),
      Subject(
        id: 'default_art',
        name: '美術',
        color: '#FFC107', // 琥珀色
        teacher: '蔡老師',
        classroom: 'D102',
        type: SubjectType.art,
      ),
      Subject(
        id: 'default_pe',
        name: '體育',
        color: '#3F51B5', // 靛藍色
        teacher: '郭老師',
        classroom: '操場',
        type: SubjectType.physicalEd,
      ),
    ];
    
    // 檢查是否存在預設科目
    bool hasSubjects = _subjectBox.isNotEmpty;
    
    // 如果沒有科目，添加預設科目
    if (!hasSubjects) {
      for (final subject in defaultSubjects) {
        await _subjectBox.put(subject.id, subject);
      }
    }
    
    // 重新加載科目
    _loadSubjects();
    
    // 檢查加載後是否仍然沒有科目，如果沒有則手動添加一個
    if (_subjects.isEmpty) {
      final firstSubject = defaultSubjects.first;
      await _subjectBox.put(firstSubject.id, firstSubject);
      _loadSubjects();
    }
  }
} 