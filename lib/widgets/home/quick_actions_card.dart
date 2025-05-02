import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/providers/locale_provider.dart';
import 'package:edurium/widgets/common/app_card.dart';
import 'package:edurium/utils/navigation_handler.dart';
import 'package:edurium/utils/route_constants.dart';
import 'package:edurium/models/task.dart';
import 'package:edurium/screens/add_task/add_task_screen.dart';
import 'package:edurium/screens/add_grade_screen.dart';

/// 首頁上的快速操作卡片
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isZh = locale.languageCode == 'zh';
    
    return AppCard(
      title: isZh ? '快速操作' : 'Quick Actions',
      titleIcon: Icons.flash_on,
      child: Column(
        children: [
          // 第一行按鈕
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                icon: Icons.assignment_add,
                label: isZh ? '加入作業' : 'Add Homework',
                color: Colors.amber.shade700,
                onTap: () {
                  // 導航到添加任務頁面，使用路由名稱
                  Navigator.pushNamed(
                    context,
                    AppRoutes.addTask,
                    arguments: {'initialTaskType': TaskType.homework},
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.quiz,
                label: isZh ? '加入考試' : 'Add Exam',
                color: Colors.red.shade700,
                onTap: () {
                  // 導航到添加任務頁面，使用路由名稱
                  Navigator.pushNamed(
                    context,
                    AppRoutes.addTask,
                    arguments: {'initialTaskType': TaskType.exam},
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.grade,
                label: isZh ? '記錄成績' : 'Add Grade',
                color: Colors.green.shade700,
                onTap: () {
                  // 使用路由名稱導航到添加成績頁面
                  Navigator.pushNamed(context, AppRoutes.addGrade);
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 第二行按鈕
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                icon: Icons.event_note,
                label: isZh ? '查看課表' : 'Schedule',
                color: Colors.indigo.shade400,
                onTap: () {
                  // 直接導航到學校頁面，指定課表標籤
                  Navigator.pushNamed(
                    context,
                    AppRoutes.school,
                    arguments: {'initialTabIndex': 2}, // 課表標籤
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.person,
                label: isZh ? '教師信息' : 'Teachers',
                color: Colors.purple.shade400,
                onTap: () {
                  // 直接導航到學校頁面，指定教師標籤
                  Navigator.pushNamed(
                    context,
                    AppRoutes.school,
                    arguments: {'initialTabIndex': 3}, // 教師標籤
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.analytics,
                label: isZh ? '成績統計' : 'Analytics',
                color: Colors.teal.shade700,
                onTap: () {
                  // 直接導航到學校頁面，指定成績標籤
                  Navigator.pushNamed(
                    context,
                    AppRoutes.school,
                    arguments: {'initialTabIndex': 1}, // 成績標籤
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 