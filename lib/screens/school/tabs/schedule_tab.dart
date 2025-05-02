import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_util.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  // 當前選中的日期
  late DateTime _selectedDate;
  // 當前週的日期範圍
  late List<DateTime> _weekDays;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initWeekDays();
  }
  
  // 初始化當前週的日期
  void _initWeekDays() {
    final weekRange = DateUtil.getCurrentWeekRange();
    _weekDays = DateUtil.getDaysInRange(weekRange['start']!, weekRange['end']!);
  }
  
  // 切換到上一週
  void _previousWeek() {
    setState(() {
      final firstDay = _weekDays.first;
      final newFirstDay = firstDay.subtract(const Duration(days: 7));
      _weekDays = DateUtil.getDaysInRange(
        newFirstDay, 
        newFirstDay.add(const Duration(days: 6))
      );
      _selectedDate = _weekDays.first;
    });
  }
  
  // 切換到下一週
  void _nextWeek() {
    setState(() {
      final lastDay = _weekDays.last;
      final newFirstDay = lastDay.add(const Duration(days: 1));
      _weekDays = DateUtil.getDaysInRange(
        newFirstDay, 
        newFirstDay.add(const Duration(days: 6))
      );
      _selectedDate = _weekDays.first;
    });
  }
  
  // 回到當前週
  void _goToCurrentWeek() {
    setState(() {
      _initWeekDays();
      _selectedDate = DateTime.now();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    
    final isZh = localeProvider.locale.languageCode == 'zh';
    final isDarkMode = themeProvider.isDarkMode(context);
    
    // 獲取課程時間表
    final weeklySchedule = subjectProvider.getWeeklySchedule();
    
    // 定義課程時段
    final List<String> periodTimes = [
      '08:00 - 08:50', '09:00 - 09:50', '10:00 - 10:50', '11:00 - 11:50',
      '13:00 - 13:50', '14:00 - 14:50', '15:00 - 15:50', '16:00 - 16:50',
      '18:00 - 18:50', '19:00 - 19:50', '20:00 - 20:50', '21:00 - 21:50',
    ];
    
    return Column(
      children: [
        // 週選擇器
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousWeek,
                tooltip: isZh ? '上一週' : 'Previous Week',
              ),
              GestureDetector(
                onTap: _goToCurrentWeek,
                child: Text(
                  '${DateUtil.formatDate(_weekDays.first)} - ${DateUtil.formatDate(_weekDays.last)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _nextWeek,
                tooltip: isZh ? '下一週' : 'Next Week',
              ),
            ],
          ),
        ),
        
        // 日期選擇列
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColorConstants.darkCardColor : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _weekDays.length,
            itemBuilder: (context, index) {
              final currentDate = _weekDays[index];
              final isSelected = currentDate.day == _selectedDate.day &&
                                currentDate.month == _selectedDate.month &&
                                currentDate.year == _selectedDate.year;
              final isToday = currentDate.day == DateTime.now().day &&
                            currentDate.month == DateTime.now().month &&
                            currentDate.year == DateTime.now().year;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = currentDate;
                  });
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDarkMode ? AppColorConstants.primaryColor : AppColorConstants.primaryColor).withOpacity(0.2)
                        : isToday
                            ? (isDarkMode ? AppColorConstants.secondaryColor : AppColorConstants.secondaryColor).withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: isDarkMode ? AppColorConstants.primaryColor : AppColorConstants.primaryColor,
                            width: 2,
                          )
                        : isToday
                            ? Border.all(
                                color: isDarkMode ? AppColorConstants.secondaryColor : AppColorConstants.secondaryColor,
                                width: 1,
                              )
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateUtil.getWeekdayShortName(currentDate, locale: localeProvider.locale),
                        style: TextStyle(
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (isDarkMode ? AppColorConstants.primaryColor : AppColorConstants.primaryColor)
                              : isToday
                                  ? (isDarkMode ? AppColorConstants.secondaryColor : AppColorConstants.secondaryColor)
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentDate.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (isDarkMode ? AppColorConstants.primaryColor : AppColorConstants.primaryColor)
                              : isToday
                                  ? (isDarkMode ? AppColorConstants.secondaryColor : AppColorConstants.secondaryColor)
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // 課程列表
        Expanded(
          child: weeklySchedule.isEmpty || weeklySchedule[_selectedDate.weekday]?.isEmpty == true
              ? _buildEmptySchedule(context, isZh)
              : _buildScheduleList(
                  context, 
                  weeklySchedule[_selectedDate.weekday] ?? {}, 
                  periodTimes, 
                  subjectProvider, 
                  teacherProvider,
                  isZh,
                ),
        ),
      ],
    );
  }
  
  // 構建空課程表
  Widget _buildEmptySchedule(BuildContext context, bool isZh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isZh ? '這一天沒有課程安排' : 'No classes scheduled for this day',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // 跳轉到添加課程頁面
              _showAddClassDialog(context);
            },
            icon: const Icon(Icons.add),
            label: Text(isZh ? '添加課程' : 'Add Class'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
  
  // 構建課程列表
  Widget _buildScheduleList(
    BuildContext context, 
    Map<int, Subject> daySchedule, 
    List<String> periodTimes, 
    SubjectProvider subjectProvider, 
    TeacherProvider teacherProvider,
    bool isZh,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: periodTimes.length,
      itemBuilder: (context, index) {
        // 時間段索引從1開始，對應periodTimes從0開始
        final periodIndex = index + 1;
        final subject = daySchedule[periodIndex];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: subject != null 
                  ? _getSubjectColor(subject).withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
              width: subject != null ? 1.5 : 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 課程時段
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$periodIndex',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      periodTimes[index],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // 課程資訊
                Expanded(
                  child: subject == null
                      ? _buildEmptySlot(context, isZh)
                      : _buildSubjectInfo(context, subject, teacherProvider, isZh),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // 構建空課程槽
  Widget _buildEmptySlot(BuildContext context, bool isZh) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      child: Text(
        isZh ? '沒有課程安排' : 'No class scheduled',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
  
  // 構建課程資訊
  Widget _buildSubjectInfo(BuildContext context, Subject subject, TeacherProvider teacherProvider, bool isZh) {
    final teacher = subject.teacherId != null ? teacherProvider.getTeacherById(subject.teacherId!) : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (teacher != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.person,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                teacher.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
        if (subject.classroom != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                subject.classroom!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  
  // 獲取課程顏色
  Color _getSubjectColor(Subject subject) {
    if (subject.color != null) {
      try {
        return Color(int.parse(subject.color!.replaceAll('#', '0xFF')));
      } catch (e) {
        // 忽略錯誤
      }
    }
    return Colors.blue;
  }

  // 添加課程對話框
  void _showAddClassDialog(BuildContext context) {
    final isZh = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode == 'zh';
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final subjects = subjectProvider.subjects;
    String? selectedSubjectId;
    int selectedPeriod = 1;
    
    final periodTimes = [
      '08:00 - 08:50', '09:00 - 09:50', '10:00 - 10:50', '11:00 - 11:50',
      '13:00 - 13:50', '14:00 - 14:50', '15:00 - 15:50', '16:00 - 16:50',
      '18:00 - 18:50', '19:00 - 19:50', '20:00 - 20:50', '21:00 - 21:50',
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isZh ? '添加課程' : 'Add Class'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 選擇科目
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: isZh ? '選擇科目' : 'Select Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: selectedSubjectId,
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(isZh ? '請選擇' : 'Please select'),
                      ),
                      ...subjects.map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject.id,
                          child: Text(subject.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSubjectId = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 選擇時段
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: isZh ? '選擇時段' : 'Select Period',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: selectedPeriod,
                    items: List.generate(periodTimes.length, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('${index + 1} (${periodTimes[index]})'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedPeriod = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isZh ? '取消' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedSubjectId != null) {
                    // 獲取選中的科目
                    final subject = subjects.firstWhere((s) => s.id == selectedSubjectId);
                    
                    // 更新科目的課程表
                    Map<String, dynamic> schedule = subject.schedule ?? {};
                    String weekday = _selectedDate.weekday.toString();
                    String periodKey = '$weekday-$selectedPeriod';
                    
                    // 設置當前學期為有效期（假設當前為第1學期）
                    schedule[periodKey] = [1]; // [學期編號]
                    
                    // 保存更新後的科目
                    final updatedSubject = subject.copyWith(
                      schedule: schedule,
                    );
                    
                    subjectProvider.updateSubject(updatedSubject);
                    
                    // 關閉對話框
                    Navigator.pop(context);
                    
                    // 顯示提示
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isZh ? '課程已添加' : 'Class added'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    // 提示需要選擇科目
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isZh ? '請選擇科目' : 'Please select a subject'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text(isZh ? '添加' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
  }
} 