import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/models.dart';
import 'providers/providers.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/main_screen.dart'; 
import 'screens/school/school_screen.dart';
import 'screens/school/screens/subject_form_screen.dart';
import 'screens/school/screens/subject_detail_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/add_grade_screen.dart';
import 'themes/app_theme.dart';
import 'utils/constants.dart';
import 'utils/navigation_handler.dart';
import 'l10n/app_localizations.dart';
import 'package:edurium/utils/route_constants.dart';
import 'package:edurium/models/task.dart';

// 臨時的AddTaskScreen實現
class AddTaskScreen extends StatelessWidget {
  final DateTime? initialDate;
  final TaskType? initialTaskType;
  
  const AddTaskScreen({Key? key, this.initialDate, this.initialTaskType}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增任務'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('新增任務頁面'),
            const SizedBox(height: 8),
            Text('初始日期: ${initialDate?.toString() ?? "未設定"}'),
            if (initialTaskType != null)
              Text('任務類型: ${_getTaskTypeName(initialTaskType!)}'),
          ],
        ),
      ),
    );
  }
  
  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.homework:
        return '作業';
      case TaskType.exam:
        return '考試';
      case TaskType.project:
        return '專案';
      case TaskType.reading:
        return '閱讀';
      case TaskType.meeting:
        return '會議';
      case TaskType.reminder:
        return '提醒';
      case TaskType.other:
        return '其他';
    }
  }
}

Future<void> main() async {
  try {
    // 確保 Flutter 綁定初始化
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Flutter 綁定已初始化');
    
    // 初始化 Hive
    await Hive.initFlutter();
    debugPrint('Hive 已初始化');
    
    try {
      // 註冊 Hive 適配器
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(TaskTypeAdapter());
      Hive.registerAdapter(TaskPriorityAdapter());
      Hive.registerAdapter(SubjectAdapter());
      Hive.registerAdapter(TeacherAdapter());
      Hive.registerAdapter(GradeAdapter());
      Hive.registerAdapter(GradeTypeAdapter());
      Hive.registerAdapter(UserAdapter());
      debugPrint('Hive 適配器已註冊');
    } catch (e) {
      debugPrint('註冊 Hive 適配器時出錯: $e');
    }
    
    try {
      // 打開 Hive 盒子
      await Hive.openBox<Task>(AppConstants.taskBoxName);
      await Hive.openBox<Subject>(AppConstants.subjectBoxName);
      await Hive.openBox<Teacher>(AppConstants.teacherBoxName);
      await Hive.openBox<Grade>(AppConstants.gradeBoxName);
      await Hive.openBox(AppConstants.settingsBoxName);
      await Hive.openBox<User>(AppConstants.userBoxName);
      debugPrint('Hive 盒子已打開');
    } catch (e) {
      debugPrint('打開 Hive 盒子時出錯: $e');
    }
    
    // 設置系統 UI 覆蓋樣式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    
    // 設置首選方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // 初始化導航處理器
    NavigationHandler.init('/splash');
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('初始化時發生嚴重錯誤: $e');
    debugPrint('堆疊追蹤: $stackTrace');
    
    // 在錯誤狀態下啟動一個簡化版本的應用
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('應用程式初始化錯誤: $e', textAlign: TextAlign.center),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => GradeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(
              primaryColor: themeProvider.primaryColor,
              secondaryColor: themeProvider.secondaryColor,
              accentColor: themeProvider.accentColor,
            ),
            darkTheme: AppTheme.darkTheme(
              primaryColor: themeProvider.primaryColor,
              secondaryColor: themeProvider.secondaryColor,
              accentColor: themeProvider.accentColor,
            ),
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('zh', 'TW'), // 繁體中文
              Locale('zh', 'CN'), // 簡體中文
              Locale('en'),       // 英文
              Locale('ja'),       // 日文
              Locale('ko'),       // 韓文
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            routes: {
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.home: (context) => const HomeScreen(),
              AppRoutes.main: (context) => const MainScreen(),
              AppRoutes.calendar: (context) => const CalendarScreen(),
              AppRoutes.school: (context) => const SchoolScreen(),
              AppRoutes.settings: (context) => const SettingsScreen(),
              AppRoutes.search: (context) => const SearchScreen(),
              AppRoutes.addTask: (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                DateTime? initialDate;
                TaskType? initialTaskType;
                
                if (args is DateTime) {
                  initialDate = args;
                } else if (args is Map<String, dynamic>) {
                  initialDate = args['initialDate'] as DateTime?;
                  if (args.containsKey('initialTaskType')) {
                    initialTaskType = args['initialTaskType'] as TaskType;
                  }
                }
                
                return AddTaskScreen(
                  initialDate: initialDate,
                  initialTaskType: initialTaskType,
                );
              },
              AppRoutes.addSubject: (context) => const SubjectFormScreen(),
              AppRoutes.addTeacher: (context) => const Scaffold(body: Center(child: Text('新增教師頁面'))),
              AppRoutes.addGrade: (context) => const AddGradeScreen(),
              AppRoutes.editSubject: (context) => SubjectFormScreen(
                subjectId: ModalRoute.of(context)?.settings.arguments as String,
              ),
              AppRoutes.subjectDetail: (context) => SubjectDetailScreen(
                subjectId: ModalRoute.of(context)?.settings.arguments as String,
              ),
              AppRoutes.tasksBySubject: (context) => Scaffold(
                appBar: AppBar(
                  title: Text('科目相關任務'),
                ),
                body: Center(
                  child: Text('科目相關任務頁面將在此實現'),
                ),
              ),
              AppRoutes.gradesBySubject: (context) => Scaffold(
                appBar: AppBar(
                  title: Text('科目成績'),
                ),
                body: Center(
                  child: Text('科目成績頁面將在此實現'),
                ),
              ),
            },
            scrollBehavior: MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
              },
            ).copyWith(physics: const BouncingScrollPhysics()),
            // 使用自定義路由觀察者
            navigatorObservers: [
              EduriumRouteObserver(),
            ],
            // 使用自定義頁面轉場動畫
            onGenerateRoute: (settings) {
              // 這裡可以根據路由名稱進行條件判斷，返回不同的頁面
              return NavigationHandler.buildSmoothPageRoute(
                page: _buildPageFromSettings(settings),
                routeName: settings.name ?? '/unknown',
                arguments: settings.arguments,
              );
            },
          );
        },
      ),
    );
  }
  
  // 根據路由設置構建頁面
  Widget _buildPageFromSettings(RouteSettings settings) {
    // 這裡應該根據路由名稱返回相應的頁面
    String routeName = settings.name ?? '/unknown';
    Object? arguments = settings.arguments;
    
    // 如果路由已經在routes中定義，則直接使用
    switch (routeName) {
      case AppRoutes.splash:
        return const SplashScreen();
      case AppRoutes.home:
        return const HomeScreen();
      case AppRoutes.main:
        return const MainScreen();
      case AppRoutes.calendar:
        return const CalendarScreen();
      case AppRoutes.school:
        return const SchoolScreen();
      case AppRoutes.settings:
        return const SettingsScreen();
      case AppRoutes.search:
        return const SearchScreen();
      case AppRoutes.addTask:
        DateTime? initialDate;
        TaskType? initialTaskType;
        
        if (arguments is DateTime) {
          initialDate = arguments;
        } else if (arguments is Map<String, dynamic>) {
          initialDate = arguments['initialDate'] as DateTime?;
          if (arguments.containsKey('initialTaskType')) {
            initialTaskType = arguments['initialTaskType'] as TaskType;
          }
        }
        
        return AddTaskScreen(
          initialDate: initialDate,
          initialTaskType: initialTaskType,
        );
      case AppRoutes.addSubject:
        return const SubjectFormScreen();
      case AppRoutes.addTeacher:
        return const Scaffold(body: Center(child: Text('新增教師頁面')));
      case AppRoutes.addGrade:
        return const AddGradeScreen();
      case AppRoutes.editSubject:
        final subjectId = arguments as String;
        return SubjectFormScreen(subjectId: subjectId);
      case AppRoutes.subjectDetail:
        final subjectId = arguments as String;
        return SubjectDetailScreen(subjectId: subjectId);
      case AppRoutes.tasksBySubject:
        return Scaffold(
          appBar: AppBar(
            title: Text('科目相關任務'),
          ),
          body: Center(
            child: Text('科目相關任務頁面將在此實現'),
          ),
        );
      case AppRoutes.gradesBySubject:
        return Scaffold(
          appBar: AppBar(
            title: Text('科目成績'),
          ),
          body: Center(
            child: Text('科目成績頁面將在此實現'),
          ),
        );
      default:
        // 如果找不到匹配的路由，返回錯誤頁面
        return Scaffold(
          appBar: AppBar(title: const Text('頁面未找到')),
          body: Center(
            child: Text('找不到路由: $routeName'),
          ),
        );
    }
  }
}

