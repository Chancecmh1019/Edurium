import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../providers/providers.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_util.dart';
import '../../../screens/add_grade_screen.dart';

class GradesTab extends StatefulWidget {
  const GradesTab({super.key});

  @override
  State<GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends State<GradesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSubject = '全部';
  String _selectedSemester = '全部';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 獲取所有學期
    final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
    final semesters = gradeProvider.getAllSemesters();
    
    if (semesters.isNotEmpty) {
      _selectedSemester = semesters.last; // 預設選擇最新學期
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final gradeProvider = Provider.of<GradeProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isZh = localeProvider.locale.languageCode == 'zh';
    
    // 獲取成績列表
    final allGrades = gradeProvider.grades;
    
    // 篩選成績
    List<Grade> filteredGrades = allGrades;
    if (_selectedSubject != '全部') {
      filteredGrades = filteredGrades.where((grade) => 
          grade.subjectId != null && 
          subjectProvider.getSubjectById(grade.subjectId!)?.name == _selectedSubject
      ).toList();
    }
    
    if (_selectedSemester != '全部') {
      filteredGrades = filteredGrades.where((grade) => 
          grade.semester == _selectedSemester
      ).toList();
    }
    
    // 獲取科目列表
    final subjects = ['全部', ...subjectProvider.subjects.map((s) => s.name)];
    
    // 獲取學期列表
    final semesters = ['全部', ...gradeProvider.getAllSemesters()];
    
    // 計算各區間成績數量
    final Map<String, int> distributionData = {
      '90-100': 0,
      '80-89': 0,
      '70-79': 0,
      '60-69': 0,
      '0-59': 0,
    };
    
    for (final grade in filteredGrades) {
      final score = grade.score;
      if (score >= 90) {
        distributionData['90-100'] = (distributionData['90-100'] ?? 0) + 1;
      } else if (score >= 80) {
        distributionData['80-89'] = (distributionData['80-89'] ?? 0) + 1;
      } else if (score >= 70) {
        distributionData['70-79'] = (distributionData['70-79'] ?? 0) + 1;
      } else if (score >= 60) {
        distributionData['60-69'] = (distributionData['60-69'] ?? 0) + 1;
      } else {
        distributionData['0-59'] = (distributionData['0-59'] ?? 0) + 1;
      }
    }
    
    return Column(
      children: [
        // 篩選條件
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 科目篩選
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSubject,
                      hint: Text(isZh ? '選擇科目' : 'Select Subject'),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _selectedSubject = value;
                          });
                        }
                      },
                      items: subjects.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 10),
              
              // 學期篩選
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSemester,
                      hint: Text(isZh ? '選擇學期' : 'Select Semester'),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _selectedSemester = value;
                          });
                        }
                      },
                      items: semesters.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 標籤頁頭部
        TabBar(
          controller: _tabController,
          indicatorColor: isDarkMode ? AppColorConstants.primaryColor : AppColorConstants.primaryColor,
          labelColor: isDarkMode ? Colors.white : AppColorConstants.primaryColor,
          unselectedLabelColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          tabs: [
            Tab(text: isZh ? '成績列表' : 'Grade List'),
            Tab(text: isZh ? '成績分析' : 'Analysis'),
          ],
        ),
        
        // 標籤頁內容
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  // 成績列表頁
                  filteredGrades.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assessment_outlined,
                                size: 64,
                                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isZh ? '尚無成績資料' : 'No grades available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // 跳轉到添加成績頁面
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddGradeScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: Text(isZh ? '添加成績' : 'Add Grade'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredGrades.length,
                          itemBuilder: (context, index) {
                            final grade = filteredGrades[index];
                            final subject = grade.subjectId != null 
                                ? subjectProvider.getSubjectById(grade.subjectId!) 
                                : null;
                            
                            if (subject != null) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: subject.color != null 
                                        ? Color(int.parse(subject.color!.replaceAll('#', '0xFF'))).withOpacity(0.5)
                                        : Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // TODO: 導航到任務詳情頁面
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // 成績圓
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _getScoreColor(grade.score).withOpacity(0.2),
                                            border: Border.all(
                                              color: _getScoreColor(grade.score),
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${grade.score}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: _getScoreColor(grade.score),
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 16),
                                        
                                        // 成績信息
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                subject.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${isZh ? '類型: ' : 'Type: '}${_getGradeTypeText(grade.type, isZh)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${isZh ? '日期: ' : 'Date: '}${_formatDate(grade.gradedDate, isZh)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // 分數等級
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getScoreColor(grade.score).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: _getScoreColor(grade.score).withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            _getGradeLevel(grade.score, isZh),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _getScoreColor(grade.score),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                  
                  // 成績分析頁
                  _buildGradeAnalysisChart(context, filteredGrades, subjectProvider.subjects, isZh),
                ],
              ),
              
              // 右下角添加按鈕
              if (filteredGrades.isEmpty)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddGradeScreen(),
                        ),
                      );
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 創建統計卡片
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    bool isInteger = false,
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isInteger ? value.toInt().toString() : value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 創建柱狀圖的柱子
  BarChartGroupData _createBarGroup(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }
  
  // 獲取最大分佈值（用於圖表Y軸）
  double _getMaxDistribution(Map<String, int> distribution) {
    int max = 0;
    for (final value in distribution.values) {
      if (value > max) max = value;
    }
    // 保證最小高度為1
    return max > 0 ? (max + 1).toDouble() : 1;
  }
  
  // 根據分數獲取顏色
  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.amber;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
  
  // 獲取成績等級
  String _getGradeLevel(double score, bool isZh) {
    if (score >= 90) return isZh ? '優' : 'A';
    if (score >= 80) return isZh ? '良' : 'B';
    if (score >= 70) return isZh ? '中' : 'C';
    if (score >= 60) return isZh ? '及格' : 'D';
    return isZh ? '不及格' : 'F';
  }
  
  // 獲取成績類型文字
  String _getGradeTypeText(GradeType type, bool isZh) {
    switch (type) {
      case GradeType.exam:
        return isZh ? '考試' : 'Exam';
      case GradeType.quiz:
        return isZh ? '測驗' : 'Quiz';
      case GradeType.assignment:
        return isZh ? '作業' : 'Assignment';
      case GradeType.project:
        return isZh ? '專案' : 'Project';
      case GradeType.presentation:
        return isZh ? '報告' : 'Presentation';
      case GradeType.participation:
        return isZh ? '參與度' : 'Participation';
      case GradeType.finalExam:
        return isZh ? '期末考試' : 'Final Exam';
      case GradeType.midtermExam:
        return isZh ? '期中考試' : 'Midterm Exam';
      default:
        return isZh ? '其他' : 'Other';
    }
  }
  
  // 格式化日期
  String _formatDate(DateTime? date, bool isZh) {
    if (date == null) return isZh ? '未知日期' : 'Unknown Date';
    
    if (isZh) {
      return '${date.year} 年 ${date.month} 月 ${date.day} 日';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
  
  // 計算平均分
  double _calculateAverage(List<Grade> grades) {
    if (grades.isEmpty) return 0;
    double sum = 0;
    for (final grade in grades) {
      sum += grade.score;
    }
    return sum / grades.length;
  }
  
  // 計算最高分
  double _calculateHighest(List<Grade> grades) {
    if (grades.isEmpty) return 0;
    double highest = grades[0].score;
    for (final grade in grades) {
      if (grade.score > highest) {
        highest = grade.score;
      }
    }
    return highest;
  }
  
  // 計算最低分
  double _calculateLowest(List<Grade> grades) {
    if (grades.isEmpty) return 0;
    double lowest = grades[0].score;
    for (final grade in grades) {
      if (grade.score < lowest) {
        lowest = grade.score;
      }
    }
    return lowest;
  }
  
  // 計算不同科目數量
  int _countUniqueSubjects(List<Grade> grades, SubjectProvider subjectProvider) {
    if (grades.isEmpty) return 0;
    
    final Set<String?> uniqueSubjectIds = {};
    for (final grade in grades) {
      uniqueSubjectIds.add(grade.subjectId);
    }
    
    return uniqueSubjectIds.length;
  }

  // 成績分析圖表
  Widget _buildGradeAnalysisChart(BuildContext context, List<Grade> grades, List<Subject> subjects, bool isZh) {
    if (grades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isZh ? '暫無成績數據用於分析' : 'No grade data for analysis',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // 按科目分組的成績
    final Map<String, List<Grade>> gradesBySubject = {};
    
    for (final grade in grades) {
      if (grade.subjectId != null) {
        final subject = subjects.firstWhere(
          (s) => s.id == grade.subjectId,
          orElse: () => Subject(id: '', name: isZh ? '未知科目' : 'Unknown'),
        );
        
        if (!gradesBySubject.containsKey(subject.name)) {
          gradesBySubject[subject.name] = [];
        }
        gradesBySubject[subject.name]!.add(grade);
      }
    }
    
    // 計算每個科目的平均分數
    final Map<String, double> averageScores = {};
    gradesBySubject.forEach((subject, subjectGrades) {
      final totalScore = subjectGrades.fold(0.0, (sum, grade) => sum + grade.score);
      averageScores[subject] = totalScore / subjectGrades.length;
    });
    
    // 轉換為圖表數據
    final List<BarChartGroupData> barGroups = [];
    int index = 0;
    
    averageScores.forEach((subject, score) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: score,
              color: _getScoreColor(score),
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
      index++;
    });
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isZh ? '科目平均分數' : 'Subject Average Scores',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < averageScores.keys.length) {
                          final subject = averageScores.keys.elementAt(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              subject.length > 8 ? '${subject.substring(0, 8)}...' : subject,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
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
                gridData: FlGridData(
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                    left: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 圖表說明
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(context, '90-100', Colors.green, isZh ? '優秀' : 'Excellent'),
              _buildLegendItem(context, '80-89', Colors.lightGreen, isZh ? '良好' : 'Good'),
              _buildLegendItem(context, '70-79', Colors.amber, isZh ? '一般' : 'Average'),
              _buildLegendItem(context, '60-69', Colors.orange, isZh ? '及格' : 'Pass'),
              _buildLegendItem(context, '0-59', Colors.red, isZh ? '不及格' : 'Fail'),
            ],
          ),
        ],
      ),
    );
  }
  
  // 圖例項目
  Widget _buildLegendItem(BuildContext context, String range, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$range ($label)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
} 