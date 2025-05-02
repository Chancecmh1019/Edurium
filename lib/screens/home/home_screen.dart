import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../../utils/utils.dart';
import '../../themes/app_theme.dart';
import 'package:edurium/providers/task_provider.dart';
import 'package:edurium/providers/grade_provider.dart';
import 'package:edurium/providers/user_provider.dart';
import 'package:edurium/widgets/home/upcoming_tasks_card.dart';
import 'package:edurium/widgets/home/grade_summary_card.dart';
import 'package:edurium/widgets/home/schedule_preview_card.dart';
import 'package:edurium/widgets/home/quick_actions_card.dart';
import 'package:edurium/utils/constants.dart';
import 'package:edurium/screens/add_task/add_task_screen.dart';
import 'package:edurium/screens/notification/notification_screen.dart';
import 'package:edurium/utils/date_utils.dart' as date_utils;
import 'package:edurium/widgets/home/motivation_quotes_card.dart';
import 'package:edurium/utils/navigation_handler.dart';
import 'package:edurium/utils/route_constants.dart';

import 'widgets/home_header.dart';
import 'widgets/today_tasks_section.dart';
import 'widgets/upcoming_events_section.dart';
import 'widgets/subject_summary_section.dart';
import 'widgets/grade_summary_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 獲取今天的日期
  String get _formattedDate {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    final now = DateTime.now();
    final weekday = date_utils.AppDateUtils.getWeekdayName(now, locale: locale);
    
    if (locale.languageCode == 'zh') {
      return '${now.year}年${now.month}月${now.day}日 $weekday';
    } else {
      return DateFormat('MMMM d, yyyy', locale.toString()).format(now) + 
             ' - ' + weekday;
    }
  }
  
  // 獲取浮動按鈕文字
  String get _newTaskButtonText {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return locale.languageCode == 'zh' ? '新增任務' : 'New Task';
  }
  
  // 獲取狀態卡片標題
  String get _statusCardTitle {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return locale.languageCode == 'zh' ? '本週學習狀態' : 'Weekly Study Status';
  }
  
  // 獲取學習狀態項目文字
  List<String> get _statusItemTitles {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return locale.languageCode == 'zh' 
      ? ['今日待辦', '已逾期', '本週完成', '完成率'] 
      : ['Today', 'Overdue', 'Completed', 'Completion'];
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 獲取待辦任務
    final todayTasks = taskProvider.getTodayTasks();
    final upcomingTasks = taskProvider.getUpcomingTasks();
    final overdueTasks = taskProvider.getOverdueTasks();
    
    // 檢查是否有任務
    final hasTasks = todayTasks.isNotEmpty || upcomingTasks.isNotEmpty || overdueTasks.isNotEmpty;
    
    // 檢查是否有通知
    final hasNotifications = userProvider.hasUnreadNotifications();
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<TaskProvider>(context, listen: false).loadTasks();
          await Provider.of<GradeProvider>(context, listen: false).loadGrades();
          await Provider.of<SubjectProvider>(context, listen: false).loadSubjects();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 頂部應用欄
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 16),
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.primaryContainer.withOpacity(0.8),
                        colorScheme.surface,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}，${userProvider.currentUser?.name ?? "同學"}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formattedDate,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // 通知按鈕
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        // 打開通知頁面
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    if (hasNotifications)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    NavigationHandler.navigateTo(context, AppRoutes.search);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            // 內容區域
            SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 學習狀態卡片
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: _buildStatusCard(context, taskProvider),
                  ),
                  
                  // 今日課程
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: SchedulePreviewCard(),
                  ),
                  
                  // 待辦任務
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: UpcomingTasksCard(),
                  ),
                  
                  // 成績概覽
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: GradeSummaryCard(),
                  ),
                  
                  // 快捷方式
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: QuickActionsCard(),
                  ),
                  
                  // 激勵語錄
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: MotivationQuotesCard(),
                  ),
                  
                  const SizedBox(height: 120), // 增加底部間距，確保內容不被遮擋
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
            // 導航到新增任務頁面
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTaskScreen(),
              ),
            );
          },
          tooltip: _newTaskButtonText,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.onPrimary,
          child: const Icon(Icons.add_task),
        ),
      ),
      // 將浮動按鈕位置調整為右下角，避免與底部導航欄重疊
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  // 學習狀態卡片
  Widget _buildStatusCard(BuildContext context, TaskProvider taskProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusItemTitles = _statusItemTitles;
    
    // 獲取今日任務
    final todayTasks = taskProvider.getTodayTasks();
    
    // 獲取本週完成任務
    final completedTasks = taskProvider.getCompletedTasksThisWeek();
    
    // 獲取已逾期任務
    final overdueTasks = taskProvider.getOverdueTasks();
    
    // 計算完成率
    final totalTasks = taskProvider.getAllTasksThisWeek().length;
    final completionRate = totalTasks > 0 
        ? (completedTasks.length / totalTasks * 100).round() 
        : 100;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusCardTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  context,
                  title: statusItemTitles[0],
                  value: '${todayTasks.length}',
                  icon: Icons.assignment_outlined,
                  color: colorScheme.primary,
                ),
                _buildStatusItem(
                  context,
                  title: statusItemTitles[1],
                  value: '${overdueTasks.length}',
                  icon: Icons.warning_outlined,
                  color: colorScheme.error,
                ),
                _buildStatusItem(
                  context,
                  title: statusItemTitles[2],
                  value: '${completedTasks.length}',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                _buildStatusItem(
                  context,
                  title: statusItemTitles[3],
                  value: '$completionRate%',
                  icon: Icons.trending_up,
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 學習狀態項
  Widget _buildStatusItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ],
    );
  }
  
  // 獲取問候語
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '凌晨好';
    } else if (hour < 12) {
      return '早上好';
    } else if (hour < 14) {
      return '中午好';
    } else if (hour < 18) {
      return '下午好';
    } else if (hour < 22) {
      return '晚上好';
    } else {
      return '夜深了';
    }
  }
} 