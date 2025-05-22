import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeType {
  light,
  dark,
  system
}

class AppColors {
  // 淺色主題顏色 - 文青風格
  static const Color primaryLight = Color(0xFF5E7B66);     // 主色調 - 輪廓綠
  static const Color primaryVariantLight = Color(0xFF3A5D43); // 深森林綠
  static const Color secondaryLight = Color(0xFFDEAA81);   // 次要色調 - 奶茶棕
  static const Color accentLight = Color(0xFFB96654);      // 強調色 - 紅土色
  static const Color backgroundLight = Color(0xFFF7F3EB);  // 背景色 - 米紙色
  static const Color surfaceLight = Color(0xFFFFFBF5);     // 表面色 - 淡杏色
  static const Color errorLight = Color(0xFFAA4A44);       // 錯誤色 - 暗紅色
  static const Color textPrimaryLight = Color(0xFF2C2A2B); // 主要文字 - 碳灰色
  static const Color textSecondaryLight = Color(0xFF5F574F); // 次要文字 - 木灰色
  static const Color dividerLight = Color(0xFFE5DED3);     // 分隔線 - 杏仁色

  // 深色主題顏色 - 文青風格
  static const Color primaryDark = Color(0xFF90A99B);      // 主色調 - 薄荷綠
  static const Color primaryVariantDark = Color(0xFF6B8F7A); // 主色調變種 - 鴨綠
  static const Color secondaryDark = Color(0xFFF0C8A4);    // 次要色調 - 淺杏色
  static const Color accentDark = Color(0xFFE0A68E);       // 強調色 - 磚粉色
  static const Color backgroundDark = Color(0xFF1E1B16);   // 背景色 - 深咖啡色
  static const Color surfaceDark = Color(0xFF252219);      // 表面色 - 橄欖黑
  static const Color errorDark = Color(0xFFE57373);        // 錯誤色 - 淺紅色
  static const Color textPrimaryDark = Color(0xFFF4EBE0);  // 主要文字 - 米白色
  static const Color textSecondaryDark = Color(0xFFD5CAB9); // 次要文字 - 灰米色
  static const Color dividerDark = Color(0xFF3E392F);      // 分隔線 - 深咖啡色
  
  // 系統顏色（不隨主題變化）
  static const Color success = Color(0xFF7CB894);          // 成功 - 淡綠色
  static const Color warning = Color(0xFFE6B485);          // 警告 - 杏色
  static const Color info = Color(0xFF8EACCF);             // 信息 - 灰藍色
}

