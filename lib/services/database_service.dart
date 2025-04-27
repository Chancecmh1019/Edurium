import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'dart:io';

class DatabaseService {
  static const String _taskBoxName = 'tasks';
  static const String _subjectBoxName = 'subjects';
  static const String _teacherBoxName = 'teachers';
  static const String _gradeBoxName = 'grades';
  static const String _settingsBoxName = 'settings';
  
  // 初始化Hive資料庫
  static Future<void> initDatabase() async {
    // 初始化Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    
    // 註冊適配器
    // 注意：這裡需要先執行build_runner來產生適配器
    // flutter pub run build_runner build --delete-conflicting-outputs
    
    // 打開各種Box
    await Hive.openBox<Task>(_taskBoxName);
    await Hive.openBox<Subject>(_subjectBoxName);
    await Hive.openBox<Teacher>(_teacherBoxName);
    await Hive.openBox<Grade>(_gradeBoxName);
    await Hive.openBox(_settingsBoxName);
  }
  
  // 獲取任務盒子
  static Box<Task> getTaskBox() {
    return Hive.box<Task>(_taskBoxName);
  }
  
  // 獲取課程盒子
  static Box<Subject> getSubjectBox() {
    return Hive.box<Subject>(_subjectBoxName);
  }
  
  // 獲取老師盒子
  static Box<Teacher> getTeacherBox() {
    return Hive.box<Teacher>(_teacherBoxName);
  }
  
  // 獲取成績盒子
  static Box<Grade> getGradeBox() {
    return Hive.box<Grade>(_gradeBoxName);
  }
  
  // 獲取設置盒子
  static Box getSettingsBox() {
    return Hive.box(_settingsBoxName);
  }
  
  // 關閉資料庫
  static Future<void> closeDatabase() async {
    await Hive.close();
  }
  
  // 清除所有資料
  static Future<void> clearAllData() async {
    await getTaskBox().clear();
    await getSubjectBox().clear();
    await getTeacherBox().clear();
    await getGradeBox().clear();
    // 設置不清除，因為包含主題等配置
  }
  
  // 清除並刪除資料庫
  static Future<void> deleteDatabase() async {
    await Hive.deleteBoxFromDisk(_taskBoxName);
    await Hive.deleteBoxFromDisk(_subjectBoxName);
    await Hive.deleteBoxFromDisk(_teacherBoxName);
    await Hive.deleteBoxFromDisk(_gradeBoxName);
    await Hive.deleteBoxFromDisk(_settingsBoxName);
  }
  
  // 導出資料庫
  static Future<File> exportDatabase(String path) async {
    // 實現導出邏輯
    // 這裡是一個簡單的範例，實際應用可能需要更複雜的邏輯
    final File file = File(path);
    
    // 將資料序列化為JSON並寫入文件
    // 這裡僅為示例
    final Map<String, dynamic> data = {
      'tasks': getTaskBox().values.toList(),
      'subjects': getSubjectBox().values.toList(),
      'teachers': getTeacherBox().values.toList(),
      'grades': getGradeBox().values.toList(),
    };
    
    await file.writeAsString(data.toString());
    return file;
  }
  
  // 導入資料庫
  static Future<void> importDatabase(String path) async {
    // 實現導入邏輯
    // 同樣，這裡只是一個簡單的範例
    // 此方法待實現
  }
  
