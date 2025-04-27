/// 應用程式中使用的所有路由常數
/// 
/// 這個類集中管理所有路由名稱，避免硬編碼字串出現在程式碼中
/// 使用這個類可以提高路由管理的可維護性和避免拼寫錯誤
class AppRoutes {
  // 主頁面
  static const String main = '/';
  static const String home = '/home';
  static const String school = '/school';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  
  // 學校相關頁面
  static const String addSubject = '/add_subject';
  static const String editSubject = '/edit_subject';
  static const String subjectDetail = '/subject_detail';
  static const String addGrade = '/add_grade';
  static const String gradesBySubject = '/grades_by_subject';
  static const String addSchedule = '/add_schedule';
  static const String scheduleDetail = '/schedule_detail';
  static const String addTeacher = '/add_teacher';
  static const String teacherDetail = '/teacher_detail';
  
  // 任務相關頁面
  static const String addTask = '/add_task';
  static const String taskDetail = '/task_detail';
  static const String tasksBySubject = '/tasks_by_subject';
  
  // 其他頁面
  static const String search = '/search';
  static const String notification = '/notification';
  static const String profile = '/profile';
  static const String editProfile = '/edit_profile';
  static const String onboarding = '/onboarding';
  static const String splash = '/splash';
  
  // 未知路由
  static const String unknown = '/unknown';
} 