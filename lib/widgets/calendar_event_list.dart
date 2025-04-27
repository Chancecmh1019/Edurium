import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class CalendarEventList extends StatefulWidget {
  final DateTime? selectedDay;
  
  const CalendarEventList({
    Key? key,
    this.selectedDay,
  }) : super(key: key);
  
  @override
  _CalendarEventListState createState() => _CalendarEventListState();
}

class _CalendarEventListState extends State<CalendarEventList> {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final selectedDay = widget.selectedDay ?? DateTime.now();
    
    // 使用已經實現的getTasksForDay方法
    final tasks = taskProvider.getTasksForDay(selectedDay);
    
    if (tasks.isEmpty) {
      return Center(
        child: Text('沒有事項'),
      );
    }
    
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(tasks[index].title),
          subtitle: Text(tasks[index].description ?? ''),
        );
      },
    );
  }
} 