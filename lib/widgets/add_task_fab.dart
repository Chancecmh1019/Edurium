import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../providers/providers.dart';
import '../themes/app_theme.dart';
import '../utils/navigation_handler.dart';

class AddTaskFAB extends StatefulWidget {
  const AddTaskFAB({Key? key}) : super(key: key);

  @override
  State<AddTaskFAB> createState() => _AddTaskFABState();
}

class _AddTaskFABState extends State<AddTaskFAB> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildFabItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required double angle,
    required double distance,
  }) {
    final double rad = (angle + 180) * math.pi / 180;
    final double x = distance * math.cos(rad);
    final double y = distance * math.sin(rad);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: _isExpanded ? x + 16 : 0,
      bottom: _isExpanded ? y + 16 : 0,
      child: AnimatedOpacity(
        opacity: _isExpanded ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedScale(
          scale: _isExpanded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            width: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _toggleExpanded();
                      onPressed();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            icon,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景模糊遮罩
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: _isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: _isExpanded ? _toggleExpanded : null,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _isExpanded ? 3.0 : 0.0,
                  sigmaY: _isExpanded ? 3.0 : 0.0,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
        
        // 主要FAB按鈕
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _toggleExpanded,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedRotation(
              turns: _animationController.value * 0.125,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isExpanded ? Icons.close : Icons.add,
              ),
            ),
          ),
        ),
        
        // 任務按鈕 - 向上展開
        _buildFabItem(
          icon: Icons.assignment,
          label: '新增任務',
          onPressed: () {
            NavigationHandler.navigateTo(context, '/add_task');
          },
          angle: 270, // 正上方
          distance: 80,
        ),
        
        // 科目按鈕
        _buildFabItem(
          icon: Icons.book,
          label: '新增科目',
          onPressed: () {
            NavigationHandler.navigateTo(context, '/add_subject');
          },
          angle: 315, // 右上方
          distance: 80,
        ),
        
        // 教師按鈕
        _buildFabItem(
          icon: Icons.person,
          label: '新增教師',
          onPressed: () {
            NavigationHandler.navigateTo(context, '/add_teacher');
          },
          angle: 225, // 左上方
          distance: 80,
        ),
        
        // 成績按鈕
        _buildFabItem(
          icon: Icons.grade,
          label: '新增成績',
          onPressed: () {
            NavigationHandler.navigateTo(context, '/add_grade');
          },
          angle: 290, // 偏右上方
          distance: 140,
        ),
      ],
    );
  }
}

class ExpandableFAB extends StatefulWidget {
  final List<ExpandableFabItem> items;
  final String tooltip;
  final IconData icon;
  final Color? backgroundColor;
  final Duration duration;

  const ExpandableFAB({
    Key? key,
    required this.items,
    this.tooltip = '選項',
    this.icon = Icons.add,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 250),
  }) : super(key: key);

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = widget.backgroundColor ?? 
        (isDarkMode ? AppColors.accentDark : AppColors.accentLight);
    
    return Stack(
      children: [
        // 背景遮罩
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
        
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 展開的子項目
            ..._buildExpandableItems(),
            
            // 主按鈕
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggle,
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _isOpen ? 0.125 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildExpandableItems() {
    if (!_isOpen) {
      return [];
    }
    
    final items = <Widget>[];
    
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      
      items.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = CurvedAnimation(
              parent: _controller,
              curve: Interval(
                0.2 * i, 
                0.2 * i + 0.8,
                curve: Curves.easeOutCubic,
              ),
            ).value;
            
            return Transform.translate(
              offset: Offset(0, 20 * (1.0 - progress)),
              child: Opacity(
                opacity: progress,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildFabItem(item),
          ),
        ),
      );
    }
    
    return items;
  }

  Widget _buildFabItem(ExpandableFabItem item) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = item.backgroundColor ?? 
        (isDarkMode ? AppColors.primaryDark : AppColors.primaryLight);
        
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.label != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              item.label!,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _toggle();
                item.onPressed();
              },
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ExpandableFabItem {
  final IconData icon;
  final String? label;
  final String? tooltip;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final String? heroTag;

  ExpandableFabItem({
    required this.icon,
    required this.onPressed,
    this.label,
    this.tooltip,
    this.backgroundColor,
    this.heroTag,
  });
}

class AnimatedAddTaskFAB extends StatefulWidget {
  final VoidCallback onAddTaskPressed;
  final VoidCallback? onAddHomeworkPressed;
  final VoidCallback? onAddExamPressed;
  final VoidCallback? onAddProjectPressed;
  final VoidCallback? onAddReminderPressed;
  
  const AnimatedAddTaskFAB({
    super.key,
    required this.onAddTaskPressed,
    this.onAddHomeworkPressed,
    this.onAddExamPressed,
    this.onAddProjectPressed,
    this.onAddReminderPressed,
  });

  @override
  State<AnimatedAddTaskFAB> createState() => _AnimatedAddTaskFABState();
}

class _AnimatedAddTaskFABState extends State<AnimatedAddTaskFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.accentDark : AppColors.accentLight;
    
    return Container(
      padding: const EdgeInsets.only(bottom: 16, right: 16),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          FloatingActionButton(
            onPressed: _toggle,
            tooltip: '新增項目',
            backgroundColor: backgroundColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _controller,
              color: Colors.white,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _isOpen
                  ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
} 