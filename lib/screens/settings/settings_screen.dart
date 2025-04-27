import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../providers/providers.dart';
import '../../themes/app_theme.dart';
import '../../utils/constants.dart';
import '../edit_profile_screen.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    final user = userProvider.currentUser;
    final isDarkMode = themeProvider.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 用戶資訊
          _buildUserInfoSection(context),
          
          // 自定義
          _buildCustomizationSection(context),
          
          // 區域設定
          _buildLocalizationSection(context),
          
          // 存取設定
          _buildAccessibilitySection(context),
          
          // 關於
          _buildAboutSection(context),
        ],
      ),
    );
  }
  
  // 區段標題
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  // 個人資料卡片
  Widget _buildProfileCard(BuildContext context, user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 頭像
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                backgroundImage: user?.photoUrl != null && user!.photoUrl!.startsWith('data:image')
                    ? MemoryImage(_decodeBase64Image(user.photoUrl!))
                    : null,
                child: user?.photoUrl == null
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // 用戶資訊
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? context.l10n.notSet,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.tapToEditProfile,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 編輯按鈕
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 一般設定卡片
  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  // 帶開關的設定卡片
  Widget _buildSwitchCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
  
  // 獲取主題文字
  String _getThemeText(ThemeType themeType, BuildContext context) {
    switch (themeType) {
      case ThemeType.light:
        return context.l10n.light;
      case ThemeType.dark:
        return context.l10n.dark;
      case ThemeType.system:
        return context.l10n.system;
    }
  }
  
  // 顯示主題選擇對話框
  void _showThemeModal(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.chooseTheme,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 系統主題
                  _buildThemeOption(
                    context,
                    title: context.l10n.system,
                    icon: Icons.brightness_auto,
                    isSelected: themeProvider.themeType == ThemeType.system,
                    onTap: () {
                      themeProvider.setTheme(ThemeType.system);
                      Navigator.pop(context);
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // 淺色主題
                  _buildThemeOption(
                    context,
                    title: context.l10n.light,
                    icon: Icons.light_mode,
                    isSelected: themeProvider.themeType == ThemeType.light,
                    onTap: () {
                      themeProvider.setTheme(ThemeType.light);
                      Navigator.pop(context);
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // 深色主題
                  _buildThemeOption(
                    context,
                    title: context.l10n.dark,
                    icon: Icons.dark_mode,
                    isSelected: themeProvider.themeType == ThemeType.dark,
                    onTap: () {
                      themeProvider.setTheme(ThemeType.dark);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // 主題選項
  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
  
  // 顯示語言選擇對話框
  void _showLanguageModal(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.chooseLanguage,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 語言選擇列表
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: LocaleProvider.localeNames.entries.map((entry) {
                        final locale = LocaleProvider.supportedLocales[entry.key]!;
                        final isSelected = localeProvider.locale.languageCode == locale.languageCode &&
                                          (locale.countryCode == null || 
                                           localeProvider.locale.countryCode == locale.countryCode);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () {
                              localeProvider.setLocale(entry.key);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected 
                                          ? Theme.of(context).colorScheme.primary 
                                          : null,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // 顯示字體大小選擇對話框
  void _showFontSizeModal(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.fontSize,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 字體大小選擇
                  ...FontSizeType.values.map((type) {
                    final isSelected = fontSizeProvider.fontSizeType == type;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          fontSizeProvider.setFontSize(type);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                FontSizeProvider.getFontSizeTypeName(type, context),
                                style: TextStyle(
                                  fontSize: 14 + (FontSizeProvider.fontSizeFactors[type]! - 0.85) * 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary 
                                      : null,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // 顯示關於對話框
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.aboutApp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.school,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Edurium',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${context.l10n.version} ${AppConstants.appVersion}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.aboutApp,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                '© 2025 Edurium',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ],
        );
      },
    );
  }
  
  // 打開URL
  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
  
  // 解碼base64圖片
  Uint8List _decodeBase64Image(String base64String) {
    try {
      final encodedStr = base64String.split(',')[1];
      return base64Decode(encodedStr);
    } catch (e) {
      return Uint8List(0);
    }
  }

  // 顯示顏色選擇器對話框
  void _showColorPickerModal(BuildContext context, String colorType) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    // 獲取當前顏色
    Color currentColor;
    String title;
    
    switch (colorType) {
      case 'primary':
        currentColor = themeProvider.primaryColor;
        title = context.l10n.primaryColor;
        break;
      case 'secondary':
        currentColor = themeProvider.secondaryColor;
        title = context.l10n.secondaryColor;
        break;
      case 'accent':
        currentColor = themeProvider.accentColor;
        title = context.l10n.accentColor;
        break;
      default:
        currentColor = themeProvider.primaryColor;
        title = context.l10n.primaryColor;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: currentColor,
                        onColorChanged: (color) {
                          setState(() {
                            currentColor = color;
                          });
                        },
                        pickerAreaHeightPercent: 0.8,
                        enableAlpha: false,
                        displayThumbColor: true,
                        paletteType: PaletteType.hsvWithHue,
                        labelTypes: const [ColorLabelType.rgb, ColorLabelType.hex],
                      ),
                    ),
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(context.l10n.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // 保存顏色設置
                          switch (colorType) {
                            case 'primary':
                              themeProvider.setPrimaryColor(currentColor);
                              break;
                            case 'secondary':
                              themeProvider.setSecondaryColor(currentColor);
                              break;
                            case 'accent':
                              themeProvider.setAccentColor(currentColor);
                              break;
                          }
                          
                          Navigator.pop(context);
                          
                          // 顯示提示
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.colorsReset),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(context.l10n.save),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 在設置頁面的_buildCustomizationSection函數中添加顏色設置卡片
  Widget _buildCustomizationSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            context.l10n.customization,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // 顏色設置卡片
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // 主題選擇
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: Text(context.l10n.theme),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showThemeModal(context),
              ),
              
              const Divider(height: 1),
              
              // 主要顏色選擇
              ListTile(
                leading: Icon(Icons.circle, color: themeProvider.primaryColor),
                title: Text(context.l10n.primaryColor),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showColorPickerModal(context, 'primary'),
              ),
              
              const Divider(height: 1),
              
              // 次要顏色選擇
              ListTile(
                leading: Icon(Icons.circle, color: themeProvider.secondaryColor),
                title: Text(context.l10n.secondaryColor),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showColorPickerModal(context, 'secondary'),
              ),
              
              const Divider(height: 1),
              
              // 強調顏色選擇
              ListTile(
                leading: Icon(Icons.circle, color: themeProvider.accentColor),
                title: Text(context.l10n.accentColor),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showColorPickerModal(context, 'accent'),
              ),
              
              const Divider(height: 1),
              
              // 重置顏色
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(context.l10n.resetColors),
                onTap: () {
                  themeProvider.resetColors();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.colorsReset),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // 其他個性化設置...
        
      ],
    );
  }

  // 用戶信息部分
  Widget _buildUserInfoSection(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            context.l10n.profile,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    user?.name?.isNotEmpty == true ? user!.name![0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? context.l10n.notSet,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? context.l10n.emailNotSet,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // 跳轉到編輯個人資料頁面
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 區域設定部分
  Widget _buildLocalizationSection(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            context.l10n.localization,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // 語言設定
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(context.l10n.language),
                subtitle: Text(localeProvider.localeName),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLanguageModal(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 無障礙設定部分
  Widget _buildAccessibilitySection(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            context.l10n.accessibility,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // 字體大小設定
              ListTile(
                leading: const Icon(Icons.format_size),
                title: Text(context.l10n.fontSize),
                subtitle: Text(fontSizeProvider.getFontSizeName(context)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showFontSizeModal(context),
              ),
              
              const Divider(height: 1),
              
              // 高對比度模式
              SwitchListTile(
                secondary: const Icon(Icons.contrast),
                title: Text(context.l10n.highContrast),
                value: accessibilityProvider.isHighContrast,
                onChanged: (value) {
                  accessibilityProvider.setHighContrast(value);
                },
              ),
              
              const Divider(height: 1),
              
              // 粗體文字
              SwitchListTile(
                secondary: const Icon(Icons.format_bold),
                title: Text(context.l10n.boldText),
                value: accessibilityProvider.isBoldText,
                onChanged: (value) {
                  accessibilityProvider.setBoldText(value);
                },
              ),
              
              const Divider(height: 1),
              
              // 減少動畫
              SwitchListTile(
                secondary: const Icon(Icons.animation),
                title: Text(context.l10n.reduceAnimation),
                value: accessibilityProvider.isReduceAnimation,
                onChanged: (value) {
                  accessibilityProvider.setReduceAnimation(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 關於部分
  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            context.l10n.about,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // 關於應用
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(context.l10n.aboutApp),
                subtitle: Text('${AppConstants.appName} v${AppConstants.appVersion}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAboutDialog(context),
              ),
              
              const Divider(height: 1),
              
              // 隱私政策
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(context.l10n.privacyPolicy),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // 打開隱私政策頁面
                  // 實際開發時應替換為實際的URL
                  _launchUrl('https://example.com/privacy');
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }
}