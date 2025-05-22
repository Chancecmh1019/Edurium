import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/locale_provider.dart';
import '../models/task.dart';

class TaskStatsScreen extends StatelessWidget {
  const TaskStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final isZh = Provider.of<LocaleProvider>(context).locale.languageCode == 'zh';
    final stats = taskProvider.getLearningStats();
    final subjectStats = taskProvider.getSubjectStats();

    return Scaffold(
      appBar: AppBar(
        title: Text(isZh ? '學習統計' : 'Learning Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallStats(stats, isZh),
            const SizedBox(height: 24),
            _buildTaskTypeDistribution(taskProvider, isZh),
            const SizedBox(height: 24),
            _buildPriorityDistribution(taskProvider, isZh),
            const SizedBox(height: 24),
            _buildSubjectStats(subjectStats, isZh),
            const SizedBox(height: 24),
            _buildTagStats(taskProvider, isZh),
            const SizedBox(height: 24),
            _buildTimeDistribution(taskProvider, isZh),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(Map<String, dynamic> stats, bool isZh) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isZh ? '整體統計' : 'Overall Statistics',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    isZh ? '總任務數' : 'Total Tasks',
                    stats['totalTasks'].toString(),
                    Icons.assignment,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    isZh ? '已完成' : 'Completed',
                    stats['completedTasks'].toString(),
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    isZh ? '完成率' : 'Completion Rate',
                    '${(stats['completionRate'] * 100).toStringAsFixed(1)}%',
                    Icons.percent,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    isZh ? '平均效率' : 'Avg. Efficiency',
                    '${(stats['averageEfficiency'] * 100).toStringAsFixed(1)}%',
                    Icons.speed,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    isZh ? '總學習時間' : 'Total Study Time',
                    '${(stats['totalStudyTime'] / 60).toStringAsFixed(1)}h',
                    Icons.timer,
                    color: Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    isZh ? '平均時間' : 'Avg. Time',
                    '${(stats['averageStudyTime']).toStringAsFixed(1)}min',
                    Icons.access_time,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTaskTypeDistribution(TaskProvider taskProvider, bool isZh) {
    final typeStats = taskProvider.getTasksByType();
    final total = typeStats.values.fold(0, (sum, tasks) => sum + tasks.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isZh ? '任務類型分佈' : 'Task Type Distribution',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: TaskType.values.map((type) {
                    final tasks = typeStats[type] ?? [];
                    final percentage = total > 0 ? tasks.length / total : 0.0;
                    return PieChartSectionData(
                      value: percentage * 100,
                      title: '${(percentage * 100).toStringAsFixed(1)}%',
                      color: _getTaskTypeColor(type),
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: TaskType.values.map((type) {
                final tasks = typeStats[type] ?? [];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: _getTaskTypeColor(type),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_getTaskTypeName(type, isZh)} (${tasks.length})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDistribution(TaskProvider taskProvider, bool isZh) {
    final priorityStats = taskProvider.getTasksByPriority();
    final total = priorityStats.values.fold(0, (sum, tasks) => sum + tasks.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isZh ? '優先級分佈' : 'Priority Distribution',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: total.toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getPriorityName(TaskPriority.values[value.toInt()], isZh),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
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
                  barGroups: TaskPriority.values.map((priority) {
                    final tasks = priorityStats[priority] ?? [];
                    return BarChartGroupData(
                      x: priority.index,
                      barRods: [
                        BarChartRodData(
                          toY: tasks.length.toDouble(),
                          color: _getPriorityColor(priority),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectStats(Map<String, dynamic> subjectStats, bool isZh) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isZh ? '科目統計' : 'Subject Statistics',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...subjectStats.entries.map((entry) {
              final stats = entry.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: stats['completionRate'] as double,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(stats['completionRate'] as double),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isZh ? '完成率：${(stats['completionRate'] * 100).toStringAsFixed(1)}%' : 'Completion: ${(stats['completionRate'] * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          isZh ? '效率：${(stats['efficiency'] * 100).toStringAsFixed(1)}%' : 'Efficiency: ${(stats['efficiency'] * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTagStats(TaskProvider taskProvider, bool isZh) {
    final tagStats = taskProvider.tagCounts;
    final sortedTags = tagStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isZh ? '標籤統計' : 'Tag Statistics',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sortedTags.map((entry) {
                return Chip(
                  label: Text('${entry.key} (${entry.value})'),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDistribution(TaskProvider taskProvider, bool isZh) {
    final tasks = taskProvider.tasks;
    final timeDistribution = List.filled(24, 0);

    for (final task in tasks) {
      final hour = task.dueDate.hour;
      timeDistribution[hour]++;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isZh ? '時間分佈' : 'Time Distribution',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${value.toInt()}:00',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        interval: 4,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(24, (index) {
                        return FlSpot(index.toDouble(), timeDistribution[index].toDouble());
                      }),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.homework:
        return Colors.blue;
      case TaskType.exam:
        return Colors.red;
      case TaskType.project:
        return Colors.green;
      case TaskType.reminder:
        return Colors.orange;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getTaskTypeName(TaskType type, bool isZh) {
    switch (type) {
      case TaskType.homework:
        return isZh ? '作業' : 'Homework';
      case TaskType.exam:
        return isZh ? '考試' : 'Exam';
      case TaskType.project:
        return isZh ? '專案' : 'Project';
      case TaskType.reminder:
        return isZh ? '提醒' : 'Reminder';
    }
  }

  String _getPriorityName(TaskPriority priority, bool isZh) {
    switch (priority) {
      case TaskPriority.low:
        return isZh ? '低' : 'Low';
      case TaskPriority.medium:
        return isZh ? '中' : 'Medium';
      case TaskPriority.high:
        return isZh ? '高' : 'High';
    }
  }
} 