import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/utils.dart';

class SubjectSummarySection extends StatelessWidget {
  const SubjectSummarySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final String sectionTitle = locale.languageCode == 'zh' ? '課程' : 'Subjects';
    final String noSubjectsText = locale.languageCode == 'zh' 
        ? '尚未添加課程' 
        : 'No subjects added yet';
    final String viewAllText = locale.languageCode == 'zh' 
        ? '查看全部' 
        : 'View All';
    
    final subjects = subjectProvider.subjects;
    
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
            if (subjects.isNotEmpty)
              TextButton(
                onPressed: () {
                  // 導航到課程列表
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
        
        // 課程列表
        if (subjects.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  noSubjectsText,
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
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return _buildSubjectCard(context, subjects[index]);
              },
            ),
          ),
      ],
    );
  }
  
  Widget _buildSubjectCard(BuildContext context, Subject subject) {
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final teacher = subject.teacherId != null ? teacherProvider.getTeacherById(subject.teacherId!) : null;
    final locale = Provider.of<LocaleProvider>(context).locale;
    
    // 獲取課程顏色
    final Color subjectColor = subject.color != null 
        ? Color(int.parse(subject.color!.replaceAll('#', '0xFF')))
        : AppColors.primaryLight;
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: subjectColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: subjectColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 導航到課程詳情
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 課程圖標
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.book_outlined,
                    color: subjectColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 課程名稱
                Text(
                  subject.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: subjectColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // 老師名稱
                if (teacher != null)
                  Text(
                    teacher.name,
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
        ),
      ),
    );
  }
} 