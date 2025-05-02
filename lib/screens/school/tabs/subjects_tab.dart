import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/subject.dart';
import '../../../providers/providers.dart';
import '../../../utils/constants.dart';

class SubjectsTab extends StatefulWidget {
  const SubjectsTab({super.key});

  @override
  State<SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<SubjectsTab> {
  SubjectType? _selectedType;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isZh = localeProvider.locale.languageCode == 'zh';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // 獲取所有科目
    final subjects = subjectProvider.subjects;
    
    // 根據搜索和過濾條件篩選科目
    List<Subject> filteredSubjects = subjects;
    
    // 根據類型過濾
    if (_selectedType != null) {
      filteredSubjects = filteredSubjects.where((s) => s.type == _selectedType).toList();
    }
    
    // 根據搜索條件過濾
    if (_searchQuery.isNotEmpty) {
      filteredSubjects = filteredSubjects.where((s) => 
        s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (s.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    return Column(
      children: [
        // 搜索和篩選區域
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 搜索框
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: isZh ? '搜尋科目...' : 'Search subjects...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // 科目類型篩選器
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: isZh ? '所有' : 'All',
                      selected: _selectedType == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...SubjectType.values.map((type) => 
                      _buildFilterChip(
                        label: _getSubjectTypeName(type, isZh),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 科目列表
        Expanded(
          child: filteredSubjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isZh ? '暫無科目' : 'No subjects',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isZh ? '點擊右下角加號新增科目' : 'Tap the plus button to add a subject',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredSubjects.length,
                  padding: const EdgeInsets.only(bottom: 120), // 為 FAB 留出空間
                  itemBuilder: (context, index) {
                    final subject = filteredSubjects[index];
                    return _buildSubjectCard(subject, context);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.bold : null,
      ),
    );
  }
  
  Widget _buildSubjectCard(Subject subject, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isZh = localeProvider.locale.languageCode == 'zh';
    
    // 根據科目類型選擇背景顏色
    Color bgColor;
    switch (subject.type) {
      case SubjectType.math:
        bgColor = Colors.blue;
        break;
      case SubjectType.science:
        bgColor = Colors.green;
        break;
      case SubjectType.language:
        bgColor = Colors.purple;
        break;
      case SubjectType.socialStudies:
        bgColor = Colors.orange;
        break;
      case SubjectType.art:
        bgColor = Colors.pink;
        break;
      case SubjectType.physicalEd:
        bgColor = Colors.teal;
        break;
      case SubjectType.other:
        bgColor = Colors.grey;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showSubjectDetailsDialog(context, subject);
        },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // 標題欄
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? bgColor.withOpacity(0.3) : bgColor.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: bgColor,
                    child: Icon(
                      _getSubjectIcon(subject.type),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subject.teacher != null && subject.teacher!.isNotEmpty)
                          Text(
                            subject.teacher!,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (subject.hasHomework)
                        Chip(
                          label: Text(
                            isZh ? '作業' : 'HW',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: colorScheme.primary,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      if (subject.hasExam)
                        Chip(
                          label: Text(
                            isZh ? '考試' : 'Exam',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: colorScheme.error,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 科目詳情
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subject.description != null && subject.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        subject.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getSubjectTypeName(subject.type, isZh),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      
                      if (subject.location != null && subject.location!.isNotEmpty) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subject.location!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSubjectDetailsDialog(BuildContext context, Subject subject) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    final isZh = locale.languageCode == 'zh';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(subject.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subject.description != null && subject.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      subject.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  
                ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(isZh ? '類型' : 'Type'),
                  subtitle: Text(_getSubjectTypeName(subject.type, isZh)),
                ),
                
                if (subject.teacher != null && subject.teacher!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(isZh ? '教師' : 'Teacher'),
                    subtitle: Text(subject.teacher!),
                  ),
                  
                if (subject.location != null && subject.location!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(isZh ? '地點' : 'Location'),
                    subtitle: Text(subject.location!),
                  ),
                  
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: Text(isZh ? '作業' : 'Homework'),
                  trailing: Switch(
                    value: subject.hasHomework,
                    onChanged: null,
                  ),
                ),
                
                ListTile(
                  leading: const Icon(Icons.quiz),
                  title: Text(isZh ? '考試' : 'Exam'),
                  trailing: Switch(
                    value: subject.hasExam,
                    onChanged: null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isZh ? '關閉' : 'Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 導航到編輯科目頁面
                Navigator.pushNamed(
                  context, 
                  '/edit_subject',
                  arguments: subject.id,
                );
              },
              child: Text(isZh ? '編輯' : 'Edit'),
            ),
          ],
        );
      },
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
  
  IconData _getSubjectIcon(SubjectType type) {
    switch (type) {
      case SubjectType.math:
        return Icons.calculate;
      case SubjectType.science:
        return Icons.science;
      case SubjectType.language:
        return Icons.translate;
      case SubjectType.socialStudies:
        return Icons.history_edu;
      case SubjectType.art:
        return Icons.palette;
      case SubjectType.physicalEd:
        return Icons.sports_basketball;
      case SubjectType.other:
        return Icons.book;
    }
  }
} 