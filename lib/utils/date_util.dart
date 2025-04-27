import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtil {
  // 格式化日期為 yyyy-MM-dd
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // 格式化日期為更友好的顯示形式
  static String formatDateFriendly(DateTime date, {Locale locale = const Locale('zh', 'TW')}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    String pattern;
    
    if (locale.languageCode == 'zh') {
      if (dateOnly == today) {
        return '今天';
      } else if (dateOnly == yesterday) {
        return '昨天';
      } else if (dateOnly == tomorrow) {
        return '明天';
      } else if (dateOnly.year == now.year) {
        // 同年，只顯示月日
        pattern = 'MM月dd日';
      } else {
        // 不同年，顯示年月日
        pattern = 'yyyy年MM月dd日';
      }
    } else {
      // 英文或其他語言
      if (dateOnly == today) {
        return 'Today';
      } else if (dateOnly == yesterday) {
        return 'Yesterday';
      } else if (dateOnly == tomorrow) {
        return 'Tomorrow';
      } else if (dateOnly.year == now.year) {
        // 同年，只顯示月日
        pattern = 'MMM d';
      } else {
        // 不同年，顯示年月日
        pattern = 'MMM d, yyyy';
      }
    }
    
    return DateFormat(pattern, locale.toString()).format(date);
  }
  
  // 格式化日期和時間
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
  
  // 格式化時間為相對形式（幾分鐘前、幾小時前等）
  static String formatDateTimeRelative(DateTime date, {Locale locale = const Locale('zh', 'TW')}) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (locale.languageCode == 'zh') {
      if (difference.inSeconds < 60) {
        return '剛剛';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分鐘前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}小時前';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}天前';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()}個月前';
      } else {
        return '${(difference.inDays / 365).floor()}年前';
      }
    } else {
      // 英文或其他語言
      if (difference.inSeconds < 60) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      }
    }
  }
  
  // 格式化時間
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  // 計算兩個日期之間的天數差異
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
  
  // 獲取日期範圍內的所有日期
  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }
  
  // 獲取當前週的起始和結束日期
  static Map<String, DateTime> getCurrentWeekRange() {
    final now = DateTime.now();
    // 假設週一是一週的開始
    final weekday = now.weekday;
    final firstDayOfWeek = now.subtract(Duration(days: weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    
    return {
      'start': DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day),
      'end': DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day),
    };
  }
  
  // 獲取當前月的起始和結束日期
  static Map<String, DateTime> getCurrentMonthRange() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return {
      'start': firstDayOfMonth,
      'end': lastDayOfMonth,
    };
  }
  
  // 獲取日期是星期幾
  static String getWeekdayName(DateTime date, {Locale locale = const Locale('zh', 'TW')}) {
    final weekday = date.weekday;
    
    if (locale.languageCode == 'zh') {
      switch (weekday) {
        case DateTime.monday:
          return '星期一';
        case DateTime.tuesday:
          return '星期二';
        case DateTime.wednesday:
          return '星期三';
        case DateTime.thursday:
          return '星期四';
        case DateTime.friday:
          return '星期五';
        case DateTime.saturday:
          return '星期六';
        case DateTime.sunday:
          return '星期日';
        default:
          return '';
      }
    } else {
      // 英文或其他語言
      return DateFormat('EEEE', locale.toString()).format(date);
    }
  }
  
  // 獲取日期是星期幾（短格式）
  static String getWeekdayShortName(DateTime date, {Locale locale = const Locale('zh', 'TW')}) {
    final weekday = date.weekday;
    
    if (locale.languageCode == 'zh') {
      switch (weekday) {
        case DateTime.monday:
          return '一';
        case DateTime.tuesday:
          return '二';
        case DateTime.wednesday:
          return '三';
        case DateTime.thursday:
          return '四';
        case DateTime.friday:
          return '五';
        case DateTime.saturday:
          return '六';
        case DateTime.sunday:
          return '日';
        default:
          return '';
      }
    } else {
      // 英文或其他語言
      return DateFormat('E', locale.toString()).format(date);
    }
  }
  
  // 獲取月份名稱
  static String getMonthName(DateTime date, {Locale locale = const Locale('zh', 'TW')}) {
    if (locale.languageCode == 'zh') {
      return '${date.month}月';
    } else {
      // 英文或其他語言
      return DateFormat('MMMM', locale.toString()).format(date);
    }
  }
  
  // 獲取月份名稱（短格式）
  static String getMonthShortName(DateTime date, {Locale locale = const Locale('zh', 'TW')}) {
    if (locale.languageCode == 'zh') {
      return '${date.month}月';
    } else {
      // 英文或其他語言
      return DateFormat('MMM', locale.toString()).format(date);
    }
  }
} 