import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/providers/subject_provider.dart';
import 'package:edurium/providers/teacher_provider.dart';
import 'package:edurium/models/subject.dart';
import 'package:edurium/utils/date_util.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  int _selectedDay = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDaySelector(),
        Expanded(
          child: _buildSchedule(),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(5, (index) {
            final day = index + 1;
            final isSelected = _selectedDay == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDay = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getDayName(day),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSchedule() {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        // TODO: 實現 getSubjectsForDay 方法
        // final subjects = subjectProvider.getSubjectsForDay(_selectedDay + 1);
        // 臨時解決方案
        final List<Subject> subjects = [];
        
        if (subjects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school,
                  size: 64,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '今日無課程',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return _SubjectCard(subject: subject);
          },
        );
      },
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return '星期一';
      case 2:
        return '星期二';
      case 3:
        return '星期三';
      case 4:
        return '星期四';
      case 5:
        return '星期五';
      default:
        return '';
    }
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;

  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final teacher = subject.teacherId != null ? teacherProvider.getTeacherById(subject.teacherId!) : null;
    
    // 獲取課程顏色
    Color subjectColor;
    if (subject.color != null) {
      if (subject.color is int) {
        subjectColor = Color(subject.color as int);
      } else if (subject.color is String) {
        try {
          subjectColor = Color(int.parse((subject.color as String).replaceAll('#', '0xFF')));
        } catch (e) {
          subjectColor = Theme.of(context).primaryColor;
        }
      } else {
        subjectColor = Theme.of(context).primaryColor;
      }
    } else {
      subjectColor = Theme.of(context).primaryColor;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: subjectColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: subjectColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              subject.name.substring(0, 1),
              style: TextStyle(
                color: subjectColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${teacher?.name ?? '未指定'} 老師'),
            const SizedBox(height: 4),
            // TODO: 實現課程開始和結束時間屬性
            // Text(
            //   '${DateUtil.formatTime(subject.startTime)} - ${DateUtil.formatTime(subject.endTime)}',
            //   style: TextStyle(
            //     color: Colors.grey.shade600,
            //   ),
            // ),
            Text(
              '時間未設定',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            // TODO: 顯示科目詳情
          },
        ),
      ),
    );
  }
} 