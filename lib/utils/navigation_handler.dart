import 'package:flutter/material.dart';

/// 處理應用內導航的工具類，提供一致的導航方法，採用Page API
class NavigationHandler {
  /// 應用程序的導航歷史記錄
  static final List<PageData> _history = [];
  
  /// 首頁路由
  static String _homeRoute = '/splash';
  
  /// 初始化導航
  static String? _initialRoute;
  
  /// 初始化導航處理器
  static void init(String homeRoute) {
    _homeRoute = homeRoute;
    _initialRoute = null;
    _history.clear();
  }
  
  /// 獲取初始路由
  static String? get initialRoute => _initialRoute;

  /// 創建導航器
  static Navigator createNavigator(List<Page<dynamic>> pages, {
    GlobalKey<NavigatorState>? navigatorKey,
    String? initialRoute,
    List<NavigatorObserver>? observers,
    TransitionDelegate<dynamic>? transitionDelegate,
  }) {
    return Navigator(
      key: navigatorKey,
      initialRoute: initialRoute,
      observers: observers ?? [],
      transitionDelegate: transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        return true;
      },
    );
  }

  /// 創建頁面
  static MaterialPage<T> createPage<T>({
    required Widget child,
    required String name,
    Object? arguments,
    LocalKey? key,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return MaterialPage<T>(
      child: child,
      name: name,
      arguments: arguments,
      key: key ?? ValueKey(name),
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
  
  /// 創建自定義頁面
  static Page<T> createCustomPage<T>({
    required Widget child,
    required String name,
    Object? arguments,
    LocalKey? key,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool fadeTransition = true,
  }) {
    return SmoothPage<T>(
      child: child,
      name: name,
      arguments: arguments,
      key: key,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      fadeTransition: fadeTransition,
    );
  }

  /// 導航到指定路由 (傳統Navigator 1.0方法)
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {
    Object? arguments,
  }) async {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// 替換當前頁面為新頁面 (傳統Navigator 1.0方法)
  static Future<T?> replaceTo<T>(BuildContext context, String routeName, {
    Object? arguments,
  }) async {
    return Navigator.of(context).pushReplacementNamed<T, dynamic>(
      routeName,
      arguments: arguments,
    );
  }

  /// 清除導航堆疊並導航到新頁面 (傳統Navigator 1.0方法)
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context, 
    String routeName, {
    Object? arguments,
    String? untilRouteName,
  }) async {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      untilRouteName != null 
        ? ModalRoute.withName(untilRouteName)
        : (route) => false,
      arguments: arguments,
    );
  }

  /// 導航到主頁面，清除所有其他頁面 (傳統Navigator 1.0方法)
  static void goToMainScreen(BuildContext context) {
    navigateAndRemoveUntil(context, '/main');
  }

  /// 返回前一頁面 (傳統Navigator 1.0方法)
  static void goBack<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// 嘗試返回，如果可以的話 (傳統Navigator 1.0方法)
  static bool tryGoBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      goBack(context);
      return true;
    }
    return false;
  }

  /// 獲取路由參數 (適用於Navigator 1.0和2.0)
  static T? getArguments<T>(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as T?;
  }

  /// 導航到學校頁面的科目標籤
  static Future<dynamic> goToSubjectsTab(BuildContext context) async {
    try {
      // 首先導航到主頁面
      await navigateTo(context, '/main');
      
      // 等待頁面加載
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 獲取MainScreen實例
      final mainScreenState = _findMainScreenState(context);
      if (mainScreenState != null) {
        // 切換到學校頁面（MainScreen中的第3個標籤）
        mainScreenState.pageController.jumpToPage(2); // 學校標籤索引為2
        
        // 等待頁面切換完成
        await Future.delayed(const Duration(milliseconds: 300));
        
        // 找到SchoolScreen實例
        final schoolScreenState = _findSchoolScreenState(context);
        if (schoolScreenState != null) {
          // 切換到科目標籤
          schoolScreenState.tabController.animateTo(0); // 科目是第一個標籤
          return null;
        }
      }
      
      // 如果無法通過Widget樹找到實例，則使用常規導航方法
      return navigateTo(context, '/school');
    } catch (e) {
      debugPrint('導航到科目標籤時出錯: $e');
      // 出錯時回退到普通導航
      return navigateTo(context, '/school');
    }
  }
  
  /// 尋找SchoolScreen的State實例
  static dynamic _findSchoolScreenState(BuildContext context) {
    dynamic schoolScreenState;
    
    void findInContext(BuildContext context) {
      context.visitChildElements((element) {
        // 如果已經找到，則停止尋找
        if (schoolScreenState != null) return;
        
        final state = (element as StatefulElement?)?.state;
        
        // 檢查是否是SchoolScreen的狀態
        if (state != null && state.toString().contains('_SchoolScreenState')) {
          schoolScreenState = state;
          return;
        }
        
        // 繼續在子元素中尋找
        findInContext(element);
      });
    }
    
    try {
      findInContext(context);
    } catch (e) {
      debugPrint('尋找SchoolScreenState時出錯: $e');
    }
    
    return schoolScreenState;
  }
  
  /// 尋找MainScreen的State實例
  static dynamic _findMainScreenState(BuildContext context) {
    dynamic mainScreenState;
    
    void findInContext(BuildContext context) {
      context.visitChildElements((element) {
        // 如果已經找到，則停止尋找
        if (mainScreenState != null) return;
        
        final state = (element as StatefulElement?)?.state;
        
        // 檢查是否是MainScreen的狀態
        if (state != null && state.toString().contains('_MainScreenState')) {
          mainScreenState = state;
          return;
        }
        
        // 繼續在子元素中尋找
        findInContext(element);
      });
    }
    
    try {
      findInContext(context);
    } catch (e) {
      debugPrint('尋找MainScreenState時出錯: $e');
    }
    
    return mainScreenState;
  }

  /// 添加一個新頁面到歷史記錄中
  static void addPage(String route, {Object? arguments, String? title}) {
    _history.add(PageData(
      route: route,
      arguments: arguments,
      title: title ?? route,
    ));
  }
  
  /// 創建一個自定義的平滑頁面路由
  static SmoothPageRoute buildSmoothPageRoute({
    required Widget page,
    required String routeName,
    Object? arguments,
    bool fadeTransition = true,
  }) {
    return SmoothPageRoute(
      page: page,
      routeName: routeName,
      arguments: arguments,
      fadeTransition: fadeTransition,
    );
  }
}

