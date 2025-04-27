import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  List<OnboardingItem> _getOnboardingItems(bool isZh) {
    return [
      OnboardingItem(
        title: isZh ? '歡迎使用 Edurium' : 'Welcome to Edurium',
        description: isZh 
            ? '您的學習生活管理專家，協助您輕鬆追蹤學校生活的所有面向' 
            : 'Your learning life management expert, helping you easily track all aspects of school life',
        icon: Icons.school,
        color: Colors.blue,
      ),
      OnboardingItem(
        title: isZh ? '追蹤您的課表與教師' : 'Track Your Schedule & Teachers',
        description: isZh 
            ? '輕鬆查看課表、儲存教師聯絡資訊，讓您的學習更有條理' 
            : 'Easily view your schedule, save teacher contact information, and make your learning more organized',
        icon: Icons.calendar_today,
        color: Colors.green,
      ),
      OnboardingItem(
        title: isZh ? '管理考試與作業' : 'Manage Exams & Assignments',
        description: isZh 
            ? '透過行事曆追蹤考試和作業，從不錯過重要的學習任務' 
            : 'Track exams and assignments via calendar, never miss important learning tasks',
        icon: Icons.assignment,
        color: Colors.orange,
      ),
      OnboardingItem(
        title: isZh ? '分析成績表現' : 'Analyze Grade Performance',
        description: isZh 
            ? '記錄和分析您的學習成績，掌握自己的學習進度和表現' 
            : 'Record and analyze your grades, keep track of your learning progress and performance',
        icon: Icons.trending_up,
        color: Colors.purple,
      ),
      OnboardingItem(
        title: isZh ? '開始使用！' : 'Get Started!',
        description: isZh 
            ? '準備好開始使用 Edurium 提升您的學習效率了嗎？' 
            : 'Ready to start using Edurium to improve your learning efficiency?',
        icon: Icons.rocket_launch,
        color: Colors.red,
      ),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isZh = localeProvider.locale.languageCode == 'zh';
    final onboardingItems = _getOnboardingItems(isZh);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark 
              ? Brightness.light 
              : Brightness.dark,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            child: Text(
              isZh ? '跳過' : 'Skip',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 頁面指示器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(
                onboardingItems.length,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage >= index 
                          ? onboardingItems[_currentPage].color
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 主要內容
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingItems.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final item = onboardingItems[index];
                return OnboardingPage(item: item);
              },
            ),
          ),
          
          // 底部導航
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 上一頁按鈕
                _currentPage > 0
                    ? IconButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                        tooltip: isZh ? '上一頁' : 'Previous',
                      )
                    : const SizedBox(width: 48),
                
                // 下一頁或開始按鈕
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < onboardingItems.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onboardingItems[_currentPage].color,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _currentPage < onboardingItems.length - 1
                        ? (isZh ? '繼續' : 'Continue')
                        : (isZh ? '開始使用' : 'Get Started'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  
  const OnboardingPage({
    Key? key,
    required this.item,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 圖標
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 80,
              color: item.color,
            ),
          ),
          const SizedBox(height: 40),
          
          // 標題
          Text(
            item.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // 描述
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  
  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
} 