import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class AddGradeScreen extends StatefulWidget {
  const AddGradeScreen({Key? key}) : super(key: key);

  @override
  State<AddGradeScreen> createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends State<AddGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubjectId;
  String? _selectedType;
  final _titleController = TextEditingController();
  final _scoreController = TextEditingController();
  final _commentController = TextEditingController();
  late String _semester;
  
  @override
  void initState() {
    super.initState();
    _semester = '2023-2'; // 預設學期，可以根據需要修改
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _scoreController.dispose();
    _commentController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final gradeProvider = Provider.of<GradeProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isZh = localeProvider.locale.languageCode == 'zh';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isZh ? '添加成績' : 'Add Grade'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 科目選擇
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: isZh ? '科目' : 'Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: _selectedSubjectId,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(isZh ? '請選擇科目' : 'Please select subject'),
                ),
                ...subjectProvider.subjects.map((subject) {
                  return DropdownMenuItem<String>(
                    value: subject.id,
                    child: Text(subject.name),
                  );
                }),
              ],
              validator: (value) {
                if (value == null) {
                  return isZh ? '請選擇科目' : 'Please select a subject';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedSubjectId = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // 標題
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: isZh ? '標題' : 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isZh ? '請輸入標題' : 'Please enter a title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 成績類型
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: isZh ? '成績類型' : 'Grade Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: _selectedType,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(isZh ? '請選擇類型' : 'Please select type'),
                ),
                DropdownMenuItem<String>(
                  value: 'exam',
                  child: Text(isZh ? '考試' : 'Exam'),
                ),
                DropdownMenuItem<String>(
                  value: 'quiz',
                  child: Text(isZh ? '測驗' : 'Quiz'),
                ),
                DropdownMenuItem<String>(
                  value: 'assignment',
                  child: Text(isZh ? '作業' : 'Assignment'),
                ),
                DropdownMenuItem<String>(
                  value: 'project',
                  child: Text(isZh ? '專案' : 'Project'),
                ),
                DropdownMenuItem<String>(
                  value: 'midterm',
                  child: Text(isZh ? '期中考' : 'Midterm'),
                ),
                DropdownMenuItem<String>(
                  value: 'final',
                  child: Text(isZh ? '期末考' : 'Final'),
                ),
              ],
              validator: (value) {
                if (value == null) {
                  return isZh ? '請選擇成績類型' : 'Please select grade type';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // 分數
            TextFormField(
              controller: _scoreController,
              decoration: InputDecoration(
                labelText: isZh ? '分數 (0-100)' : 'Score (0-100)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isZh ? '請輸入分數' : 'Please enter a score';
                }
                
                try {
                  final score = double.parse(value);
                  if (score < 0 || score > 100) {
                    return isZh ? '分數必須在0到100之間' : 'Score must be between 0 and 100';
                  }
                } catch (e) {
                  return isZh ? '請輸入有效的數字' : 'Please enter a valid number';
                }
                
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 評語
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: isZh ? '評語（可選）' : 'Comment (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // 提交按鈕
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // 創建成績
                  final score = double.parse(_scoreController.text);
                  GradeType gradeType;
                  
                  switch (_selectedType) {
                    case 'exam':
                      gradeType = GradeType.exam;
                      break;
                    case 'quiz':
                      gradeType = GradeType.quiz;
                      break;
                    case 'assignment':
                      gradeType = GradeType.assignment;
                      break;
                    case 'project':
                      gradeType = GradeType.project;
                      break;
                    case 'midterm':
                      gradeType = GradeType.midtermExam;
                      break;
                    case 'final':
                      gradeType = GradeType.finalExam;
                      break;
                    default:
                      gradeType = GradeType.exam;
                  }
                  
                  final id = const Uuid().v4();
                  
                  final grade = Grade(
                    id: id,
                    subjectId: _selectedSubjectId!,
                    title: _titleController.text,
                    score: score,
                    maxScore: 100,
                    date: DateTime.now(),
                    gradeType: gradeType,
                    gradedDate: DateTime.now(),
                    description: _commentController.text,
                    semester: _semester,
                  );
                  
                  // 添加成績
                  gradeProvider.addGrade(grade);
                  
                  // 顯示提示並返回
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isZh ? '成績添加成功' : 'Grade added successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  
                  Navigator.pop(context);
                }
              },
              child: Text(isZh ? '保存' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
} 