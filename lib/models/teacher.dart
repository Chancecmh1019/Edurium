import 'package:hive/hive.dart';

part 'teacher.g.dart';

@HiveType(typeId: 3)
class Teacher extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String? email;
  
  @HiveField(3)
  String? phone;
  
  @HiveField(4)
  String? photoUrl;

  @HiveField(5)
  String? department;

  @HiveField(6)
  String? phoneNumber;

  @HiveField(7)
  Map<String, String>? officeHours;

  @HiveField(8)
  String? office;

  @HiveField(9)
  String? notes;
  
  Teacher({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.department,
    this.phoneNumber,
    this.officeHours,
    this.office,
    this.notes,
  });
  
  // 獲取格式化的辦公時間
  String? getFormattedOfficeHours() {
    if (officeHours == null || officeHours!.isEmpty) return null;
    return officeHours!['time'];
  }
} 