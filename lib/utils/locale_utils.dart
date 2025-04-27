import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

/// 檢查當前的語言環境是否為中文
bool isZh(BuildContext context) {
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  return localeProvider.locale.languageCode == 'zh';
}

/// 根據當前語言環境獲取本地化文本
String getLocalizedText(BuildContext context, String zhText, String enText) {
  return isZh(context) ? zhText : enText;
}

/// 獲取當前月份的本地化名稱
String getLocalizedMonth(BuildContext context, int month) {
  final zhMonths = [
    '一月', '二月', '三月', '四月', '五月', '六月',
    '七月', '八月', '九月', '十月', '十一月', '十二月'
  ];
  
  final enMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  if (month < 1 || month > 12) {
    return '';
  }
  
  return isZh(context) ? zhMonths[month - 1] : enMonths[month - 1];
}

/// 獲取當前星期的本地化名稱
String getLocalizedWeekday(BuildContext context, int weekday) {
  final zhWeekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  final enWeekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  if (weekday < 1 || weekday > 7) {
    return '';
  }
  
  return isZh(context) ? zhWeekdays[weekday - 1] : enWeekdays[weekday - 1];
}

/// 獲取短格式的星期名稱
String getShortWeekday(BuildContext context, int weekday) {
  final zhShortWeekdays = ['一', '二', '三', '四', '五', '六', '日'];
  final enShortWeekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  if (weekday < 1 || weekday > 7) {
    return '';
  }
  
  return isZh(context) ? zhShortWeekdays[weekday - 1] : enShortWeekdays[weekday - 1];
} 