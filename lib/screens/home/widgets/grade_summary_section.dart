import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/utils.dart';

class GradeSummarySection extends StatelessWidget {
  const GradeSummarySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradeProvider = Provider.of<GradeProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final String sectionTitle = locale.languageCode == 'zh' ? '成績總覽' : 'Grade Overview';
    final String noGradesText = locale.languageCode == 'zh' 
        ? '尚未添加成績' 
        : 'No grades added yet';
    final String viewAllText = locale.languageCode == 'zh' 
        ? '查看全部' 
        : 'View All';
    final String gpaText = locale.languageCode == 'zh' 
        ? 'GPA' 
        : 'GPA';
    
    final grades = gradeProvider.grades;
    final subjects = subjectProvider.subjects;
    
    // 計算整體GPA
    final double overallGPA = gradeProvider.calculateOverallGPA();
    
    // 獲取最近的成績
    final List<Grade> recentGrades = List.from(grades)
      ..sort((a, b) {
        if (a.gradedDate == null) return 1;
        if (b.gradedDate == null) return -1;
        return b.gradedDate!.compareTo(a.gradedDate!);
      });
    final recentGradesToShow = recentGrades.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sectionTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (grades.isNotEmpty)
              TextButton(
                onPressed: () {
                  // 導航到成績頁面
                },
                child: Text(
                  viewAllText,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // 成績內容
        if (grades.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.assessment_outlined,
                  size: 48,
                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  noGradesText,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        else
          Column(
            children: [
              // GPA卡片和成績分佈
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? AppColors.primaryDark.withOpacity(0.15) 
                      : AppColors.primaryLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode 
                        ? AppColors.primaryDark.withOpacity(0.3) 
                        : AppColors.primaryLight.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // GPA 部分
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gpaText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode 
                                  ? AppColors.primaryDark 
                                  : AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                overallGPA.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '/ 4.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildGPAIndicator(context, overallGPA),
                        ],
                      ),
                    ),
                    
                    // 分隔線
                    Container(
                      height: 80,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: isDarkMode 
                          ? Colors.grey.shade700 
                          : Colors.grey.shade300,
                    ),
                    
                    // 成績分佈圓餅圖
                    Expanded(
                      flex: 4,
                      child: _buildGradeDistributionChart(context, gradeProvider),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 最近成績
              if (recentGradesToShow.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.languageCode == 'zh' ? '最近成績' : 'Recent Grades',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...recentGradesToShow.map((grade) => _buildRecentGradeItem(context, grade)).toList(),
                  ],
                ),
            ],
          ),
      ],
    );
  }
  
  // GPA指示器
  Widget _buildGPAIndicator(BuildContext context, double gpa) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // GPA顏色
    Color getGPAColor(double gpa) {
      if (gpa >= 3.7) return Colors.green;
      if (gpa >= 3.0) return Colors.lightGreen;
      if (gpa >= 2.3) return Colors.amber;
      if (gpa >= 1.7) return Colors.orange;
      return Colors.red;
    }
    
    final gpaColor = getGPAColor(gpa);
    final progress = (gpa / 4.0).clamp(0.0, 1.0);
    
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: gpaColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
  
  // 成績分佈圓餅圖
  Widget _buildGradeDistributionChart(BuildContext context, GradeProvider gradeProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final distribution = gradeProvider.getGradeDistribution();
    
    // 定義區間顏色
    final Map<String, Color> rangeColors = {
      '90-100': Colors.green,
      '80-89': Colors.lightGreen,
      '70-79': Colors.amber,
      '60-69': Colors.orange,
      '0-59': Colors.red,
    };
    
    // 準備餅圖數據
    final List<PieChartSectionData> sections = [];
    
    distribution.forEach((range, count) {
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: rangeColors[range]!,
            value: count.toDouble(),
            title: '',
            radius: 30,
            titleStyle: const TextStyle(
              fontSize: 0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });
    
    // 如果沒有數據，添加一個灰色的佔位圖
    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          value: 1,
          title: '',
          radius: 30,
          titleStyle: const TextStyle(
            fontSize: 0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          Provider.of<LocaleProvider>(context).locale.languageCode == 'zh' 
              ? '成績分佈' 
              : 'Grade Distribution',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
          ),
        ),
        
        SizedBox(
          height: 120,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 20,
              sectionsSpace: 2,
              startDegreeOffset: 180,
            ),
          ),
        ),
      ],
    );
  }
  
  // 最近成績項目
  Widget _buildRecentGradeItem(BuildContext context, Grade grade) {
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final subject = grade.subjectId != null ? subjectProvider.getSubjectById(grade.subjectId!) : null;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final locale = Provider.of<LocaleProvider>(context).locale;
    
    // 成績顏色
    Color getScoreColor(double percentage) {
      if (percentage >= 90) return Colors.green;
      if (percentage >= 80) return Colors.lightGreen;
      if (percentage >= 70) return Colors.amber;
      if (percentage >= 60) return Colors.orange;
      return Colors.red;
    }
    
    final percentage = grade.getPercentage();
    final scoreColor = getScoreColor(percentage);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 成績
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                percentage.toStringAsFixed(0),
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 標題和課程
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.title ?? (locale.languageCode == 'zh' ? '無標題' : 'Untitled'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (subject != null)
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          // 得分和日期
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${grade.score}/${grade.totalPoints}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scoreColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                grade.gradedDate != null ? DateUtil.formatDate(grade.gradedDate!) : '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 