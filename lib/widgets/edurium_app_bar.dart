import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_theme.dart';
import '../utils/navigation_handler.dart';

enum AppBarStyle {
  normal,
  transparent,
  colored,
}

class EduriumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final double? elevation;
  final Color? backgroundColor;
  final AppBarStyle style;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final double height;
  final VoidCallback? onLeadingPressed;
  final Widget? titleWidget;
  final bool scrolledUnderElevation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const EduriumAppBar({
    super.key,
    this.title = '',
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.elevation,
    this.backgroundColor,
    this.style = AppBarStyle.normal,
    this.flexibleSpace,
    this.bottom,
    this.centerTitle = true,
    this.height = kToolbarHeight,
    this.onLeadingPressed,
    this.titleWidget,
    this.scrolledUnderElevation = true,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? height + bottom!.preferredSize.height : height);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    Color defaultBackgroundColor;
    Color defaultForegroundColor;
    Color defaultIconColor;
    double defaultElevation;
    double defaultScrolledUnderElevation;
    
    switch (style) {
      case AppBarStyle.transparent:
        defaultBackgroundColor = Colors.transparent;
        defaultForegroundColor = isDarkMode ? Colors.white : Colors.black;
        defaultIconColor = colorScheme.primary;
        defaultElevation = 0;
        defaultScrolledUnderElevation = 0;
        break;
      case AppBarStyle.colored:
        defaultBackgroundColor = colorScheme.primaryContainer;
        defaultForegroundColor = colorScheme.onPrimaryContainer;
        defaultIconColor = colorScheme.primary;
        defaultElevation = 0;
        defaultScrolledUnderElevation = 3;
        break;
      case AppBarStyle.normal:
      default:
        defaultBackgroundColor = colorScheme.surface;
        defaultForegroundColor = colorScheme.onSurface;
        defaultIconColor = colorScheme.primary;
        defaultElevation = 0;
        defaultScrolledUnderElevation = 2;
    }
    
    // 標題文字樣式
    final titleTextStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: defaultForegroundColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    final canPop = Navigator.of(context).canPop();
    
    // 構建返回按鈕
    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (automaticallyImplyLeading && (canPop || showBackButton)) {
      leadingWidget = _buildBackButton(context);
    }

    return AppBar(
      title: titleWidget ?? Text(
        title,
        style: titleTextStyle,
      ),
      actions: actions,
      automaticallyImplyLeading: false, // 我們使用自定義的返回按鈕
      leading: leadingWidget,
      elevation: elevation ?? defaultElevation,
      scrolledUnderElevation: scrolledUnderElevation ? defaultScrolledUnderElevation : 0,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: colorScheme.surfaceTint,
      backgroundColor: backgroundColor ?? defaultBackgroundColor,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      centerTitle: centerTitle,
      iconTheme: IconThemeData(
        color: defaultIconColor,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: defaultIconColor,
        size: 24,
      ),
      titleSpacing: NavigationToolbar.kMiddleSpacing,
      toolbarHeight: height,
      shape: style == AppBarStyle.transparent
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
    );
  }
  
  // 構建自定義返回按鈕
  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      onPressed: () {
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          // 使用自定義導航處理返回
          NavigationHandler.goBack(context);
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Theme.of(context).colorScheme.surfaceVariant,
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        padding: MaterialStateProperty.all(const EdgeInsets.all(8.0)),
        shape: MaterialStateProperty.all(const CircleBorder()),
        minimumSize: MaterialStateProperty.all(const Size(40, 40)),
      ),
    );
  }
}

// 滾動時顯示陰影的應用欄
class EduriumSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;
  final double? titleSpacing;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double? elevation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const EduriumSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.bottom,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.expandedHeight,
    this.flexibleSpace,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.elevation,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    final canPop = Navigator.of(context).canPop();

    // 使用默認顏色或自定義顏色
    final bgColor = backgroundColor ?? 
        (isDarkMode ? Colors.grey.shade900 : Colors.white);
    
    // 默認文字顏色
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    // 構建返回按鈕
    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (automaticallyImplyLeading && (canPop || showBackButton)) {
      leadingWidget = _buildBackButton(context);
    }
    
    return SliverAppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      leading: leadingWidget,
      automaticallyImplyLeading: false, // 我們使用自定義的返回按鈕
      actions: actions,
      bottom: bottom,
      backgroundColor: bgColor,
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      flexibleSpace: flexibleSpace,
      titleSpacing: titleSpacing,
      elevation: elevation ?? 0,
    );
  }
  
  // 構建自定義返回按鈕
  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      onPressed: () {
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          // 使用自定義導航處理返回
          NavigationHandler.goBack(context);
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Theme.of(context).colorScheme.surfaceVariant,
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        padding: MaterialStateProperty.all(const EdgeInsets.all(8.0)),
        shape: MaterialStateProperty.all(const CircleBorder()),
        minimumSize: MaterialStateProperty.all(const Size(40, 40)),
      ),
    );
  }
}