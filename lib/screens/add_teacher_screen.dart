import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _officeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _notesController = TextEditingController();

  Map<String, dynamic> officeHours = {};
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _officeController.dispose();
    _departmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addOfficeHour(String day, String hours) {
    setState(() {
      officeHours[day] = hours;
    });
  }

  void _removeOfficeHour(String day) {
    setState(() {
      officeHours.remove(day);
    });
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
      
      // 將辦公時間資料轉換為 Map<String, String>
      final Map<String, String> officeHoursData = {};
      for (final entry in officeHours.entries) {
        officeHoursData[entry.key] = entry.value;
      }
      
      await teacherProvider.createTeacher(
        name: _nameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        office: _officeController.text.isNotEmpty ? _officeController.text : null,
        department: _departmentController.text.isNotEmpty ? _departmentController.text : null,
        officeHours: officeHoursData.isNotEmpty ? officeHoursData : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (!mounted) return;
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isZh(context) ? '教師新增成功' : 'Teacher added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isZh(context) ? '新增教師失敗: $e' : 'Failed to add teacher: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isZhContext = isZh(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isZhContext ? '添加教師' : 'Add Teacher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveTeacher,
            tooltip: isZhContext ? '儲存' : 'Save',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 名稱欄位（必填）
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: isZhContext ? '姓名 *' : 'Name *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isZhContext ? '請輸入教師姓名' : 'Please enter teacher name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 系所欄位
                    TextFormField(
                      controller: _departmentController,
                      decoration: InputDecoration(
                        labelText: isZhContext ? '系所' : 'Department',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 電子郵件欄位
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: isZhContext ? '電子郵件' : 'Email',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    // 電話號碼欄位
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: isZhContext ? '電話號碼' : 'Phone Number',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    
                    // 辦公室位置欄位
                    TextFormField(
                      controller: _officeController,
                      decoration: InputDecoration(
                        labelText: isZhContext ? '辦公室位置' : 'Office Location',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 辦公時間
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isZhContext ? '辦公時間' : 'Office Hours',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // 已添加的辦公時間列表
                            ...officeHours.entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text('${entry.key}: ${entry.value}'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeOfficeHour(entry.key),
                                  ),
                                ],
                              ),
                            )),
                            
                            // 添加新辦公時間
                            ExpansionTile(
                              title: Text(isZhContext ? '添加新辦公時間' : 'Add New Office Hours'),
                              children: [
                                ..._weekdays.map((day) {
                                  // 如果這天已經有辦公時間，則不顯示
                                  if (officeHours.containsKey(day)) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  final timeController = TextEditingController();
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: Text(day),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: timeController,
                                            decoration: InputDecoration(
                                              hintText: isZhContext ? '例如：14:00-16:00' : 'e.g. 2:00PM-4:00PM',
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, color: Colors.green),
                                          onPressed: () {
                                            if (timeController.text.isNotEmpty) {
                                              _addOfficeHour(day, timeController.text);
                                              timeController.clear();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 備註欄位
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: isZhContext ? '備註' : 'Notes',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.note),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // 儲存按鈕
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveTeacher,
                      icon: const Icon(Icons.save),
                      label: Text(isZhContext ? '儲存教師資料' : 'Save Teacher'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 