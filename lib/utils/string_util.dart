class StringUtil {
  // 截斷字符串，超過maxLength會顯示...
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
  
  // 首字母大寫
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  // 將蛇形命名轉換為標題形式（例如：task_type -> Task Type）
  static String snakeToTitle(String text) {
    if (text.isEmpty) return text;
    
    return text.split('_').map((word) => capitalize(word)).join(' ');
  }
  
  // 將駝峰命名轉換為標題形式（例如：taskType -> Task Type）
  static String camelToTitle(String text) {
    if (text.isEmpty) return text;
    
    // 在大寫字母前加空格，然後首字母大寫
    String result = text.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (match) => ' ${match.group(0)}',
    );
    
    return capitalize(result);
  }
  
  // 獲取任務類型的本地化名稱
  static String getTaskTypeName(String type, {String languageCode = 'zh'}) {
    if (languageCode == 'zh') {
      switch (type.toLowerCase()) {
        case 'exam':
          return '考試';
        case 'homework':
          return '作業';
        case 'project':
          return '專案';
        case 'meeting':
          return '會議';
        case 'reminder':
          return '提醒';
        default:
          return type;
      }
    } else {
      // 英文或其他語言
      return capitalize(type);
    }
  }
  
  // 獲取任務優先級的本地化名稱
  static String getPriorityName(String priority, {String languageCode = 'zh'}) {
    if (languageCode == 'zh') {
      switch (priority.toLowerCase()) {
        case 'high':
          return '高';
        case 'medium':
          return '中';
        case 'low':
          return '低';
        default:
          return priority;
      }
    } else {
      // 英文或其他語言
      return capitalize(priority);
    }
  }
  
  // 從字符串中提取首字母（用於顯示頭像）
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    // 分割名字並獲取每部分的首字母
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      // 只有一個名字，返回前兩個字符或僅一個字符
      return name.length > 1 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
    } else {
      // 多個名字，返回首字母
      return parts.map((part) => part.isNotEmpty ? part[0].toUpperCase() : '').join();
    }
  }
  
  // 判斷字符串是否為Email
  static bool isEmail(String text) {
    if (text.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    
    return emailRegex.hasMatch(text);
  }
  
  // 判斷字符串是否為URL
  static bool isUrl(String text) {
    if (text.isEmpty) return false;
    
    final urlRegex = RegExp(
      r'^(http|https)://[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    
    return urlRegex.hasMatch(text);
  }
  
  // 判斷字符串是否為手機號碼（簡單判斷）
  static bool isPhoneNumber(String text) {
    if (text.isEmpty) return false;
    
    final phoneRegex = RegExp(r'^[0-9+\- ]{8,15}$');
    
    return phoneRegex.hasMatch(text);
  }
  
  // 移除HTML標籤
  static String removeHtmlTags(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  }
  
  // 將字符串轉換為安全的文件名
  static String toSafeFileName(String input) {
    // 替換不允許在文件名中的字符
    return input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
} 