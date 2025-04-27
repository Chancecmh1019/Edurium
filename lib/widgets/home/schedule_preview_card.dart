import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:edurium/models/subject.dart';
import 'package:edurium/providers/subject_provider.dart';
import 'package:edurium/screens/school/tabs/schedule_tab.dart';
import 'package:edurium/widgets/common/app_card.dart';
import 'package:edurium/widgets/common/empty_state.dart';
import 'package:edurium/utils/date_utils.dart' as date_utils;

/// 首頁上的課表預覽卡片
class SchedulePreviewCard extends StatelessWidget {
  /// 是否顯示當天課程（否則顯示明天課程）
  final bool showToday;
  
  const SchedulePreviewCard({
    super.key,
    this.showToday = true,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dayToShow = showToday ? today : tomorrow;
    final weekday = dayToShow.weekday;
    
    // 獲取星期幾的文字
    final weekdayName = date_utils.AppDateUtils.getWeekdayName(
      dayToShow, 
      locale: Localizations.localeOf(context),
    );
    
    // 格式化日期
    final dateFormatter = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final dateString = dateFormatter.format(dayToShow);
    
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        // 獲取當天課程
        final subjects = subjectProvider.getSubjectsForWeekday(weekday);
        final hasSubjects = subjects.isNotEmpty;
        
        return AppCard(
          title: showToday ? '今日課程' : '明日課程',
          titleIcon: Icons.calendar_today,
          actionButton: TextButton(
            onPressed: () {
              // 導航到課表頁面
              Navigator.pushNamed(context, '/school/schedule');
            },
            child: const Text('查看課表'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期顯示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$weekdayName - $dateString',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 課程列表
              hasSubjects
                  ? Column(
                      children: subjects
                          .map((subject) => _buildSubjectItem(context, subject))
                          .toList(),
                    )
                  : const EmptyState(
                      icon: Icons.event_available,
                      message: '今天沒有排課',
                      subMessage: '享受輕鬆的一天吧！',
                      compact: true,
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectItem(BuildContext context, Subject subject) {
    final theme = Theme.of(context);
    
    // 根據課程類型設置顏色和圖標
    Color subjectColor;
    IconData subjectIcon;
    
    switch (subject.type) {
      case SubjectType.math:
        subjectColor = Colors.blue;
        subjectIcon = Icons.calculate;
        break;
      case SubjectType.science:
        subjectColor = Colors.green;
        subjectIcon = Icons.science;
        break;
      case SubjectType.language:
        subjectColor = Colors.purple;
        subjectIcon = Icons.translate;
        break;
      case SubjectType.socialStudies:
        subjectColor = Colors.orange;
        subjectIcon = Icons.public;
        break;
      case SubjectType.art:
        subjectColor = Colors.pink;
        subjectIcon = Icons.palette;
        break;
      case SubjectType.physicalEd:
        subjectColor = Colors.red;
        subjectIcon = Icons.sports_soccer;
        break;
      default:
        subjectColor = Colors.grey;
        subjectIcon = Icons.school;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: subjectColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: subjectColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 時間信息
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: subjectColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  _formatTime(subject.startTime),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: subjectColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(subject.endTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: subjectColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // 課程信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      subjectIcon,
                      size: 16,
                      color: subjectColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (subject.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subject.location!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
                if (subject.teacher != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subject.teacher!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // 今日作業/考試提醒
          if (subject.hasHomework || subject.hasExam) ...[
            Column(
              children: [
                if (subject.hasHomework)
                  Tooltip(
                    message: '今日有作業',
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ),
                if (subject.hasExam)
                  Tooltip(
                    message: '今日有考試',
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.quiz,
                        size: 16,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 格式化時間
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--:--';
    }
    
    // 格式化小時和分鐘
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
} 