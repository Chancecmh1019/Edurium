import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/providers/teacher_provider.dart';
import 'package:edurium/models/teacher.dart';

class TeachersTab extends StatelessWidget {
  const TeachersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, teacherProvider, child) {
        final teachers = teacherProvider.teachers;
        
        if (teachers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 64,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '尚未添加任何老師',
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
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return _TeacherCard(teacher: teacher);
          },
        );
      },
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final Teacher teacher;

  const _TeacherCard({required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              teacher.name.substring(0, 1),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          teacher.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (teacher.email != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    teacher.email!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (teacher.phone != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    teacher.phone!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (teacher.subjects.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: teacher.subjects.map((subject) {
                  return Chip(
                    label: Text(
                      subject.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: subject.color.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: subject.color,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // TODO: 編輯老師資訊
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('刪除老師'),
                    content: const Text('您確定要刪除這位老師的資訊嗎？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Provider.of<TeacherProvider>(context, listen: false)
                              .deleteTeacher(teacher.id);
                          Navigator.pop(context);
                        },
                        child: const Text('刪除'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 