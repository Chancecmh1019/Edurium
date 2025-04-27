import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/subject.dart';
import '../../../providers/subject_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation_handler.dart';
import '../../../utils/route_constants.dart';

/// 科目詳情頁面
class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;

  const SubjectDetailScreen({
    Key? key,
    required this.subjectId,
  }) : super(key: key);

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  late Subject? _subject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubject();
  }

  Future<void> _loadSubject() async {
    setState(() {
      _isLoading = true;
    });

    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    _subject = subjectProvider.getSubjectById(widget.subjectId);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isZh = locale.languageCode == 'zh';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isZh ? '科目詳情' : 'Subject Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_subject == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isZh ? '科目詳情' : 'Subject Details'),
        ),
        body: Center(
          child: Text(
            isZh ? '找不到科目' : 'Subject not found',
            style: theme.textTheme.titleLarge,
          ),
        ),
      );
    }

    // 獲取科目顏色
    Color subjectColor;
    try {
      if (_subject!.color is String) {
        final colorString = _subject!.color as String;
        final colorValue = int.parse(colorString.replaceAll('#', '0xFF'));
        subjectColor = Color(colorValue);
      } else {
        subjectColor = _subject!.color as Color;
      }
    } catch (e) {
      subjectColor = AppColorConstants.primaryColor;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_subject!.name),
        backgroundColor: subjectColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              NavigationHandler.navigateTo(
                context,
                AppRoutes.editSubject,
                arguments: widget.subjectId,
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(isZh ? '刪除科目' : 'Delete Subject'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 科目頭部區域
            Container(
              padding: const EdgeInsets.all(16),
              color: subjectColor.withOpacity(0.1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 科目圖標
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: subjectColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: subjectColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.book,
                      color: subjectColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 科目信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _subject!.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSubjectTypeName(_subject!.type, isZh),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: subjectColor,
                          ),
                        ),
                        if (_subject!.teacher != null && _subject!.teacher!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _subject!.teacher!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_subject!.location != null && _subject!.location!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _subject!.location!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 描述區域
            if (_subject!.description != null && _subject!.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isZh ? '描述' : 'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subject!.description!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            
            // 功能區域 (作業、考試等)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isZh ? '科目特性' : 'Subject Features',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 作業開關
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(
                        Icons.assignment, 
                        color: _subject!.hasHomework ? subjectColor : colorScheme.onSurfaceVariant,
                      ),
                      title: Text(isZh ? '作業' : 'Homework'),
                      subtitle: Text(
                        _subject!.hasHomework 
                            ? (isZh ? '此科目有作業' : 'This subject has homework') 
                            : (isZh ? '此科目無作業' : 'This subject has no homework'),
                      ),
                      trailing: Switch(
                        value: _subject!.hasHomework,
                        activeColor: subjectColor,
                        onChanged: null,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 考試開關
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: Icon(
                        Icons.quiz, 
                        color: _subject!.hasExam ? subjectColor : colorScheme.onSurfaceVariant,
                      ),
                      title: Text(isZh ? '考試' : 'Exam'),
                      subtitle: Text(
                        _subject!.hasExam 
                            ? (isZh ? '此科目有考試' : 'This subject has exams') 
                            : (isZh ? '此科目無考試' : 'This subject has no exams'),
                      ),
                      trailing: Switch(
                        value: _subject!.hasExam,
                        activeColor: subjectColor,
                        onChanged: null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 按鈕區域
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 查看相關任務
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 導航到與此科目相關的任務列表
                        NavigationHandler.navigateTo(
                          context,
                          AppRoutes.tasksBySubject,
                          arguments: {
                            'subjectId': _subject!.id,
                            'subjectName': _subject!.name,
                          },
                        );
                      },
                      icon: const Icon(Icons.assignment),
                      label: Text(isZh ? '查看相關任務' : 'View Related Tasks'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subjectColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 查看成績
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // 導航到與此科目相關的成績
                        NavigationHandler.navigateTo(
                          context,
                          AppRoutes.gradesBySubject,
                          arguments: {
                            'subjectId': _subject!.id,
                            'subjectName': _subject!.name,
                          },
                        );
                      },
                      icon: const Icon(Icons.grade),
                      label: Text(isZh ? '查看成績' : 'View Grades'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: subjectColor,
                        side: BorderSide(color: subjectColor),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    final isZh = locale.languageCode == 'zh';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isZh ? '刪除科目' : 'Delete Subject'),
        content: Text(
          isZh 
              ? '確定要刪除此科目嗎？此操作無法撤銷，所有與此科目相關的數據都將被刪除。'
              : 'Are you sure you want to delete this subject? This action cannot be undone and all data associated with this subject will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isZh ? '取消' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // 刪除科目
              final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
              await subjectProvider.deleteSubject(_subject!.id);
              
              // 返回上一頁
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(isZh ? '刪除' : 'Delete'),
          ),
        ],
      ),
    );
  }

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
        default:
          return '未知';
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
        default:
          return 'Unknown';
      }
    }
  }
} 