// 自定義路由觀察者，用於跟踪頁面導航
class EduriumRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    
    if (route is PageRoute && route.settings.name != null) {
      debugPrint('Navigation: Pushed ${route.settings.name}');
    }
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    
    if (route is PageRoute && route.settings.name != null) {
      debugPrint('Navigation: Popped ${route.settings.name}');
    }
  }
}

// 導航提供者，用於在整個應用程序中共享導航狀態
class NavigationProvider extends ChangeNotifier {
  // 當前活動頁面的路由名稱
  String _currentRoute = AppRoutes.splash;
  
  // 頁面歷史記錄
  final List<String> _history = [AppRoutes.splash];
  
  // 最大歷史記錄大小
  static const int _maxHistorySize = 10;
  
  // 獲取當前路由
  String get currentRoute => _currentRoute;
  
  // 獲取歷史記錄
  List<String> get history => List.unmodifiable(_history);
  
  // 添加路由到歷史記錄
  void addRoute(String route) {
    // 添加新路由到歷史記錄
    _history.add(route);
    
    // 限制歷史記錄大小
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
    
    // 更新當前路由
    _currentRoute = route;
    
    // 通知監聽器
    notifyListeners();
  }
  
  // 返回上一頁
  String? goBack() {
    if (_history.length > 1) {
      // 移除當前頁面
      _history.removeLast();
      
      // 獲取新的當前頁面
      _currentRoute = _history.last;
      
      // 通知監聽器
      notifyListeners();
      
      return _currentRoute;
    }
    
    return null;
  }
  
  // 清空歷史記錄
  void clearHistory() {
    _history.clear();
    _history.add(_currentRoute);
    notifyListeners();
  }
}
