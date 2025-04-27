import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 浮動按鈕項目配置
class FloatingActionItem {
  /// 按鈕圖標
  final IconData icon;
  
  /// 顯示文字
  final String label;
  
  /// 點擊事件處理
  final VoidCallback onPressed;
  
  /// 獨立Hero標籤
  final String heroTag;
  
  /// 按鈕顏色
  final Color? backgroundColor;
  
  /// 圖標顏色
  final Color? foregroundColor;
  
  /// 標籤背景色
  final Color? labelBackgroundColor;
  
  /// 標籤文字顏色
  final Color? labelTextColor;
  
  /// 是否顯示標籤
  final bool showLabel;

  const FloatingActionItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.heroTag,
    this.backgroundColor,
    this.foregroundColor,
    this.labelBackgroundColor,
    this.labelTextColor,
    this.showLabel = true,
  });
}

/// 展開方向
enum FloatingActionMenuDirection {
  /// 向上展開
  up,
  /// 向左上展開
  topLeft,
  /// 向右上展開
  topRight,
  /// 向左展開
  left,
  /// 向右展開
  right,
  /// 向左下展開
  bottomLeft,
  /// 向右下展開
  bottomRight,
  /// 圓形展開
  circular,
}

/// 現代浮動菜單按鈕
class FloatingActionMenu extends StatefulWidget {
  /// 菜單項目
  final List<FloatingActionItem> items;
  
  /// 主按鈕圖標
  final IconData? icon;
  
  /// 展開方向
  final FloatingActionMenuDirection direction;
  
  /// 展開距離
  final double distance;
  
  /// 展開間隔
  final double spaceBetween;
  
  /// 主按鈕大小
  final double mainButtonSize;
  
  /// 子按鈕大小
  final double childButtonSize;
  
  /// 主按鈕背景色
  final Color? backgroundColor;
  
  /// 主按鈕圖標顏色
  final Color? foregroundColor;
  
  /// 子按鈕背景色
  final Color? childBackgroundColor;
  
  /// 子按鈕圖標顏色
  final Color? childForegroundColor;
  
  /// 提示文字
  final String? tooltip;
  
  /// 動畫時長
  final Duration animationDuration;
  
  /// 是否顯示疊加層
  final bool showOverlay;
  
  /// 疊加層顏色
  final Color overlayColor;
  
  /// 疊加層透明度
  final double overlayOpacity;
  
  /// 展開時回調
  final VoidCallback? onOpen;
  
  /// 收起時回調
  final VoidCallback? onClose;
  
  /// 是否顯示子按鈕標籤
  final bool showLabels;
  
  /// 標籤顯示位置
  final LabelPosition labelPosition;
  
  /// 是否使用交錯動畫
  final bool useStaggeredAnimation;

