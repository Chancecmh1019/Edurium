import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../providers/providers.dart';
import '../models/user.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import '../l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  
  String? _photoPath;
  String? _photoBase64;
  
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    super.dispose();
  }
  
  // 選擇照片
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _photoPath = image.path;
          _photoBase64 = null; // 清除舊的 base64 資料
        });
        
        // 將照片轉換為 base64
        final bytes = await File(image.path).readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        
        setState(() {
          _photoBase64 = base64Image;
        });
      }
    } catch (e) {
      // 處理錯誤
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('無法選擇照片: ${e.toString()}')),
      );
    }
  }
  
  // 儲存資料
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    int? enrollmentYear;
    if (_yearController.text.isNotEmpty) {
      enrollmentYear = int.tryParse(_yearController.text);
    }
    
    // 更新使用者資料
    if (userProvider.isLoggedIn) {
      await userProvider.updateUser(
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        photoUrl: _photoBase64,
        schoolName: _schoolController.text.isEmpty ? null : _schoolController.text,
        className: _classController.text.isEmpty ? null : _classController.text,
        department: _departmentController.text.isEmpty ? null : _departmentController.text,
        enrollmentYear: enrollmentYear,
      );
    } else {
      // 創建新使用者
      await userProvider.createUser(
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        photoUrl: _photoBase64,
        schoolName: _schoolController.text.isEmpty ? null : _schoolController.text,
        className: _classController.text.isEmpty ? null : _classController.text,
        department: _departmentController.text.isEmpty ? null : _departmentController.text,
        enrollmentYear: enrollmentYear,
      );
    }
    
    if (mounted) {
      // 顯示儲存成功訊息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.profileSavedSuccessfully,
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      // 返回上一頁
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.editProfile),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 頭像
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      backgroundImage: _getProfileImage(),
                      child: _photoBase64 == null && _photoPath == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: InkWell(
                          onTap: _pickImage,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 姓名欄位
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.name,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 電子郵件欄位
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.l10n.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // 簡單的電子郵件驗證
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 電話欄位
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '電話',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 學校資訊標題
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'School Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 學校名稱欄位
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(
                  labelText: 'School Name',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 班級欄位
              TextFormField(
                controller: _classController,
                decoration: InputDecoration(
                  labelText: 'Class',
                  prefixIcon: const Icon(Icons.group),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 系所欄位
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: 'Department',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 入學年份欄位
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enrollment Year',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > 2100) {
                      return 'Please enter a valid year';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // 儲存按鈕
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.save,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 獲取個人頭像圖片
  ImageProvider? _getProfileImage() {
    if (_photoPath != null) {
      return FileImage(File(_photoPath!));
    } else if (_photoBase64 != null) {
      // 從 base64 字串載入圖片
      try {
        final encodedStr = _photoBase64!.split(',')[1];
        return MemoryImage(base64Decode(encodedStr));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
} 