/// 頁面數據類
class PageData {
  final String route;
  final Object? arguments;
  final String title;
  
  PageData({
    required this.route,
    this.arguments,
    required this.title,
  });
  
  @override
  String toString() => 'PageData($title, $route)';
}

/// 自定義平滑頁面過渡 (Page API形式)
class SmoothPage<T> extends Page<T> {
  final Widget child;
  final bool fadeTransition;
  @override
  final bool maintainState;
  final bool fullscreenDialog;
  
  SmoothPage({
    required this.child,
    required String name,
    LocalKey? key,
    Object? arguments,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.fadeTransition = true,
  }) : super(
    key: key,
    name: name,
    arguments: arguments,
  );
  
  @override
  Route<T> createRoute(BuildContext context) {
    return PageBasedSmoothPageRoute<T>(
      page: this,
      child: child,
      fadeTransition: fadeTransition,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
}

/// 自定義頁面路由 (基於Page API的路由實現)
class PageBasedSmoothPageRoute<T> extends PageRoute<T> {
  final Page<T> page;
  final Widget child;
  final bool fadeTransition;
  @override
  final bool maintainState;
  
  PageBasedSmoothPageRoute({
    required this.page,
    required this.child,
    required this.fadeTransition,
    required this.maintainState,
    required bool fullscreenDialog,
  }) : super(
    settings: page,
    fullscreenDialog: fullscreenDialog,
  );
  
  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);
  
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);
  
  @override
  bool get opaque => true;
  
  @override
  bool get barrierDismissible => false;
  
  @override
  Color? get barrierColor => null;
  
  @override
  String? get barrierLabel => null;
  
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }
  
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.05, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);
    
    if (fadeTransition) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: offsetAnimation,
          child: child,
        ),
      );
    } else {
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    }
  }
}

/// 保留舊版路由類以向後兼容
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final String routeName;
  final Object? arguments;
  final bool fadeTransition;
  
  SmoothPageRoute({
    required this.page,
    required this.routeName,
    this.arguments,
    this.fadeTransition = true,
  }) : super(
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return page;
    },
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      const begin = Offset(0.05, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      
      if (fadeTransition) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      } else {
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      }
    },
    transitionDuration: const Duration(milliseconds: 250),
    settings: RouteSettings(
      name: routeName,
      arguments: arguments,
    ),
  );
} 