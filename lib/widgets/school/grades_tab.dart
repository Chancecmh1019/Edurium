import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/providers/grade_provider.dart';
import 'package:edurium/providers/subject_provider.dart';
import 'package:edurium/models/grade.dart';
import 'package:edurium/models/subject.dart';
import 'package:edurium/utils/date_util.dart';

class GradesTab extends StatelessWidget {
  const GradesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GradeProvider>(
      builder: (context, gradeProvider, child) {
        final grades = gradeProvider.grades;
        
        if (grades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.grade_outlined,
                  size: 64,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '尚未記錄任何成績',
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
          itemCount: grades.length,
          itemBuilder: (context, index) {
            final grade = grades[index];
            return _GradeCard(
              grade: grade,
              onTap: () => _navigateToGradeDetail(context, grade),
            );
          },
        );
      },
    );
  }

  void _navigateToGradeDetail(BuildContext context, Grade grade) {
    // 導航到成績詳情頁面
    Navigator.of(context).pushNamed(
      '/grade_detail',
      arguments: grade.id,
    );
  }
}

class _GradeCard extends StatelessWidget {
  final Grade grade;
  final Subject? subject;
  final VoidCallback onTap;

  const _GradeCard({
    required this.grade,
    this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    // 獲取顏色
    final Color gradeColor = _getGradeColor(grade.score, context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${grade.score.toStringAsFixed(1)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (grade.comment != null && grade.comment!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          grade.comment!,
                          style: textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '日期: ${_formatDate(grade.date)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '未知日期';
    return '${date.year}/${date.month}/${date.day}';
  }

  Color _getGradeColor(double value, BuildContext context) {
    final theme = Theme.of(context);
    
    if (value >= 90.0) {
      return Colors.green;
    } else if (value >= 70.0) {
      return Colors.blue;
    } else if (value >= 60.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
} 