  // 插入演示數據（用於測試）
  static Future<void> insertDemoData() async {
    final taskBox = getTaskBox();
    final subjectBox = getSubjectBox();
    final teacherBox = getTeacherBox();
    final gradeBox = getGradeBox();
    
    // 清除現有資料
    await taskBox.clear();
    await subjectBox.clear();
    await teacherBox.clear();
    await gradeBox.clear();
    
    // 插入老師數據
    final teacher1 = Teacher(
      id: '1',
      name: '王老師',
      email: 'wang@school.edu',
      department: '數學系',
      office: 'A棟201室',
    );
    
    final teacher2 = Teacher(
      id: '2',
      name: '林老師',
      email: 'lin@school.edu',
      department: '英文系',
      office: 'B棟304室',
    );
    
    await teacherBox.put(teacher1.id, teacher1);
    await teacherBox.put(teacher2.id, teacher2);
    
    // 插入課程數據
    final subject1 = Subject(
      id: '1',
      name: '高等數學',
      teacherId: '1',
      classroom: 'A棟301教室',
      color: '#4CAF50',
    );
    
    final subject2 = Subject(
      id: '2',
      name: '英語寫作',
      teacherId: '2',
      classroom: 'B棟102教室',
      color: '#2196F3',
    );
    
    await subjectBox.put(subject1.id, subject1);
    await subjectBox.put(subject2.id, subject2);
    
    // 插入任務數據
    final task1 = Task(
      id: '1',
      title: '數學期中考',
      description: '高等數學期中考試',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      taskType: TaskType.exam,
      priority: TaskPriority.high,
      subjectId: '1',
      teacherId: '1',
    );
    
    final task2 = Task(
      id: '2',
      title: '英文作業',
      description: '寫一篇500字的英文短文',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      taskType: TaskType.homework,
      priority: TaskPriority.medium,
      subjectId: '2',
      teacherId: '2',
    );
    
    await taskBox.put(task1.id, task1);
    await taskBox.put(task2.id, task2);
    
    // 插入成績數據
    final grade1 = Grade(
      id: '1',
      subjectId: '1',
      title: '數學小測驗',
      score: 85,
      maxScore: 100,
      date: DateTime.now(),
      gradeType: GradeType.quiz,
      gradedDate: DateTime.now().subtract(const Duration(days: 5)),
      totalPoints: 100,
      weight: 0.1,
      semester: '2023-1',
    );
    
    final grade2 = Grade(
      id: '2',
      subjectId: '2',
      title: '英文寫作作業1',
      score: 90,
      maxScore: 100,
      date: DateTime.now(),
      gradeType: GradeType.assignment,
      gradedDate: DateTime.now().subtract(const Duration(days: 8)),
      totalPoints: 100,
      weight: 0.15,
      semester: '2023-1',
    );
    
    await gradeBox.put(grade1.id, grade1);
    await gradeBox.put(grade2.id, grade2);
  }
  
  static Future<void> importSampleData() async {
    // 檢查是否已經有數據
    if (getSubjectBox().isNotEmpty || getTaskBox().isNotEmpty || 
        getTeacherBox().isNotEmpty || getGradeBox().isNotEmpty) {
      return; // 已有數據，不導入
    }
    
    // 創建示例教師
    final teacher1 = Teacher(
      id: 'teacher1',
      name: '張老師',
      department: '數學',
      email: 'zhang@school.edu',
      phoneNumber: '0912345678',
      officeHours: {'time': '週一、三、五 13:00-15:00'},
      office: '理學院 301',
    );
    
    final teacher2 = Teacher(
      id: 'teacher2',
      name: '李教授',
      department: '物理',
      email: 'lee@school.edu',
      phoneNumber: '0923456789',
      officeHours: {'time': '週二、四 10:00-12:00'},
      office: '理學院 205',
    );
    
    await getTeacherBox().putAll({
      teacher1.id: teacher1,
      teacher2.id: teacher2,
    });
    
    // 創建示例課程
    final subject1 = Subject(
      id: 'subject1',
      name: '微積分',
      teacherId: teacher1.id,
      classroom: '理學院 101',
      color: '#4CAF50',
    );
    
    final subject2 = Subject(
      id: 'subject2',
      name: '基礎物理',
      teacherId: teacher2.id,
      classroom: '理學院 205',
      color: '#2196F3',
    );
    
    await getSubjectBox().putAll({
      subject1.id: subject1,
      subject2.id: subject2,
    });
    
    // 創建示例任務
    final now = DateTime.now();
    
    final task1 = Task(
      id: 'task1',
      title: '微積分作業',
      description: '第3章習題1-10',
      dueDate: now.add(const Duration(days: 2)),
      taskType: TaskType.homework,
      subjectId: subject1.id,
    );
    
    final task2 = Task(
      id: 'task2',
      title: '物理小測驗',
      description: '牛頓運動定律',
      dueDate: now.add(const Duration(days: 5)),
      taskType: TaskType.exam,
      subjectId: subject2.id,
    );
    
    await getTaskBox().putAll({
      task1.id: task1,
      task2.id: task2,
    });
    
    // 創建示例成績
    final grade1 = Grade(
      id: 'grade1',
      subjectId: subject1.id,
      score: 85,
      maxScore: 100,
      title: '微積分期中考',
      date: now.subtract(const Duration(days: 20)),
      gradeType: GradeType.midtermExam,
      semester: '2023-1',
      gradedDate: now.subtract(const Duration(days: 15)),
    );
    
    final grade2 = Grade(
      id: 'grade2',
      subjectId: subject2.id,
      score: 92,
      maxScore: 100,
      title: '物理小測驗',
      date: now.subtract(const Duration(days: 10)),
      gradeType: GradeType.quiz,
      semester: '2023-1',
      gradedDate: now.subtract(const Duration(days: 7)),
    );
    
    await getGradeBox().putAll({
      grade1.id: grade1,
      grade2.id: grade2,
    });
  }
} 