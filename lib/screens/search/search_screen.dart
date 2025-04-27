import 'package:flutter/material.dart';
import 'package:edurium/widgets/widgets.dart';
import 'package:edurium/utils/utils.dart';
import 'package:edurium/models/models.dart';
import 'package:edurium/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:edurium/utils/date_utils.dart';
import 'package:edurium/themes/app_theme.dart';
import 'package:edurium/utils/navigation_handler.dart';
import 'package:edurium/utils/route_constants.dart';

/// 搜索頁面
/// 
/// 允許用戶搜索任務、科目、教師和筆記等內容
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  
  // 搜索結果
  List<Task> _taskResults = [];
  List<Subject> _subjectResults = [];
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _performSearch();
    });
  }
  
  void _performSearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _taskResults = [];
        _subjectResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
    });
    
    // 從提供者獲取數據
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    
    // 搜索任務
    _taskResults = taskProvider.searchTasks(_searchQuery);
    
    // 搜索科目
    _subjectResults = subjectProvider.searchSubjects(_searchQuery);
    
    setState(() {
      _isSearching = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: '搜索任務、科目、教師...',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onSubmitted: (value) {
            _searchQuery = value;
            _performSearch();
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: _buildSearchResults(),
    );
  }
  
  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildEmptySearch();
    }
    
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final hasResults = _taskResults.isNotEmpty || _subjectResults.isNotEmpty;
    
    if (!hasResults) {
      return _buildNoResults();
    }
    
    return CustomScrollView(
      slivers: [
        // 任務結果
        if (_taskResults.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '任務',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTaskItem(_taskResults[index]),
              childCount: _taskResults.length,
            ),
          ),
        ],
        
        // 科目結果
        if (_subjectResults.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '科目',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSubjectItem(_subjectResults[index]),
              childCount: _subjectResults.length,
            ),
          ),
        ],
        
        // 底部間距
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
  
  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '輸入關鍵詞開始搜索',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildViewAllSubjectsButton(),
        ],
      ),
    );
  }
  
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '沒有找到 "$_searchQuery" 的結果',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildViewAllSubjectsButton(),
        ],
      ),
    );
  }
  
  Widget _buildViewAllSubjectsButton() {
    final theme = Theme.of(context);
    
    return ElevatedButton.icon(
      onPressed: () {
        // 調用導航到科目標籤的方法
        NavigationHandler.goToSubjectsTab(context);
      },
      icon: const Icon(Icons.book_outlined),
      label: const Text('查看所有科目'),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  Widget _buildTaskItem(Task task) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    // 獲取任務的科目顏色
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final subject = task.subjectId != null ? subjectProvider.getSubjectById(task.subjectId!) : null;
    final subjectColor = subject?.color ?? AppColors.primaryLight;
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: subjectColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.assignment_outlined,
          color: subjectColor,
        ),
      ),
      title: Text(
        task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subject?.name ?? '未指定科目',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        AppDateUtils.formatDateTime(task.dueDate),
        style: theme.textTheme.bodySmall?.copyWith(
          color: task.isOverdue ? colorScheme.error : colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () {
        // 導航到任務詳情頁面
        NavigationHandler.navigateTo(
          context, 
          AppRoutes.taskDetail,
          arguments: task.id,
        );
      },
    );
  }
  
  Widget _buildSubjectItem(Subject subject) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: subject.color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.book_outlined,
          color: subject.color,
        ),
      ),
      title: Text(
        subject.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subject.teacher ?? '未指定教師',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () {
        // 導航到科目詳情頁面
        NavigationHandler.navigateTo(
          context, 
          AppRoutes.subjectDetail,
          arguments: subject.id,
        );
      },
    );
  }
} 