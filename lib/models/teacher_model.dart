import 'package:hive/hive.dart';

part 'teacher_model.g.dart';

@HiveType(typeId: 2)
class Teacher {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name; // 老師姓名
  
  @HiveField(2)
  final String? email; // 電子郵件
  
  @HiveField(3)
  final String? phoneNumber; // 電話號碼
  
  @HiveField(4)
  final String? office; // 辦公室位置
  
  @HiveField(5)
  final String? department; // 系所
  
  @HiveField(6)
  final Map<String, dynamic>? officeHours; // 辦公室時間
  
  @HiveField(7)
  final String? notes; // 備註
  
  @HiveField(8)
  final String? photoUrl; // 照片URL
  
  @HiveField(9)
  final DateTime createdAt; // 創建時間
  
  @HiveField(10)
  final Map<String, dynamic>? extras; // 額外資訊
  
  Teacher({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.office,
    this.department,
    this.officeHours,
    this.notes,
    this.photoUrl,
    DateTime? createdAt,
    this.extras,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Teacher copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? office,
    String? department,
    Map<String, dynamic>? officeHours,
    String? notes,
    String? photoUrl,
    DateTime? createdAt,
    Map<String, dynamic>? extras,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      office: office ?? this.office,
      department: department ?? this.department,
      officeHours: officeHours ?? this.officeHours,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      extras: extras ?? this.extras,
    );
  }
} 