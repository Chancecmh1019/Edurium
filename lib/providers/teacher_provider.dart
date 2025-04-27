import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import 'package:edurium/utils/constants.dart';

class TeacherProvider extends ChangeNotifier {
  // 獲取教師盒子
  Box<Teacher> get _teacherBox => Hive.box<Teacher>(AppConstants.teacherBoxName);
  
  List<Teacher> _teachers = [];
  
  TeacherProvider() {
    _loadTeachers();
  }
  
  // 獲取所有老師
  List<Teacher> get teachers => _teachers;
  
  // 按系所獲取老師
  List<Teacher> getTeachersByDepartment(String department) {
    return _teachers.where((teacher) => teacher.department == department).toList();
  }
  
  // 獲取所有系所
  List<String> get allDepartments {
    final Set<String> departments = {};
    
    for (final teacher in _teachers) {
      if (teacher.department != null && teacher.department!.isNotEmpty) {
        departments.add(teacher.department!);
      }
    }
    
    return departments.toList()..sort();
  }
  
  // 獲取老師通過ID
  Teacher? getTeacherById(String id) {
    return _teacherBox.get(id);
  }
  
  // 加載所有老師
  void _loadTeachers() {
    _teachers = _teacherBox.values.toList();
    notifyListeners();
  }
  
  // 添加老師
  Future<void> addTeacher(Teacher teacher) async {
    await _teacherBox.add(teacher);
    notifyListeners();
  }
  
  // 創建並添加新老師
  Future<Teacher> createTeacher({
    required String name,
    String? email,
    String? phoneNumber,
    String? office,
    String? department,
    Map<String, String>? officeHours,
    String? notes,
    String? photoUrl,
  }) async {
    final id = const Uuid().v4();
    final teacher = Teacher(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      office: office,
      department: department,
      officeHours: officeHours,
      notes: notes,
      photoUrl: photoUrl,
    );
    
    await addTeacher(teacher);
    return teacher;
  }
  
  // 更新老師
  Future<void> updateTeacher(Teacher teacher) async {
    await teacher.save();
    notifyListeners();
  }
  
  // 刪除老師
  Future<void> deleteTeacher(Teacher teacher) async {
    await teacher.delete();
    notifyListeners();
  }
  
  // 批量刪除老師
  Future<void> deleteTeachers(List<String> teacherIds) async {
    for (final id in teacherIds) {
      await _teacherBox.delete(id);
    }
    _loadTeachers();
  }
  
  // 清除所有老師
  Future<void> clearAllTeachers() async {
    await _teacherBox.clear();
    _loadTeachers();
  }
  
  // 搜索老師
  List<Teacher> searchTeachers(String query) {
    if (query.isEmpty) {
      return _teachers;
    }
    
    final lowerCaseQuery = query.toLowerCase();
    
    return _teachers.where((teacher) {
      return teacher.name.toLowerCase().contains(lowerCaseQuery) ||
             (teacher.email != null && teacher.email!.toLowerCase().contains(lowerCaseQuery)) ||
             (teacher.department != null && teacher.department!.toLowerCase().contains(lowerCaseQuery));
    }).toList();
  }
} 