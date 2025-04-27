import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';

class UserProvider extends ChangeNotifier {
  static const String _userKey = 'user_data';
  
  User? _currentUser;
  
  // 獲取當前用戶
  User? get currentUser => _currentUser;
  
  // 檢查用戶是否已登入
  bool get isLoggedIn => _currentUser != null;
  
  // 檢查是否有未讀通知
  bool hasUnreadNotifications() {
    // TODO: 實現未讀通知檢查邏輯
    return false;
  }
  
  // 獲取用戶盒子
  Box<User> get _userBox => Hive.box<User>(AppConstants.userBoxName);
  
  UserProvider() {
    _loadCurrentUser();
  }
  
  // 加載當前用戶
  void _loadCurrentUser() {
    try {
      if (_userBox.isNotEmpty) {
        _currentUser = _userBox.getAt(0);
      }
    } catch (e) {
      debugPrint('Error loading user: ${e.toString()}');
    }
  }
  
  // 更新用戶信息
  Future<void> updateUser({
    String? name,
    String? email,
    String? photoUrl,
    String? phoneNumber,
    String? schoolName,
    String? className,
    String? department,
    int? enrollmentYear,
  }) async {
    try {
      final updatedUser = User(
        name: name ?? _currentUser?.name,
        email: email ?? _currentUser?.email,
        photoUrl: photoUrl ?? _currentUser?.photoUrl,
        phoneNumber: phoneNumber ?? _currentUser?.phoneNumber,
        schoolName: schoolName ?? _currentUser?.schoolName,
        className: className ?? _currentUser?.className,
        department: department ?? _currentUser?.department,
        enrollmentYear: enrollmentYear ?? _currentUser?.enrollmentYear,
      );
      
      if (_userBox.isEmpty) {
        await _userBox.add(updatedUser);
      } else {
        await _userBox.putAt(0, updatedUser);
      }
      
      _currentUser = updatedUser;
      notifyListeners();
      
      // 保存到 SharedPreferences
      await _saveUserData();
    } catch (e) {
      debugPrint('Error updating user: ${e.toString()}');
    }
  }
  
  // 創建新用戶
  Future<void> createUser({
    required String name, 
    String? email, 
    String? photoUrl, 
    String? phoneNumber,
    String? schoolName,
    String? className,
    String? department,
    int? enrollmentYear,
  }) async {
    final user = User(
      name: name,
      email: email,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      schoolName: schoolName,
      className: className,
      department: department,
      enrollmentYear: enrollmentYear,
    );
    
    await updateUser(
      name: user.name,
      email: user.email,
      photoUrl: user.photoUrl,
      phoneNumber: user.phoneNumber,
      schoolName: user.schoolName,
      className: user.className,
      department: user.department,
      enrollmentYear: user.enrollmentYear,
    );
  }
  
  // 更新用戶名
  Future<void> updateUserName(String name) async {
    if (_currentUser == null) {
      await createUser(name: name);
    } else {
      await updateUser(name: name);
    }
  }
  
  // 更新用戶電子郵件
  Future<void> updateUserEmail(String email) async {
    if (_currentUser == null) {
      await createUser(name: 'User', email: email);
    } else {
      await updateUser(email: email);
    }
  }
  
  // 更新用戶頭像
  Future<void> updateUserPhoto(String photoUrl) async {
    if (_currentUser == null) {
      await createUser(name: 'User', photoUrl: photoUrl);
    } else {
      await updateUser(photoUrl: photoUrl);
    }
  }
  
  // 登出使用者
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
    
    // 清除使用者資料
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
  
  // 從本地儲存載入使用者資料
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userKey);
      
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        _currentUser = User.fromJson(userData);
        notifyListeners();
      } else {
        // 使用Hive嘗試讀取
        try {
          final userBox = await Hive.openBox<User>(AppConstants.userBoxName);
          if (userBox.isNotEmpty) {
            _currentUser = userBox.getAt(0);
            notifyListeners();
          }
        } catch (e) {
          // Hive讀取失敗，不處理
        }
      }
    } catch (e) {
      // 讀取失敗，不處理
    }
  }
  
  // 儲存使用者資料
  Future<void> _saveUserData() async {
    if (_currentUser == null) return;
    
    try {
      // 使用SharedPreferences保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
      
      // 同時使用Hive保存
      try {
        final userBox = await Hive.openBox<User>(AppConstants.userBoxName);
        if (userBox.isEmpty) {
          await userBox.add(_currentUser!);
        } else {
          await userBox.putAt(0, _currentUser!);
        }
      } catch (e) {
        // Hive儲存失敗，不處理
      }
    } catch (e) {
      // 儲存失敗，不處理
    }
  }
} 