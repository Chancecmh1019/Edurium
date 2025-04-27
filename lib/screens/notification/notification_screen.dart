import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/models/task.dart';
import 'package:edurium/providers/task_provider.dart';
import 'package:edurium/utils/date_util.dart';
import 'package:edurium/screens/add_task/task_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // 加載通知
  Future<void> _loadNotifications() async {
    // 模擬加載延遲
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 從任務提供者獲取即將到期的任務
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final upcomingTasks = taskProvider.getUpcomingTasks();
    final overdueTasks = taskProvider.getOverdueTasks();
    
    // 將任務轉換為通知
    final List<NotificationItem> notifications = [];
    
    // 添加逾期任務通知
    for (var task in overdueTasks) {
      notifications.add(
        NotificationItem(
          id: 'overdue_${task.id}',
          title: '任務已逾期',
          message: '「${task.title}」任務已逾期，請盡快完成。',
          date: task.dueDate,
          type: NotificationType.warning,
          isRead: false,
          relatedTaskId: task.id,
        ),
      );
    }
    
    // 添加即將到期的任務通知
    for (var task in upcomingTasks) {
      // 只添加3天內到期的任務
      final daysLeft = task.dueDate.difference(DateTime.now()).inDays;
      if (daysLeft <= 3) {
        notifications.add(
          NotificationItem(
            id: 'upcoming_${task.id}',
            title: '任務即將到期',
            message: '「${task.title}」將在 ${daysLeft == 0 ? '今天' : '$daysLeft 天後'}到期。',
            date: DateTime.now(),
            type: NotificationType.info,
            isRead: false,
            relatedTaskId: task.id,
          ),
        );
      }
    }
    
    // 添加一些示例通知
    if (notifications.isEmpty) {
      notifications.addAll([
        NotificationItem(
          id: 'welcome',
          title: '歡迎使用 Edurium',
          message: '感謝您選擇 Edurium 來管理您的學習任務和成績。',
          date: DateTime.now().subtract(const Duration(days: 1)),
          type: NotificationType.info,
          isRead: true,
        ),
        NotificationItem(
          id: 'tip_1',
          title: '新功能介紹',
          message: '您可以在行事曆中查看所有待辦任務，不同類型的任務會以不同的圖標顯示。',
          date: DateTime.now().subtract(const Duration(hours: 6)),
          type: NotificationType.info,
          isRead: false,
        ),
      ]);
    }
    
    setState(() {
      _notifications.clear();
      _notifications.addAll(notifications);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '通知',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: '全部標記為已讀',
            onPressed: () {
              _markAllAsRead();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '沒有通知',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '目前沒有任何通知，當有新的任務或活動時，您會收到提醒。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                _loadNotifications();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重新整理'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 通知類型對應的顏色和圖標
    final notificationColor = notification.type == NotificationType.warning
        ? colorScheme.error
        : notification.type == NotificationType.success
            ? colorScheme.tertiary
            : colorScheme.primary;
    
    final notificationIcon = notification.type == NotificationType.warning
        ? Icons.warning_amber_rounded
        : notification.type == NotificationType.success
            ? Icons.check_circle
            : Icons.info;
    
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        _showSnackBar('通知已刪除');
      },
      child: Material(
        color: notification.isRead
            ? theme.colorScheme.surface
            : colorScheme.primaryContainer.withOpacity(0.2),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification);
            }
            
            if (notification.relatedTaskId != null) {
              _navigateToTaskDetails(notification.relatedTaskId!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notificationColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notificationIcon,
                    color: notificationColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateUtil.formatDateTimeRelative(notification.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 8, left: 8),
                    decoration: BoxDecoration(
                      color: notificationColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      final index = _notifications.indexOf(notification);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
    _showSnackBar('所有通知已標記為已讀');
  }

  void _navigateToTaskDetails(String taskId) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final task = taskProvider.getTaskById(taskId);
    
    if (task != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskDetailScreen(taskId: taskId),
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

enum NotificationType {
  info,
  warning,
  success,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final NotificationType type;
  final bool isRead;
  final String? relatedTaskId;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    required this.isRead,
    this.relatedTaskId,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? date,
    NotificationType? type,
    bool? isRead,
    String? relatedTaskId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
    );
  }
} 