  const FloatingActionMenu({
    Key? key,
    required this.items,
    this.icon = Icons.add,
    this.direction = FloatingActionMenuDirection.up,
    this.distance = 120,
    this.spaceBetween = 12,
    this.mainButtonSize = 56,
    this.childButtonSize = 48,
    this.backgroundColor,
    this.foregroundColor,
    this.childBackgroundColor,
    this.childForegroundColor,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showOverlay = true,
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.5,
    this.onOpen,
    this.onClose,
    this.showLabels = true,
    this.labelPosition = LabelPosition.top,
    this.useStaggeredAnimation = true,
  }) : super(key: key);

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

/// 標籤位置枚舉
enum LabelPosition { top, bottom, left, right }

class _FloatingActionMenuState extends State<FloatingActionMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _mainRotateAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _mainButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _mainRotateAnimation = Tween<double>(
      begin: 0,
      end: 0.125, // 旋轉45度
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    ));
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      
      if (_isOpen) {
        _showOverlay();
        _animationController.forward();
        widget.onOpen?.call();
      } else {
        _removeOverlay();
        _animationController.reverse();
        widget.onClose?.call();
      }
    });
  }

  void _showOverlay() {
    if (!widget.showOverlay) return;
    
    _removeOverlay();
    
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          color: widget.overlayColor.withOpacity(widget.overlayOpacity),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      )
    );
    
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final foregroundColor = widget.foregroundColor ?? theme.colorScheme.onPrimary;
    
    return SizedBox(
      width: widget.mainButtonSize,
      height: widget.mainButtonSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ..._buildExpandingButtons(),
          _buildMainButton(backgroundColor, foregroundColor),
        ],
      ),
    );
  }

  Widget _buildMainButton(Color backgroundColor, Color foregroundColor) {
    return SizedBox(
      width: widget.mainButtonSize,
      height: widget.mainButtonSize,
      child: FloatingActionButton(
        key: _mainButtonKey,
        heroTag: 'floatingActionMenu',
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        tooltip: widget.tooltip,
        elevation: _isOpen ? 8 : 6,
        onPressed: _toggleMenu,
        child: AnimatedBuilder(
          animation: _mainRotateAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _mainRotateAnimation.value * 2 * math.pi,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _animationController,
                color: foregroundColor,
              ),
            );
          }
        ),
      ),
    );
  }

  List<Widget> _buildExpandingButtons() {
    final items = <Widget>[];
    final count = widget.items.length;
    
    for (int i = 0; i < count; i++) {
      final item = widget.items[i];
      final interval = widget.useStaggeredAnimation
          ? Interval(0.1 + 0.9 * i / count, 1.0, curve: Curves.easeOut)
          : const Interval(0.0, 1.0, curve: Curves.easeOut);
      
      final staggeredAnimation = CurvedAnimation(
        parent: _animationController,
        curve: interval,
      );

      final childAnimation = Tween<double>(begin: 0.0, end: 1.0)
          .animate(staggeredAnimation);
      
      items.add(_buildExpandingActionButton(i, item, childAnimation));
    }
    
    return items;
  }

  Widget _buildExpandingActionButton(int index, FloatingActionItem item, Animation<double> animation) {
    final double directionAngle = _calculateAngle(widget.direction, index);
    final childBackgroundColor = item.backgroundColor ?? 
        widget.childBackgroundColor ?? 
        Theme.of(context).colorScheme.secondary;
    final childForegroundColor = item.foregroundColor ?? 
        widget.childForegroundColor ?? 
        Theme.of(context).colorScheme.onSecondary;
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // 計算展開偏移量，要考慮到按鈕間距
        final distance = widget.distance + index * widget.spaceBetween;
        
        final offset = Offset.fromDirection(
          directionAngle,
          animation.value * distance,
        );
        
        return Positioned(
          right: (widget.mainButtonSize - widget.childButtonSize) / 2,
          bottom: (widget.mainButtonSize - widget.childButtonSize) / 2,
          child: Transform.translate(
            offset: offset,
            child: Transform.scale(
              scale: animation.value,
              child: Opacity(
                opacity: animation.value,
                child: _buildActionButton(
                  item, 
                  childBackgroundColor, 
                  childForegroundColor
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateAngle(FloatingActionMenuDirection direction, int index) {
    final count = widget.items.length;
    final indexFactor = index + 1; // 避免按鈕重疊，確保第一個按鈕也有間距
    switch (direction) {
      case FloatingActionMenuDirection.up:
        return -math.pi / 2; // 0度為右，-90度為上
      case FloatingActionMenuDirection.topLeft:
        return -math.pi * 3/4; // -135度為左上
      case FloatingActionMenuDirection.topRight:
        return -math.pi / 4; // -45度為右上
      case FloatingActionMenuDirection.left:
        return math.pi; // 180度為左
      case FloatingActionMenuDirection.right:
        return 0; // 0度為右
      case FloatingActionMenuDirection.bottomLeft:
        return math.pi * 3/4; // 135度為左下
      case FloatingActionMenuDirection.bottomRight:
        return math.pi / 4; // 45度為右下
      case FloatingActionMenuDirection.circular:
        // 圓形展開，按鈕間隔均勻分布
        // 修正計算方式，確保按鈕不會重疊
        final angleIncrement = 2 * math.pi / (count * 1.5);
        final startAngle = -math.pi / 2 - (count - 1) * angleIncrement / 2;
        return startAngle + index * angleIncrement;
    }
  }

  Widget _buildActionButton(
    FloatingActionItem item, 
    Color backgroundColor, 
    Color foregroundColor
  ) {
    final labelVisible = widget.showLabels && item.showLabel;
    
    Widget button = SizedBox(
      width: widget.childButtonSize,
      height: widget.childButtonSize,
      child: FloatingActionButton(
        heroTag: item.heroTag,
        mini: widget.childButtonSize < 50,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onPressed: () {
          _toggleMenu();
          item.onPressed();
        },
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.childButtonSize / 3),
        ),
        child: Icon(item.icon),
      ),
    );
    
    if (labelVisible) {
      final labelBackgroundColor = item.labelBackgroundColor ?? 
          backgroundColor.withOpacity(0.85);
      final labelTextColor = item.labelTextColor ?? foregroundColor;
      
      final label = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: labelBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          item.label,
          style: TextStyle(
            color: labelTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      );
      
      switch (widget.labelPosition) {
        case LabelPosition.top:
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              label,
              const SizedBox(height: 8),
              button,
            ],
          );
        case LabelPosition.bottom:
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              button,
              const SizedBox(height: 8),
              label,
            ],
          );
        case LabelPosition.left:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              label,
              const SizedBox(width: 8),
              button,
            ],
          );
        case LabelPosition.right:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              button,
              const SizedBox(width: 8),
              label,
            ],
          );
      }
    }
    
    return button;
  }
} 