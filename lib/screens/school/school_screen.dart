import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../utils/constants.dart';
import '../../themes/app_theme.dart';
import '../../models/subject.dart';

import 'tabs/schedule_tab.dart';
import 'tabs/teachers_tab.dart';
import 'tabs/grades_tab.dart';
import 'tabs/subjects_tab.dart';

class SchoolScreen extends StatefulWidget {
  const SchoolScreen({super.key, this.screenKey});
  
  final GlobalKey<SchoolScreenState>? screenKey;

  @override
  State<SchoolScreen> createState() => SchoolScreenState();
}

class SchoolScreenState extends State<SchoolScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    
    // 監聽標籤頁變化
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() {});
      }
    });
    
    // 處理初始標籤索引
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('initialTabIndex')) {
        final initialTabIndex = args['initialTabIndex'] as int;
        if (initialTabIndex >= 0 && initialTabIndex < tabController.length) {
          switchToTab(initialTabIndex);
        }
      }
    });
  }
  
  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
  
  // 切換到指定的標籤頁
  void switchToTab(int index) {
    if (mounted && index >= 0 && index < tabController.length) {
      setState(() {
        tabController.animateTo(index);
      });
    }
  }
  
  // 獲取導航標題
  String _getNavigationTitle(bool isZh) {
    return isZh ? '學校' : 'School';
  }

  // 獲取標籤頁標題
  List<String> _getTabTitles(bool isZh) {
    return isZh 
      ? ['科目', '成績', '課表', '老師'] 
      : ['Subjects', 'Grades', 'Schedule', 'Teachers'];
  }

  // 獲取浮動按鈕提示文字
  List<String> _getFabTooltips(bool isZh) {
    return isZh 
      ? ['新增科目', '新增成績', '新增課表', '新增老師'] 
      : ['Add Subject', 'Add Grade', 'Add Schedule', 'Add Teacher'];
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isZh = localeProvider.locale.languageCode == 'zh';
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    final theme = Theme.of(context);
    
    final tabTitles = _getTabTitles(isZh);
    final fabTooltips = _getFabTooltips(isZh);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getNavigationTitle(isZh)),
        elevation: 0,
        actions: [
          // 學校頁面的快速選擇科目下拉菜單
          _buildSubjectSelector(context),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBarView(tabTitles),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          SubjectsTab(),
          GradesTab(),
          ScheduleTab(),
          TeachersTab(),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primary,
            ],
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            // 根據當前標籤導航到相應的頁面
            switch (tabController.index) {
              case 0: // 科目標籤頁
                Navigator.pushNamed(context, '/add_subject');
                break;
              case 1: // 成績標籤頁
                Navigator.pushNamed(context, '/add_grade');
                break;
              case 2: // 課表標籤頁
                Navigator.pushNamed(context, '/add_schedule');
                break;
              case 3: // 老師標籤頁
                Navigator.pushNamed(context, '/add_teacher');
                break;
            }
          },
          tooltip: fabTooltips[tabController.index],
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.onPrimary,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTabBarView(List<String> tabTitles) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColorConstants.primaryColor,
            AppColorConstants.secondaryColor,
          ],
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withAlpha(180),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: tabTitles[0]),
          Tab(text: tabTitles[1]),
          Tab(text: tabTitles[2]),
          Tab(text: tabTitles[3]),
        ],
      ),
    );
  }
  
  Widget _buildSubjectSelector(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final subjects = subjectProvider.subjects;
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isZh = locale.languageCode == 'zh';
    
    return PopupMenuButton<String>(
      icon: const Icon(Icons.book),
      tooltip: isZh ? '選擇科目' : 'Select Subject',
      onSelected: (String subjectId) {
        // 處理選中科目，可以導航到科目詳情頁或執行其他操作
        _showSubjectDetailsDialog(context, subjectId);
      },
      itemBuilder: (BuildContext context) {
        // 確保課程資料已載入
        if (subjects.isEmpty) {
          // 觸發載入科目
          Future.microtask(() => subjectProvider.loadSubjects());
          
          return [
            PopupMenuItem<String>(
              enabled: false,
              child: Text(isZh ? '載入科目中...' : 'Loading subjects...'),
            ),
          ];
        }
        
        // 將科目按類型分組
        final Map<SubjectType, List<Subject>> groupedSubjects = {};
        for (var subject in subjects) {
          if (groupedSubjects[subject.type] == null) {
            groupedSubjects[subject.type] = [];
          }
          groupedSubjects[subject.type]!.add(subject);
        }
        
        final List<PopupMenuEntry<String>> menuItems = [];
        
        // 添加每個科目類型的項目
        groupedSubjects.forEach((type, subjects) {
          // 添加科目類型標題
          menuItems.add(
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                _getSubjectTypeName(type, isZh),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          );
          
          // 添加該類型下的所有科目
          for (var subject in subjects) {
            menuItems.add(
              PopupMenuItem<String>(
                value: subject.id,
                child: Text(subject.name),
              ),
            );
          }
          
          // 添加分隔線
          if (type != groupedSubjects.keys.last) {
            menuItems.add(const PopupMenuDivider());
          }
        });
        
        // 添加新增科目選項
        if (menuItems.isNotEmpty) {
          menuItems.add(const PopupMenuDivider());
        }
        
        menuItems.add(
          PopupMenuItem<String>(
            value: 'add_new',
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(isZh ? '新增科目' : 'Add Subject'),
              ],
            ),
          ),
        );
        
        return menuItems;
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
  
  void _showSubjectDetailsDialog(BuildContext context, String subjectId) {
    if (subjectId == 'add_new') {
      // 導航到新增科目頁面
      Navigator.pushNamed(context, '/add_subject');
      return;
    }
    
    // 從 Provider 獲取科目信息
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final subject = subjectProvider.getSubjectById(subjectId);
    
    if (subject == null) return;
    
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
} 