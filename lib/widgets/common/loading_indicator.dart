import 'package:flutter/material.dart';

/// 加載指示器組件
class LoadingIndicator extends StatelessWidget {
  /// 顯示的文本
  final String? message;
  
  /// 尺寸
  final double size;
  
  /// 顏色
  final Color? color;
  
  /// 建構函數
  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 36.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 