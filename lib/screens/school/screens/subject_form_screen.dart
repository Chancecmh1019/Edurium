import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../models/subject.dart';
import '../../../providers/subject_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/dialog_helper.dart';

/// 科目表單頁面 - 用於新增和編輯科目
class SubjectFormScreen extends StatefulWidget {
  /// 科目ID，如果為null則表示新增科目
  final String? subjectId;

  const SubjectFormScreen({Key? key, this.subjectId}) : super(key: key);

  @override
  State<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<SubjectFormScreen> {
  // 表單全局鍵
  final _formKey = GlobalKey<FormState>();
  
  // 控制器
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // 當前編輯的科目
  Subject? _subject;
  
  // 選中的科目類型
  SubjectType _selectedType = SubjectType.other;
  
  // 科目特性
  bool _hasHomework = false;
  bool _hasExam = false;
  
  // 選中的顏色
  Color _selectedColor = Colors.blue;
  
  // 可選的顏色
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
    Colors.brown,
    Colors.deepOrange,
  ];
  
  // 是否為編輯模式
  bool get isEditMode => widget.subjectId != null;
  
  @override
  void initState() {
    super.initState();
    
    // 載入科目資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubjectData();
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  // 載入科目資料
  Future<void> _loadSubjectData() async {
    if (isEditMode) {
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      final subject = subjectProvider.getSubjectById(widget.subjectId!);
      
      if (subject != null) {
        setState(() {
          _subject = subject;
          
          // 設置控制器內容
          _nameController.text = subject.name;
          _teacherController.text = subject.teacher ?? '';
          _locationController.text = subject.location ?? '';
          _descriptionController.text = subject.description ?? '';
          
          // 設置狀態
          _selectedType = subject.type;
          _hasHomework = subject.hasHomework;
          _hasExam = subject.hasExam;
          
          // 設置顏色
          if (subject.color != null) {
            try {
              if (subject.color is String) {
                final colorString = subject.color as String;
                final colorValue = int.parse(colorString.replaceAll('#', '0xFF'));
                _selectedColor = Color(colorValue);
              } else {
                _selectedColor = subject.color as Color;
              }
            } catch (e) {
              _selectedColor = Colors.blue;
            }
          }
        });
      }
    }
  }
  
  // 儲存科目
  Future<void> _saveSubject() async {
    if (_formKey.currentState!.validate()) {
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      
      // 準備顏色值為十六進制字符串
      final colorHex = '#${_selectedColor.value.toRadixString(16).substring(2)}';
      
      if (isEditMode && _subject != null) {
        // 更新科目
        await subjectProvider.updateSubject(
          _subject!.copyWith(
            name: _nameController.text,
            teacher: _teacherController.text,
            location: _locationController.text,
            description: _descriptionController.text,
            type: _selectedType,
            hasHomework: _hasHomework,
            hasExam: _hasExam,
            color: colorHex,
          ),
        );
      } else {
        // 創建新科目
        final subject = Subject(
          id: const Uuid().v4(),
          name: _nameController.text,
          description: _descriptionController.text,
          teacher: _teacherController.text,
          location: _locationController.text,
          color: colorHex,
          type: _selectedType,
          hasHomework: _hasHomework,
          hasExam: _hasExam,
          gradeComponents: {
            'homework': 30.0,
            'exams': 50.0,
            'participation': 20.0,
          },
        );
        
        await subjectProvider.addSubject(subject);
      }
      
      // 返回上一頁
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isZh = locale.languageCode == 'zh';
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode 
            ? (isZh ? '編輯科目' : 'Edit Subject')
            : (isZh ? '新增科目' : 'Add Subject')),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: isZh ? '儲存' : 'Save',
            onPressed: _saveSubject,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 科目名稱
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isZh ? '科目名稱' : 'Subject Name',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isZh ? '請輸入科目名稱' : 'Please enter a subject name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 科目類型
              DropdownButtonFormField<SubjectType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: isZh ? '科目類型' : 'Subject Type',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: SubjectType.values.map((type) {
                  return DropdownMenuItem<SubjectType>(
                    value: type,
                    child: Text(_getSubjectTypeName(type, isZh)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // 教師名稱
              TextFormField(
                controller: _teacherController,
                decoration: InputDecoration(
                  labelText: isZh ? '教師名稱' : 'Teacher Name',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 教室位置
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: isZh ? '教室位置' : 'Classroom Location',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 描述
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: isZh ? '描述' : 'Description',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 科目特性
              Text(
                isZh ? '科目特性' : 'Subject Features',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              
              const SizedBox(height: 8),
              
              // 是否有作業
              SwitchListTile(
                title: Text(isZh ? '有作業' : 'Has Homework'),
                subtitle: Text(isZh ? '此科目是否會有作業' : 'This subject has homework assignments'),
                value: _hasHomework,
                onChanged: (value) {
                  setState(() {
                    _hasHomework = value;
                  });
                },
                secondary: const Icon(Icons.assignment),
              ),
              
              // 是否有考試
              SwitchListTile(
                title: Text(isZh ? '有考試' : 'Has Exams'),
                subtitle: Text(isZh ? '此科目是否會有考試' : 'This subject has exams'),
                value: _hasExam,
                onChanged: (value) {
                  setState(() {
                    _hasExam = value;
                  });
                },
                secondary: const Icon(Icons.quiz),
              ),
              
              const SizedBox(height: 24),
              
              // 科目顏色
              Text(
                isZh ? '科目顏色' : 'Subject Color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              
              const SizedBox(height: 8),
              
              // 顏色選擇器
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  // 獲取科目類型名稱
  String _getSubjectTypeName(SubjectType type, bool isZh) {
    if (isZh) {
      switch (type) {
        case SubjectType.math:
          return '數學';
        case SubjectType.science:
          return '科學';
        case SubjectType.language:
          return '語言';
        case SubjectType.socialStudies:
          return '社會';
        case SubjectType.art:
          return '藝術';
        case SubjectType.physicalEd:
          return '體育';
        case SubjectType.other:
          return '其他';
      }
    } else {
      switch (type) {
        case SubjectType.math:
          return 'Math';
        case SubjectType.science:
          return 'Science';
        case SubjectType.language:
          return 'Language';
        case SubjectType.socialStudies:
          return 'Social Studies';
        case SubjectType.art:
          return 'Art';
        case SubjectType.physicalEd:
          return 'Physical Education';
        case SubjectType.other:
          return 'Other';
      }
    }
  }
} 