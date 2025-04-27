import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/constants.dart';
import 'task_detail_screen.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;
  final TaskType? initialTaskType;
  final DateTime? initialDate;

  const AddTaskScreen({
    super.key,
    this.taskToEdit,
    this.initialTaskType,
    this.initialDate,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late TaskType _taskType;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  TaskPriority _priority = TaskPriority.medium;
  String? _selectedSubjectId;
  String? _selectedTeacherId;
  DateTime? _reminderTime;
  bool _isAutoCalendarEnabled = true;
  bool _isImportant = false;
  bool _showSubjectTeacherSection = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.taskToEdit != null;
    
    if (_isEditing) {
      // 如果是編輯現有任務
      final task = widget.taskToEdit!;
      _taskType = task.taskType;
      _dueDate = task.dueDate;
      _dueTime = TimeOfDay(hour: task.dueDate.hour, minute: task.dueDate.minute);
      _priority = task.priority;
      _selectedSubjectId = task.subjectId;
      _selectedTeacherId = task.teacherId;
      _reminderTime = task.reminderTime;
      _isImportant = task.extras?['isImportant'] ?? false;
      
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
    } else {
      // 如果是創建新任務
      _taskType = widget.initialTaskType ?? TaskType.homework;
      _dueDate = widget.initialDate ?? DateTime.now().add(const Duration(days: 1));
      _dueTime = TimeOfDay.now();
    }
    
    _showSubjectTeacherSection = _taskType == TaskType.homework || _taskType == TaskType.exam || _taskType == TaskType.project;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      // 合併日期和時間
      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );

      if (_isEditing) {
        // 更新現有任務
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          taskType: _taskType,
          dueDate: dueDateTime,
          priority: _priority,
          subjectId: _selectedSubjectId,
          teacherId: _selectedTeacherId,
          reminderTime: _reminderTime,
          extras: {
            'isImportant': _isImportant,
          },
        );
        
        await taskProvider.updateTask(updatedTask);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('任務已更新'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // 創建新任務
        final task = Task(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          taskType: _taskType,
          dueDate: dueDateTime,
          priority: _priority,
          subjectId: _selectedSubjectId,
          teacherId: _selectedTeacherId,
          reminderTime: _reminderTime,
          extras: {
            'isImportant': _isImportant,
          },
        );
        
        // 添加任務
        await taskProvider.addTask(task);
        
        // 關閉頁面
        if (mounted) {
          Navigator.pop(context);
          
          // 顯示提示
          final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
          final isZh = localeProvider.locale.languageCode == 'zh';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isZh ? '任務已添加' : 'Task added'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: isZh ? '查看' : 'View',
                onPressed: () {
                  // 導航到任務詳情頁面
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(taskId: task.id),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    }
  }

  // 選擇日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  // 選擇時間
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  // 選擇提醒時間
  Future<void> _selectReminderTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? _dueDate.subtract(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: _dueDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isZh = localeProvider.locale.languageCode == 'zh';
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final paddingValue = screenWidth * 0.04;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isZh ? '新增任務' : 'Add Task'),
          actions: [
            TextButton.icon(
              onPressed: _saveTask,
              icon: const Icon(Icons.check),
              label: Text(isZh ? '儲存' : 'Save'),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(paddingValue),
              children: [
                // 任務類型選擇
                Card(
                  margin: EdgeInsets.only(bottom: paddingValue),
                  child: Padding(
                    padding: EdgeInsets.all(paddingValue),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isZh ? '任務類型' : 'Task Type',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTypeChip(
                                type: TaskType.homework,
                                label: isZh ? '作業' : 'Homework',
                                icon: Icons.assignment,
                                color: AppColorConstants.homeworkColor,
                              ),
                              const SizedBox(width: 8),
                              _buildTypeChip(
                                type: TaskType.exam,
                                label: isZh ? '考試' : 'Exam',
                                icon: Icons.note_alt,
                                color: AppColorConstants.examColor,
                              ),
                              const SizedBox(width: 8),
                              _buildTypeChip(
                                type: TaskType.project,
                                label: isZh ? '專案' : 'Project',
                                icon: Icons.science,
                                color: AppColorConstants.projectColor,
                              ),
                              const SizedBox(width: 8),
                              _buildTypeChip(
                                type: TaskType.reminder,
                                label: isZh ? '提醒' : 'Reminder',
                                icon: Icons.notifications,
                                color: AppColorConstants.reminderColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 任務標題和描述
                Card(
                  margin: EdgeInsets.only(bottom: paddingValue),
                  child: Padding(
                    padding: EdgeInsets.all(paddingValue),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: isZh ? '任務標題' : 'Task Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isZh ? '請輸入任務標題' : 'Please enter a title';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        SizedBox(height: paddingValue),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: isZh ? '任務描述' : 'Task Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 日期和時間
                Card(
                  margin: EdgeInsets.only(bottom: paddingValue),
                  child: Padding(
                    padding: EdgeInsets.all(paddingValue),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isZh ? '日期和時間' : 'Date & Time',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 日期選擇
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(isZh ? '截止日期' : 'Due Date'),
                          subtitle: Text(
                            DateFormat.yMMMd(localeProvider.locale.toString()).format(_dueDate),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _selectDate,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 時間選擇
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(isZh ? '截止時間' : 'Due Time'),
                          subtitle: Text(
                            _dueTime.format(context),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _selectTime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                        ),
                        
                        // 添加到日曆
                        SwitchListTile(
                          title: Text(isZh ? '添加到日曆' : 'Add to Calendar'),
                          subtitle: Text(
                            isZh ? '自動將任務添加到系統日曆' : 'Automatically add task to system calendar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          value: _isAutoCalendarEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isAutoCalendarEnabled = value;
                            });
                          },
                          secondary: const Icon(Icons.event),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 優先級和提醒
                Card(
                  margin: EdgeInsets.only(bottom: paddingValue),
                  child: Padding(
                    padding: EdgeInsets.all(paddingValue),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isZh ? '優先級和提醒' : 'Priority & Reminder',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 優先級選擇
                        Row(
                          children: [
                            Expanded(
                              child: Text(isZh ? '優先級' : 'Priority'),
                            ),
                            _buildPriorityChip(
                              priority: TaskPriority.low,
                              label: isZh ? '低' : 'Low',
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _buildPriorityChip(
                              priority: TaskPriority.medium,
                              label: isZh ? '中' : 'Medium',
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _buildPriorityChip(
                              priority: TaskPriority.high,
                              label: isZh ? '高' : 'High',
                              color: Colors.red,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 重要標記
                        SwitchListTile(
                          title: Text(isZh ? '標記為重要' : 'Mark as Important'),
                          value: _isImportant,
                          onChanged: (value) {
                            setState(() {
                              _isImportant = value;
                            });
                          },
                          secondary: Icon(
                            Icons.star,
                            color: _isImportant ? Colors.amber : null,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // 提醒時間
                        ListTile(
                          leading: const Icon(Icons.notifications_active),
                          title: Text(isZh ? '提醒時間' : 'Reminder'),
                          subtitle: _reminderTime != null
                              ? Text(DateFormat.yMMMd(localeProvider.locale.toString()).format(_reminderTime!))
                              : Text(isZh ? '未設置' : 'Not set'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_reminderTime != null)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _reminderTime = null;
                                    });
                                  },
                                ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          onTap: _selectReminderTime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 科目和教師（僅適用於作業、考試和專案）
                if (_showSubjectTeacherSection)
                  Card(
                    margin: EdgeInsets.only(bottom: paddingValue),
                    child: Padding(
                      padding: EdgeInsets.all(paddingValue),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isZh ? '科目和教師' : 'Subject & Teacher',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // 科目選擇
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: isZh ? '選擇科目' : 'Select Subject',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.book),
                            ),
                            value: _selectedSubjectId,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(isZh ? '無' : 'None'),
                              ),
                              ...subjectProvider.subjects.map((subject) => 
                                DropdownMenuItem<String>(
                                  value: subject.id,
                                  child: Text(subject.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSubjectId = value;
                              });
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 教師選擇
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: isZh ? '選擇教師' : 'Select Teacher',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            value: _selectedTeacherId,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(isZh ? '無' : 'None'),
                              ),
                              ...teacherProvider.teachers.map((teacher) => 
                                DropdownMenuItem<String>(
                                  value: teacher.id,
                                  child: Text(teacher.name ?? ''),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedTeacherId = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 構建類型選擇芯片
  Widget _buildTypeChip({
    required TaskType type, 
    required String label, 
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _taskType == type;
    
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : null,
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: color,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _taskType = type;
            _showSubjectTeacherSection = type == TaskType.homework || type == TaskType.exam || type == TaskType.project;
          });
        }
      },
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
  
  // 構建優先級選擇芯片
  Widget _buildPriorityChip({
    required TaskPriority priority, 
    required String label, 
    required Color color,
  }) {
    final isSelected = _priority == priority;
    
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : null,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _priority = priority;
          });
        }
      },
    );
  }
} 