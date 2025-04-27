import 'package:flutter/material.dart';

/// 對話框輔助工具類
/// 
/// 提供應用程式中各種常用對話框的顯示方法
class DialogHelper {
  /// 顯示確認對話框
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool barrierDismissible = true,
  }) async {
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode == 'zh';
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? (isZh ? '取消' : 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText ?? (isZh ? '確認' : 'Confirm')),
          ),
        ],
      ),
    );
  }
  
  /// 顯示錯誤對話框
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? okText,
    bool barrierDismissible = true,
  }) async {
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode == 'zh';
    
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(okText ?? (isZh ? '確定' : 'OK')),
          ),
        ],
      ),
    );
  }
  
  /// 顯示成功對話框
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? okText,
    bool barrierDismissible = true,
  }) async {
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode == 'zh';
    
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(content),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(okText ?? (isZh ? '確定' : 'OK')),
          ),
        ],
      ),
    );
  }
  
  /// 顯示簡單的通知對話框
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? okText,
    bool barrierDismissible = true,
  }) async {
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode == 'zh';
    
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(okText ?? (isZh ? '確定' : 'OK')),
          ),
        ],
      ),
    );
  }
  
  /// 顯示刪除確認對話框
  static Future<bool?> showDeleteConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool barrierDismissible = true,
  }) async {
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode == 'zh';
    final theme = Theme.of(context);
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              color: theme.colorScheme.error,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(content),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? (isZh ? '取消' : 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(confirmText ?? (isZh ? '刪除' : 'Delete')),
          ),
        ],
      ),
    );
  }
} 