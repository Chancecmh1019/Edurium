import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 應用程式日期工具類
class AppDateUtils {
  /// 格式化日期
  static String formatDate(DateTime date, {Locale? locale}) {
    final formatter = DateFormat.yMMMd(locale?.toString());
    return formatter.format(date);
  }
  
  /// 格式化日期和時間
  static String formatDateTime(DateTime date, {Locale? locale}) {
    final formatter = DateFormat.yMMMd(locale?.toString()).add_Hm();
    return formatter.format(date);
  }
  
  /// 格式化時間
  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  /// 獲取星期幾的名稱
  static String getWeekdayName(DateTime date, {Locale? locale}) {
    final formatter = DateFormat('EEEE', locale?.toString());
    return formatter.format(date);
  }
  
  /// 獲取短星期幾的名稱
  static String getShortWeekdayName(DateTime date, {Locale? locale}) {
    final formatter = DateFormat('EEE', locale?.toString());
    return formatter.format(date);
  }
  
  /// 獲取月份名稱
  static String getMonthName(DateTime date, {Locale? locale}) {
    final formatter = DateFormat('MMMM', locale?.toString());
    return formatter.format(date);
  }
  
  /// 獲取簡短月份名稱
  static String getShortMonthName(DateTime date, {Locale? locale}) {
    final formatter = DateFormat('MMM', locale?.toString());
    return formatter.format(date);
  }
  
  /// 格式化月和年份
  static String formatMonthYear(DateTime date, {Locale? locale}) {
    final formatter = DateFormat('MMMM yyyy', locale?.toString());
    return formatter.format(date);
  }
  
  /// 格式化相對時間（例如：今天、明天、昨天）
  static String formatRelativeDate(DateTime date, {Locale? locale}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);
    
    if (inputDate == today) {
      return locale?.languageCode == 'zh' ? '今天' : 'Today';
    } else if (inputDate == tomorrow) {
      return locale?.languageCode == 'zh' ? '明天' : 'Tomorrow';
    } else if (inputDate == yesterday) {
      return locale?.languageCode == 'zh' ? '昨天' : 'Yesterday';
    } else {
      return formatDate(date, locale: locale);
    }
  }
  
  /// 獲取兩個日期之間的天數差
  static int getDaysDifference(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return (d2.difference(d1).inHours / 24).round();
  }
  
  /// 獲取離現在的天數（負數為過去的天數）
  static int getDaysLeft(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return getDaysDifference(today, targetDate);
  }
  
  /// 獲取當前週的第一天（星期一）
  static DateTime getFirstDayOfWeek([DateTime? date]) {
    final now = date ?? DateTime.now();
    // 當前週的第一天（星期一）
    int difference = now.weekday - 1;
    return now.subtract(Duration(days: difference));
  }
  
  /// 獲取當前週的最後一天（星期日）
  static DateTime getLastDayOfWeek([DateTime? date]) {
    final firstDay = getFirstDayOfWeek(date);
    return firstDay.add(const Duration(days: 6));
  }
  
  /// 獲取當前月的第一天
  static DateTime getFirstDayOfMonth([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
  
  /// 獲取當前月的最後一天
  static DateTime getLastDayOfMonth([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }
  
  /// 獲取當月的天數
  static int getDaysInMonth([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }
  
  /// 獲取下一個月
  static DateTime getNextMonth([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month + 1, 1);
  }
  
  /// 獲取上一個月
  static DateTime getPreviousMonth([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month - 1, 1);
  }
  
  /// 檢查日期是否在同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  /// 檢查日期是否在同一週
  static bool isSameWeek(DateTime date1, DateTime date2) {
    final first1 = getFirstDayOfWeek(date1);
    final first2 = getFirstDayOfWeek(date2);
    return isSameDay(first1, first2);
  }
  
  /// 檢查日期是否在同一月
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
} 