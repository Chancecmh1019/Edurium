import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edurium/models/grade.dart';
import 'package:edurium/providers/grade_provider.dart';
import 'package:edurium/providers/subject_provider.dart';
import 'package:edurium/screens/school/tabs/grades_tab.dart';
import 'package:edurium/widgets/common/app_card.dart';
import 'package:edurium/widgets/common/empty_state.dart';

/// 首頁上的成績摘要卡片
class GradeSummaryCard extends StatelessWidget {
  /// 是否是迷你版本（用於小工具）
  final bool isMini;
  
  const GradeSummaryCard({
    super.key,
    this.isMini = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<GradeProvider, SubjectProvider>(
      builder: (context, gradeProvider, subjectProvider, child) {
        final recentGrades = gradeProvider.getRecentGrades(limit: 5);
        final hasGrades = recentGrades.isNotEmpty;
        
        return AppCard(
          title: '成績概覽',
          titleIcon: Icons.analytics,
          actionButton: TextButton(
            onPressed: () {
              // 導航到成績頁面
              Navigator.pushNamed(context, '/school/grades');
            },
            child: const Text('查看詳情'),
          ),
          child: hasGrades
              ? _buildGradeContent(context, recentGrades, gradeProvider)
              : const EmptyState(
                  icon: Icons.analytics_outlined,
                  message: '尚未記錄任何成績',
                  subMessage: '點擊右上角按鈕開始記錄您的學習成績',
                ),
        );
      },
    );
  }

  Widget _buildGradeContent(
    BuildContext context, 
    List<Grade> recentGrades,
    GradeProvider gradeProvider,
  ) {
    // 計算平均分和趨勢
    final avgScore = gradeProvider.getAverageScore();
    final gpaString = gradeProvider.getGPA().toStringAsFixed(2);
    final scoreTrend = gradeProvider.getScoreTrend();
    
    // 計算平均分數趨勢
    double? scoreAverage;
    double? trendPercentage;
    
    if (scoreTrend.isNotEmpty) {
      final trendValues = scoreTrend.values.toList();
      scoreAverage = trendValues.reduce((a, b) => a + b) / trendValues.length;
      // 計算趨勢百分比 (這裡假設是計算最新與平均的差距百分比)
      final latestValue = trendValues.last;
      trendPercentage = (latestValue - scoreAverage) / scoreAverage * 100;
    }
    
    return Column(
      children: [
        // 分數概覽
        Row(
          children: [
            // 平均分
            Expanded(
              child: _buildStatCard(
                context,
                title: '平均分數',
                value: avgScore.toStringAsFixed(1),
                icon: Icons.star,
                trend: trendPercentage,
                isPositiveTrend: trendPercentage != null && trendPercentage > 0,
              ),
            ),
            const SizedBox(width: 12),
            
            // GPA
            Expanded(
              child: _buildStatCard(
                context,
                title: 'GPA',
                value: gpaString,
                icon: Icons.school,
                scale: '滿分 4.0',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 成績分佈圖
        if (!isMini) ...[
          _buildDistributionChart(context, gradeProvider),
          const SizedBox(height: 16),
        ],
        
        // 最近成績
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMini)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '最近成績',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ...recentGrades.map((grade) => _buildGradeItem(context, grade)).take(isMini ? 2 : 5),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    String? scale,
    double? trend,
    bool isPositiveTrend = true,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 數值
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              if (scale != null)
                Text(
                  scale,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              if (trend != null) ...[
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: isPositiveTrend ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${trend.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isPositiveTrend ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(BuildContext context, GradeProvider gradeProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 獲取各分數段的成績數量
    final scoreDistribution = gradeProvider.getScoreDistribution();
    
    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: scoreDistribution.isEmpty ? 1 : null,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.grey.shade800,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String range;
                  switch (groupIndex) {
                    case 0:
                      range = '0-59';
                      break;
                    case 1:
                      range = '60-69';
                      break;
                    case 2:
                      range = '70-79';
                      break;
                    case 3:
                      range = '80-89';
                      break;
                    case 4:
                      range = '90-100';
                      break;
                    default:
                      range = '';
                  }
                  return BarTooltipItem(
                    '$range分: ${rod.toY.toInt()}門課',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String text;
                    switch (value.toInt()) {
                      case 0:
                        text = '<60';
                        break;
                      case 1:
                        text = '60s';
                        break;
                      case 2:
                        text = '70s';
                        break;
                      case 3:
                        text = '80s';
                        break;
                      case 4:
                        text = '90+';
                        break;
                      default:
                        text = '';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox.shrink();
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),
            barGroups: scoreDistribution.isEmpty
                ? [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 0.1, // 顯示空圖表
                          width: 20,
                          color: colorScheme.primary.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ]
                : List.generate(scoreDistribution.length, (index) {
                    Color barColor;
                    switch (index) {
                      case 0:
                        barColor = Colors.red.shade300;
                        break;
                      case 1:
                        barColor = Colors.orange.shade300;
                        break;
                      case 2:
                        barColor = Colors.amber.shade300;
                        break;
                      case 3:
                        barColor = Colors.green.shade300;
                        break;
                      case 4:
                        barColor = Colors.teal.shade300;
                        break;
                      default:
                        barColor = colorScheme.primary;
                    }
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: scoreDistribution[index] != null ? scoreDistribution[index]!.toDouble() : 0,
                          width: 20,
                          color: barColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeItem(BuildContext context, Grade grade) {
    final theme = Theme.of(context);
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    
    // 獲取科目
    final subject = grade.subjectId != null 
        ? subjectProvider.getSubjectById(grade.subjectId!) 
        : null;
    
    // 根據成績獲取顏色
    Color gradeColor;
    if (grade.score >= 90) {
      gradeColor = Colors.teal;
    } else if (grade.score >= 80) {
      gradeColor = Colors.green;
    } else if (grade.score >= 70) {
      gradeColor = Colors.amber.shade700;
    } else if (grade.score >= 60) {
      gradeColor = Colors.orange.shade700;
    } else {
      gradeColor = Colors.red.shade700;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // 分數
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                grade.score.toString(),
                style: TextStyle(
                  color: gradeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 科目和考試信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 科目標籤
                    if (subject != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    
                    // 考試類型
                    Text(
                      _getGradeTypeText(grade.gradeType),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // 考試名稱
                Text(
                  grade.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 等級
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getGradeLevel(grade.score.toInt()),
              style: TextStyle(
                color: gradeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGradeTypeText(GradeType type) {
    switch (type) {
      case GradeType.exam:
        return '考試';
      case GradeType.quiz:
        return '測驗';
      case GradeType.assignment:
        return '作業';
      case GradeType.project:
        return '專案';
      case GradeType.midtermExam:
        return '期中考';
      case GradeType.finalExam:
        return '期末考';
      case GradeType.presentation:
        return '報告';
      case GradeType.participation:
        return '參與度';
      case GradeType.other:
        return '其他';
    }
  }

  String _getGradeLevel(int score) {
    if (score >= 90) return 'A+';
    if (score >= 85) return 'A';
    if (score >= 80) return 'A-';
    if (score >= 77) return 'B+';
    if (score >= 73) return 'B';
    if (score >= 70) return 'B-';
    if (score >= 67) return 'C+';
    if (score >= 63) return 'C';
    if (score >= 60) return 'C-';
    if (score >= 50) return 'D';
    return 'F';
  }
} 