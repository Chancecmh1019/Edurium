import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/subject_provider.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

import 'home/home_screen.dart';
import 'calendar/calendar_screen.dart';
import 'school/school_screen.dart';
import 'settings/settings_screen.dart';
import 'add_task/add_task_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController pageController;
  
  // 獲取本地化文字
  List<String> get _homeLabels {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return locale.languageCode == 'zh' 
        ? ['首頁', '行事曆', '學校', '設定'] 
        : ['Home', 'Calendar', 'School', 'Settings'];
  }
  
  // 獲取任務類型標籤
  List<String> get _taskTypeLabels {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return locale.languageCode == 'zh' 
        ? ['作業', '考試', '專案', '提醒'] 
        : ['Homework', 'Exam', 'Project', 'Reminder'];
  }
  
  // 獲取新增項目文字
  String get _addNewLabel {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return locale.languageCode == 'zh' ? '新增項目' : 'Add new';
  }

  // 頁面列表
  final List<Widget> _pages = [
    const HomeScreen(),
    const CalendarScreen(),
    SchoolScreen(screenKey: GlobalKey<SchoolScreenState>()),
    const SettingsScreen(),
  ];

  // 底部導航欄項目
  List<BottomNavItem> get _bottomNavItems {
    final labels = _homeLabels;
    return [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: labels[0],
      ),
      BottomNavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: labels[1],
      ),
      BottomNavItem(
        icon: Icons.school_outlined,
        activeIcon: Icons.school,
        label: labels[2],
      ),
      BottomNavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: labels[3],
      ),
    ];
  }

  // 浮動按鈕項目
  List<FloatingActionItem> get _fabItems {
    final taskLabels = _taskTypeLabels;
    return [
      FloatingActionItem(
        icon: Icons.assignment,
        label: taskLabels[0],
        onPressed: () => _navigateToAddTask(TaskType.homework),
        heroTag: 'homework_fab',
      ),
      FloatingActionItem(
        icon: Icons.note_alt,
        label: taskLabels[1],
        onPressed: () => _navigateToAddTask(TaskType.exam),
        heroTag: 'exam_fab',
      ),
      FloatingActionItem(
        icon: Icons.science,
        label: taskLabels[2],
        onPressed: () => _navigateToAddTask(TaskType.project),
        heroTag: 'project_fab',
      ),
      FloatingActionItem(
        icon: Icons.notifications,
        label: taskLabels[3],
        onPressed: () => _navigateToAddTask(TaskType.reminder),
        heroTag: 'reminder_fab',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    
    // 確保科目資料在應用啟動時就載入
    Future.microtask(() {
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      subjectProvider.loadSubjects();
      
      // 檢查是否有需要處理的路由參數
      _handleRouteArguments();
    });
  }
  
  void _handleRouteArguments() {
    // 從 NavigationHandler 中獲取參數
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      // 檢查是否需要切換到特定標籤頁
      if (args.containsKey('tabIndex')) {
        final tabIndex = args['tabIndex'] as int;
        if (tabIndex >= 0 && tabIndex < _pages.length) {
          // 切換到指定的標籤頁
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _switchToTab(tabIndex);
            
            // 如果是學校頁面且有子標籤索引
            if (tabIndex == 2 && args.containsKey('subTabIndex')) {
              final subTabIndex = args['subTabIndex'] as int;
              _switchToSchoolSubTab(subTabIndex);
            }
          });
        }
      }
    }
  }
  
  void _switchToTab(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
        pageController.jumpToPage(index);
      });
    }
  }
  
  void _switchToSchoolSubTab(int subTabIndex) {
    // 獲取 SchoolScreen 實例
    if (_pages[2] is SchoolScreen) {
      final schoolScreen = _pages[2] as SchoolScreen;
      if (schoolScreen.screenKey != null) {
        schoolScreen.screenKey!.currentState?.switchToTab(subTabIndex);
      }
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // 切換頁面
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 切換底部導航
  void _onBottomNavTapped(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 導航到添加任務頁面
  void _navigateToAddTask(TaskType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(initialTaskType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(), // 禁止滑動切換頁面
          children: _pages,
        ),
      ),
      extendBody: true,
      bottomNavigationBar: EduriumBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        items: _bottomNavItems,
      ),
    );
  }
} 