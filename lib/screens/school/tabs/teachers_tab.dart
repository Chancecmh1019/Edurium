import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';
import '../../add_teacher_screen.dart';

class TeachersTab extends StatefulWidget {
  const TeachersTab({super.key});

  @override
  State<TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<TeachersTab> {
  String _searchQuery = '';
  String? _selectedDepartment;
  Teacher? _selectedTeacher;
  
  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isZh = localeProvider.locale.languageCode == 'zh';
    
    // 取得所有老師
    List<Teacher> teachers = teacherProvider.teachers;
    
    // 如果有搜索條件，過濾老師
    if (_searchQuery.isNotEmpty) {
      teachers = teacherProvider.searchTeachers(_searchQuery);
    }
    
    // 如果選擇了系所，過濾老師
    if (_selectedDepartment != null) {
      teachers = teachers.where((teacher) => 
        teacher.department == _selectedDepartment).toList();
    }
    
    // 獲取所有系所
    final departments = teacherProvider.allDepartments;
    
    return Scaffold(
      body: Column(
        children: [
          // 搜索欄和過濾器
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 搜索欄
                TextField(
                  decoration: InputDecoration(
                    hintText: isZh ? '搜索老師名稱或系所...' : 'Search teachers or departments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // 系所過濾器
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 全部選項
                      FilterChip(
                        label: Text(isZh ? '全部' : 'All'),
                        selected: _selectedDepartment == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDepartment = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      
                      // 系所選項
                      ...departments.map((dept) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(dept),
                          selected: _selectedDepartment == dept,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDepartment = selected ? dept : null;
                            });
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 老師列表和詳細信息
          Expanded(
            child: teachers.isEmpty
                ? _buildEmptyTeacherList(context, isZh)
                : Row(
                    children: [
                      // 老師列表
                      Expanded(
                        flex: 3,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {
                            final teacher = teachers[index];
                            final isSelected = _selectedTeacher?.id == teacher.id;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isSelected 
                                    ? BorderSide(
                                        color: Theme.of(context).colorScheme.primary, 
                                        width: 2,
                                      )
                                    : BorderSide.none,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTeacher = teacher;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // 老師頭像或首字母頭像
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                        child: teacher.photoUrl != null
                                            ? null // 如果有照片URL，實際項目中應該加載照片
                                            : Text(
                                                teacher.name.substring(0, 1),
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // 老師信息
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              teacher.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (teacher.department != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                teacher.department!,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      
                                      // 指示箭頭
                                      Icon(
                                        Icons.chevron_right,
                                        color: isSelected 
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // 分隔線
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      
                      // 老師詳細信息
                      Expanded(
                        flex: 4,
                        child: _selectedTeacher == null
                            ? Center(
                                child: Text(
                                  isZh ? '選擇一位老師查看詳細資訊' : 'Select a teacher to view details',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : _buildTeacherDetails(context, _selectedTeacher!, isZh),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTeacherScreen(),
            ),
          );
        },
        tooltip: isZh ? '添加老師' : 'Add Teacher',
        child: const Icon(Icons.person_add),
      ),
    );
  }
  
  // 構建空老師列表
  Widget _buildEmptyTeacherList(BuildContext context, bool isZh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isZh ? '沒有找到符合條件的老師' : 'No teachers found',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTeacherScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(isZh ? '添加老師' : 'Add Teacher'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 構建老師詳細信息
  Widget _buildTeacherDetails(BuildContext context, Teacher teacher, bool isZh) {
    // 獲取課程提供者
    final subjectProvider = Provider.of<SubjectProvider>(context);
    
    // 獲取該老師的課程
    final subjects = subjectProvider.getSubjectsByTeacher(teacher.id);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 老師基本信息卡片
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 老師名稱和系所
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        child: teacher.photoUrl != null
                            ? null // 如果有照片URL，實際項目中應該加載照片
                            : Text(
                                teacher.name.substring(0, 1),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            if (teacher.department != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                teacher.department!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // 聯絡信息
                  if (teacher.email != null) ...[
                    _buildInfoRow(Icons.email, teacher.email!, context),
                    const SizedBox(height: 12),
                  ],
                  
                  if (teacher.phoneNumber != null) ...[
                    _buildInfoRow(Icons.phone, teacher.phoneNumber!, context),
                    const SizedBox(height: 12),
                  ],
                  
                  if (teacher.office != null) ...[
                    _buildInfoRow(Icons.location_on, teacher.office!, context),
                    const SizedBox(height: 12),
                  ],
                  
                  // 辦公時間
                  if (teacher.officeHours != null && teacher.officeHours!.isNotEmpty) ...[
                    Text(
                      isZh ? '辦公時間：' : 'Office Hours:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...teacher.officeHours!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(entry.value.toString()),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                  ],
                  
                  // 備註
                  if (teacher.notes != null && teacher.notes!.isNotEmpty) ...[
                    Text(
                      isZh ? '備註：' : 'Notes:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(teacher.notes!),
                  ],
                ],
              ),
            ),
          ),
          
          // 教授的課程
          if (subjects.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                isZh ? '開設課程' : 'Courses',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ...subjects.map((subject) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _getSubjectColor(subject).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getSubjectColor(subject).withOpacity(0.2),
                  child: Icon(
                    Icons.book,
                    color: _getSubjectColor(subject),
                  ),
                ),
                title: Text(
                  subject.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: subject.classroom != null 
                    ? Text(subject.classroom!) 
                    : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 導航到課程詳情頁面
                },
              ),
            )).toList(),
          ],
          
          // 如果沒有課程
          if (subjects.isEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    isZh ? '此老師暫無課程' : 'No courses for this teacher',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // 構建信息行
  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
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
} 