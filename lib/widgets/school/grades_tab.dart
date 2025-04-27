import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/providers/grade_provider.dart';
import 'package:edurium/providers/subject_provider.dart';
import 'package:edurium/models/grade.dart';
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
            return _GradeCard(grade: grade);
          },
        );
      },
    );
  }

  /// 確保輸入是一個有效的 Grade 對象
  Grade _ensureGradeObject(dynamic input) {
    if (input is Grade) {
      return input;
    } else if (input is String) {
      // 假設輸入是 gradeId，嘗試從 GradeProvider 獲取
      final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
      try {
        return gradeProvider.getGradeById(input) ?? Grade(
          id: '', 
          title: '',
          score: 0,
          maxScore: 100,
          date: DateTime.now(),
          type: GradeType.homework,
        );
      } catch (e) {
        debugPrint('無法找到 Grade 對象: $e');
      }
    }
    
    // 返回默認的空 Grade 對象
    return Grade(
      id: '', 
      title: '',
      score: 0,
      maxScore: 100,
      date: DateTime.now(),
      type: GradeType.homework,
    );
  }

  Widget _buildGradeItem(dynamic gradeData) {
    if (gradeData == null) return const SizedBox.shrink();
    
    final Grade grade = gradeData is Grade ? gradeData : Grade.fromJson(gradeData);
    if (!_isValidGrade(grade)) return const SizedBox.shrink();
    
    final Subject? subject = _getSubjectForGrade(grade);
    
    return _GradeCard(
      grade: grade,
      subject: subject,
      onTap: () => _navigateToGradeDetail(grade),
    );
  }

  Color _getGradeColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  // 獲取成績對應的科目
  Subject? _getSubjectForGrade(Grade grade) {
    if (grade.subjectId == null) return null;
    
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    try {
      return subjectProvider.getSubjectById(grade.subjectId!);
    } catch (e) {
      debugPrint('無法找到科目: $e');
      return null;
    }
  }

  void _navigateToGradeDetail(Grade grade) {
    // 導航到成績詳情頁面
    Navigator.of(context).pushNamed(
      '/grade_detail',
      arguments: grade.id,
    );
  }

  bool _isValidGrade(Grade grade) {
    return grade.id != null && grade.value != null;
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
    final Color gradeColor = _getGradeColor(grade.value ?? 0, context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                    '${grade.value?.toStringAsFixed(1) ?? "N/A"}',
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
                      subject?.name ?? '未知科目',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (grade.description != null && grade.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          grade.description!,
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
    
    if (value >= 9.0) {
      return Colors.green;
    } else if (value >= 7.0) {
      return Colors.blue;
    } else if (value >= 5.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
} 