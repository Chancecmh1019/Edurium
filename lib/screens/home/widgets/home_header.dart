import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String date;

  const HomeHeader({
    Key? key,
    required this.userName,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 問候語
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 用戶問候
            Text(
              '$userName，',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // 右側圖標
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.grey.shade800 
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: isDarkMode 
                    ? Colors.white 
                    : Colors.black87,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // 歡迎訊息
        Text(
          '歡迎回來！',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 日期
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? Colors.grey.shade800.withOpacity(0.8) 
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode 
                  ? Colors.white 
                  : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
} 