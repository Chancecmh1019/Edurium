import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edurium/providers/theme_provider.dart';
import 'package:edurium/providers/locale_provider.dart';
import 'package:edurium/widgets/common/app_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 激勵語錄卡片
class MotivationQuotesCard extends StatefulWidget {
  const MotivationQuotesCard({super.key});

  @override
  State<MotivationQuotesCard> createState() => _MotivationQuotesCardState();
}

class _MotivationQuotesCardState extends State<MotivationQuotesCard> {
  late String _currentQuote;
  late String _currentAuthor;
  
  final List<Map<String, String>> _chineseQuotes = [
    {
      'quote': '教育的目的不是填滿一桶水，而是點燃一把火。',
      'author': '葉芝',
    },
    {
      'quote': '學習不是為了學而學，學習是為了做生活的主宰。',
      'author': '約翰•杜威',
    },
    {
      'quote': '世上無難事，只怕有心人。',
      'author': '中國諺語',
    },
    {
      'quote': '天才是百分之一的靈感加上百分之九十九的汗水。',
      'author': '愛迪生',
    },
    {
      'quote': '書籍是人類進步的階梯。',
      'author': '高爾基',
    },
    {
      'quote': '行動是治愈恐懼的良藥，而猶豫、拖延將不斷滋養恐懼。',
      'author': '羅素',
    },
    {
      'quote': '立志是事業的大門，工作是登堂入室的旅程。',
      'author': '愛默生',
    },
    {
      'quote': '一日之計在於晨，一年之計在於春。',
      'author': '中國諺語',
    },
    {
      'quote': '不積跬步，無以至千里；不積小流，無以成江海。',
      'author': '荀子',
    },
    {
      'quote': '寶劍鋒從磨礪出，梅花香自苦寒來。',
      'author': '中國諺語',
    },
    {
      'quote': '千里之行，始於足下。',
      'author': '老子',
    },
    {
      'quote': '三人行，必有我師焉。',
      'author': '孔子',
    },
    {
      'quote': '學而不思則罔，思而不學則殆。',
      'author': '孔子',
    },
    {
      'quote': '知識就是力量。',
      'author': '培根',
    },
    {
      'quote': '今天做的事不要拖到明天。',
      'author': '富蘭克林',
    },
    {
      'quote': '成功的秘訣在於堅持最終目標，並為達成該目標找到方法。',
      'author': '富蘭克林',
    },
    {
      'quote': '好的開始是成功的一半。',
      'author': '亞里士多德',
    },
    {
      'quote': '志不強者智不達。',
      'author': '墨子',
    },
    {
      'quote': '敏而好學，不恥下問。',
      'author': '孔子',
    },
    {
      'quote': '讀書破萬卷，下筆如有神。',
      'author': '杜甫',
    },
  ];
  
  final List<Map<String, String>> _englishQuotes = [
    {
      'quote': 'The purpose of education is not to fill a bucket, but to light a fire.',
      'author': 'William Butler Yeats',
    },
    {
      'quote': 'Education is not preparation for life; education is life itself.',
      'author': 'John Dewey',
    },
    {
      'quote': 'The only person who is educated is the one who has learned how to learn.',
      'author': 'Carl Rogers',
    },
    {
      'quote': 'Genius is one percent inspiration and ninety-nine percent perspiration.',
      'author': 'Thomas Edison',
    },
    {
      'quote': 'Books are the ladder of human progress.',
      'author': 'Maxim Gorky',
    },
    {
      'quote': 'Action is the cure for fear. Hesitation and postponement only nourish fear.',
      'author': 'Bertrand Russell',
    },
    {
      'quote': 'Determination is the gateway to success, and work is the journey to mastery.',
      'author': 'Ralph Waldo Emerson',
    },
    {
      'quote': 'The journey of a thousand miles begins with a single step.',
      'author': 'Lao Tzu',
    },
    {
      'quote': 'The expert in anything was once a beginner.',
      'author': 'Helen Hayes',
    },
    {
      'quote': 'Success is the sum of small efforts, repeated day in and day out.',
      'author': 'Robert Collier',
    },
    {
      'quote': "The more that you read, the more things you will know. The more that you learn, the more places you'll go.",
      'author': 'Dr. Seuss',
    },
    {
      'quote': 'Education is the most powerful weapon which you can use to change the world.',
      'author': 'Nelson Mandela',
    },
    {
      'quote': 'The beautiful thing about learning is that no one can take it away from you.',
      'author': 'B.B. King',
    },
    {
      'quote': 'Knowledge is power.',
      'author': 'Francis Bacon',
    },
    {
      'quote': 'Never put off till tomorrow what you can do today.',
      'author': 'Benjamin Franklin',
    },
    {
      'quote': 'The secret of success is constancy to purpose.',
      'author': 'Benjamin Disraeli',
    },
    {
      'quote': 'Well begun is half done.',
      'author': 'Aristotle',
    },
    {
      'quote': 'An investment in knowledge pays the best interest.',
      'author': 'Benjamin Franklin',
    },
    {
      'quote': 'Learn as if you will live forever, live like you will die tomorrow.',
      'author': 'Mahatma Gandhi',
    },
    {
      'quote': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _loadQuoteOfTheDay();
  }
  
  Future<void> _loadQuoteOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('lastQuoteDate');
    final today = DateTime.now().toString().split(' ')[0]; // 只取日期部分
    
    if (lastDate != today) {
      // 如果是新的一天，選擇新的語錄
      await _updateQuoteAndSave(today);
    } else {
      // 如果是同一天，載入已保存的語錄
      final savedQuote = prefs.getString('currentQuote');
      final savedAuthor = prefs.getString('currentAuthor');
      
      if (savedQuote != null && savedAuthor != null) {
        setState(() {
          _currentQuote = savedQuote;
          _currentAuthor = savedAuthor;
        });
      } else {
        // 以防萬一沒有保存過
        await _updateQuoteAndSave(today);
      }
    }
  }
  
  Future<void> _updateQuoteAndSave(String today) async {
    final random = Random();
    final quotes = _getQuotesByLocale();
    final index = random.nextInt(quotes.length);
    
    final newQuote = quotes[index]['quote']!;
    final newAuthor = quotes[index]['author']!;
    
    setState(() {
      _currentQuote = newQuote;
      _currentAuthor = newAuthor;
    });
    
    // 保存今日語錄和日期
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastQuoteDate', today);
    await prefs.setString('currentQuote', newQuote);
    await prefs.setString('currentAuthor', newAuthor);
  }
  
  Future<void> _updateQuote() async {
    final random = Random();
    final quotes = _getQuotesByLocale();
    final index = random.nextInt(quotes.length);
    
    final newQuote = quotes[index]['quote']!;
    final newAuthor = quotes[index]['author']!;
    
    setState(() {
      _currentQuote = newQuote;
      _currentAuthor = newAuthor;
    });
    
    // 更新保存的語錄
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentQuote', newQuote);
    await prefs.setString('currentAuthor', newAuthor);
  }
  
  List<Map<String, String>> _getQuotesByLocale() {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'zh' ? _chineseQuotes : _englishQuotes;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    
    return AppCard(
      titleIcon: Icons.format_quote,
      title: localeProvider.locale.languageCode == 'zh' ? '今日勵志' : 'Quote of the Day',
      actionButton: IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: localeProvider.locale.languageCode == 'zh' ? '更換一則' : 'Get another quote',
        onPressed: () => _updateQuote(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Text(
              '"$_currentQuote"',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: isDarkMode ? Colors.white : Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— $_currentAuthor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}