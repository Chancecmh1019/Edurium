import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 5)
class User {
  @HiveField(0)
  final String? name;
  
  @HiveField(1)
  final String? email;
  
  @HiveField(2)
  final String? photoUrl;
  
  @HiveField(3)
  final String? phoneNumber;
  
  @HiveField(4)
  final String? schoolName;
  
  @HiveField(5)
  final String? className;
  
  @HiveField(6)
  final String? department;
  
  @HiveField(7)
  final int? enrollmentYear;
  
  User({
    this.name,
    this.email,
    this.photoUrl,
    this.phoneNumber,
    this.schoolName,
    this.className,
    this.department,
    this.enrollmentYear,
  });
  
  // 從 JSON 創建 User 對象
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      schoolName: json['schoolName'] as String?,
      className: json['className'] as String?,
      department: json['department'] as String?,
      enrollmentYear: json['enrollmentYear'] as int?,
    );
  }
  
  // 將 User 對象轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'schoolName': schoolName,
      'className': className,
      'department': department,
      'enrollmentYear': enrollmentYear,
    };
  }
} 