class AppTheme {
  static ThemeData lightTheme({
    Color primaryColor = AppColors.primaryLight,
    Color secondaryColor = AppColors.secondaryLight,
    Color accentColor = AppColors.accentLight,
  }) {
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: Color.lerp(primaryColor, Colors.white, 0.7),
      onPrimaryContainer: primaryColor.withOpacity(0.9),
      secondary: secondaryColor,
      onSecondary: Colors.black,
      secondaryContainer: Color.lerp(secondaryColor, Colors.white, 0.7),
      onSecondaryContainer: secondaryColor.withOpacity(0.9),
      tertiary: accentColor,
      onTertiary: Colors.white,
      tertiaryContainer: Color.lerp(accentColor, Colors.white, 0.7),
      onTertiaryContainer: accentColor.withOpacity(0.9),
      error: AppColors.errorLight,
      onError: Colors.white,
      errorContainer: Color.lerp(AppColors.errorLight, Colors.white, 0.85),
      onErrorContainer: AppColors.errorLight.withOpacity(0.9),
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceVariant: Color.lerp(AppColors.surfaceLight, AppColors.primaryLight, 0.05),
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.dividerLight,
      outlineVariant: AppColors.dividerLight.withOpacity(0.5),
      shadow: Colors.black.withOpacity(0.1),
      scrim: Colors.black.withOpacity(0.2),
      inverseSurface: AppColors.textPrimaryLight,
      onInverseSurface: AppColors.surfaceLight,
      inversePrimary: Color.lerp(primaryColor, Colors.white, 0.2),
      surfaceTint: primaryColor.withOpacity(0.02),
      background: AppColors.backgroundLight,
      onBackground: AppColors.textPrimaryLight,
      surfaceContainerHighest: Color.lerp(AppColors.surfaceLight, AppColors.backgroundLight, 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.notoSerifTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      typography: Typography.material2021(),
      // AppBar - Material 3 風格
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceVariant,
        foregroundColor: colorScheme.onSurfaceVariant,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerif(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      // 導航欄 - Material 3 風格
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.notoSerif(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSecondaryContainer,
            );
          }
          return GoogleFonts.notoSerif(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(
              color: colorScheme.onSecondaryContainer,
              size: 24,
            );
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      // 浮動按鈕 - Material 3 風格
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        highlightElevation: 6,
        shape: const StadiumBorder(),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        extendedTextStyle: GoogleFonts.notoSerif(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      // 卡片 - Material 3 風格
      cardTheme: CardTheme(
        color: colorScheme.surfaceVariant,
        elevation: 0,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // 基本按鈕 - Material 3 風格
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.notoSerif(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // 文字按鈕 - Material 3 風格
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.notoSerif(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // 輪廓按鈕 - Material 3 風格
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          side: BorderSide(color: colorScheme.outline, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.notoSerif(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // 圖標按鈕 - Material 3 風格
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          minimumSize: const Size(48, 48),
        ),
      ),
      // 輸入框 - Material 3 風格
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      scaffoldBackgroundColor: colorScheme.background,
      splashColor: colorScheme.primary.withOpacity(0.1),
      highlightColor: colorScheme.primary.withOpacity(0.05),
      // 提示條 - Material 3 風格
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: GoogleFonts.notoSerif(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }

  static ThemeData darkTheme({
    Color primaryColor = AppColors.primaryDark,
    Color secondaryColor = AppColors.secondaryDark,
    Color accentColor = AppColors.accentDark,
  }) {
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: Color.lerp(primaryColor, Colors.white, 0.3),
      onPrimaryContainer: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.black,
      secondaryContainer: Color.lerp(secondaryColor, Colors.black, 0.3),
      onSecondaryContainer: secondaryColor,
      tertiary: accentColor,
      onTertiary: Colors.white,
      tertiaryContainer: Color.lerp(accentColor, Colors.black, 0.3),
      onTertiaryContainer: accentColor,
      error: AppColors.errorDark,
      onError: Colors.white,
      errorContainer: Color.lerp(AppColors.errorDark, Colors.black, 0.3),
      onErrorContainer: AppColors.errorDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceVariant: Color.lerp(AppColors.surfaceDark, AppColors.primaryDark, 0.1),
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.dividerDark,
      outlineVariant: AppColors.dividerDark.withOpacity(0.3),
      shadow: Colors.black.withOpacity(0.3),
      scrim: Colors.black.withOpacity(0.6),
      inverseSurface: AppColors.textPrimaryDark,
      onInverseSurface: AppColors.surfaceDark,
      inversePrimary: primaryColor.withOpacity(0.8),
      surfaceTint: primaryColor.withOpacity(0.05),
      background: AppColors.backgroundDark,
      onBackground: AppColors.textPrimaryDark,
      surfaceContainerHighest: Color.lerp(AppColors.surfaceDark, Colors.black, 0.2),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.notoSerifTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      typography: Typography.material2021(),
      // AppBar - Material 3 風格
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceVariant,
        foregroundColor: colorScheme.onSurfaceVariant,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerif(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      // 導航欄 - Material 3 風格
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.notoSerif(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSecondaryContainer,
            );
          }
          return GoogleFonts.notoSerif(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(
              color: colorScheme.onSecondaryContainer,
              size: 24,
            );
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      // 浮動按鈕 - Material 3 風格
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        highlightElevation: 6,
        shape: const StadiumBorder(),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        extendedTextStyle: GoogleFonts.notoSerif(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      // 卡片 - Material 3 風格
      cardTheme: CardTheme(
        color: colorScheme.surfaceVariant,
        elevation: 0,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // 基本按鈕 - Material 3 風格
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.notoSerif(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // 文字按鈕 - Material 3 風格
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.notoSerif(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // 輪廓按鈕 - Material 3 風格
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          side: BorderSide(color: colorScheme.outline, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.notoSerif(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // 圖標按鈕 - Material 3 風格
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          minimumSize: const Size(48, 48),
        ),
      ),
      // 輸入框 - Material 3 風格
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      scaffoldBackgroundColor: colorScheme.background,
      splashColor: colorScheme.primary.withOpacity(0.1),
      highlightColor: colorScheme.primary.withOpacity(0.05),
      // 提示條 - Material 3 風格
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: GoogleFonts.notoSerif(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }
  
  // 獲取當前主題
  static ThemeData getTheme(AppThemeType type, BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    
    switch (type) {
      case AppThemeType.light:
        return lightTheme();
      case AppThemeType.dark:
        return darkTheme();
      case AppThemeType.system:
        return brightness == Brightness.dark ? darkTheme() : lightTheme();
    }
  }
}