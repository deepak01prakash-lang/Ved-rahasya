import 'package:flutter/material.dart';

void main() => runApp(const VedRahasyaApp());

class VedRahasyaApp extends StatelessWidget {
  const VedRahasyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const saffron = Color(0xFFB86B1B);
    return MaterialApp(
      title: 'वेद रहस्य | Ved Rahasya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: saffron,
          primary: saffron,
          secondary: const Color(0xFFD5A447),
          surface: const Color(0xFFFFF8E9),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8E9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF492A17),
          foregroundColor: Color(0xFFFFE4AE),
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String language = 'हिंदी';
  int japCount = 0;
  int tab = 0;
  final Set<String> bookmarks = {};

  String tr(String hi, String sa, String en) =>
      language == 'English' ? en : language == 'संस्कृत' ? sa : hi;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      _section('चारों वेद', 'The Four Vedas', 'चत्वारो वेदाः',
          'ऋग्वेद, यजुर्वेद, सामवेद और अथर्ववेद भारतीय वैदिक परंपरा के चार प्रमुख वेद हैं।',
          'The Rigveda, Yajurveda, Samaveda and Atharvaveda are the four Vedas.',
          'ऋग्वेदः यजुर्वेदः सामवेदः अथर्ववेदः।'),
      _section('भगवद्गीता', 'Bhagavad Gita', 'श्रीमद्भगवद्गीता',
          'भगवद्गीता के 18 अध्याय कर्म, ज्ञान, भक्ति और आत्मसंयम का मार्ग बताते हैं।',
          'The 18 chapters explore action, knowledge, devotion and self-discipline.',
          'कर्मयोगः ज्ञानयोगः भक्तियोगश्च।'),
      _section('उपनिषद', 'Upanishads', 'उपनिषदः',
          'उपनिषद आत्मा, ब्रह्म और परम सत्य से जुड़े गहन दार्शनिक प्रश्नों पर विचार करते हैं।',
          'The Upanishads explore the Self, Brahman and ultimate reality.',
          'आत्मा ब्रह्म च।'),
      _section('मंत्र एवं जाप', 'Mantras & Japa', 'मन्त्राः',
          'मंत्र जाप को शांत मन और एकाग्रता के साथ करें। उच्चारण और परंपरा के लिए प्रमाणिक स्रोत देखें।',
          'Practice mantra repetition with a calm and focused mind.',
          'ॐ नमः शिवाय।'),
      _section('ध्यान साधना', 'Meditation', 'ध्यानम्',
          'आराम से बैठें, सहज श्वास लें और कुछ मिनट अपने मन को शांत रखने का अभ्यास करें।',
          'Sit comfortably, breathe naturally and practise calm awareness.',
          'शान्तिः।'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('॥ वेद रहस्य ॥', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('VED RAHASYA', style: TextStyle(fontSize: 11, letterSpacing: 2)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (v) => setState(() => language = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'हिंदी', child: Text('हिंदी')),
              PopupMenuItem(value: 'संस्कृत', child: Text('संस्कृत')),
              PopupMenuItem(value: 'English', child: Text('English')),
            ],
          ),
        ],
      ),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'होम'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'वेद'),
          NavigationDestination(icon: Icon(Icons.auto_stories), label: 'गीता'),
          NavigationDestination(icon: Icon(Icons.self_improvement), label: 'उपनिषद'),
          NavigationDestination(icon: Icon(Icons.spa), label: 'साधना'),
        ],
      ),
    );
  }

  Widget _home() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF492A17), Color(0xFF8C4D1D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ॐ', style: TextStyle(fontSize: 42, color: Color(0xFFFFD47C))),
            Text(tr('अपने भीतर के ज्ञान को पहचानें।', 'आत्मानं विद्धि।', 'Discover the wisdom within.'),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('वेद • उपनिषद • गीता • मंत्र • ध्यान',
                style: TextStyle(color: Color(0xFFFFE4AE))),
          ]),
        ),
        const SizedBox(height: 18),
        Text(tr('आज का श्लोक', 'अद्यतनः श्लोकः', 'Verse of the day'),
            style: Theme.of(context).textTheme.titleLarge),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Text('कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, height: 1.7, color: Color(0xFF754414))),
              const SizedBox(height: 8),
              const Text('श्रीमद्भगवद्गीता 2.47', style: TextStyle(color: Colors.brown)),
              const Divider(),
              Text(tr('अर्थ: तुम्हारा अधिकार कर्म करने में है, उसके फलों में नहीं।',
                  'कर्मणि एव तव अधिकारः, फलेषु न कदाचन।',
                  'Your focus is on action, not on its fruits.')),
              TextButton.icon(
                onPressed: () => setState(() {
                  bookmarks.contains('gita247') ? bookmarks.remove('gita247') : bookmarks.add('gita247');
                }),
                icon: Icon(bookmarks.contains('gita247') ? Icons.bookmark : Icons.bookmark_border),
                label: Text(bookmarks.contains('gita247') ? 'सहेजा गया' : 'बुकमार्क करें'),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        Text(tr('धर्म ज्ञान के विभाग', 'धर्मज्ञानविभागाः', 'Explore knowledge'),
            style: Theme.of(context).textTheme.titleLarge),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            _tile('चारों वेद', Icons.menu_book, 1),
            _tile('भगवद्गीता', Icons.auto_stories, 2),
            _tile('उपनिषद', Icons.library_books, 3),
            _tile('मंत्र एवं जाप', Icons.spa, 4),
          ],
        ),
        const SizedBox(height: 18),
        Text(tr('दैनिक मंत्र जाप', 'दैनिक मन्त्रजपः', 'Daily mantra counter'),
            style: Theme.of(context).textTheme.titleLarge),
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const Text('ॐ नमः शिवाय', style: TextStyle(fontSize: 24, color: Color(0xFF8C4D1D), fontWeight: FontWeight.bold)),
            Text('$japCount', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const Text('आज का जाप'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              OutlinedButton(onPressed: () => setState(() => japCount = 0), child: const Text('रीसेट')),
              FilledButton.icon(onPressed: () => setState(() => japCount++), icon: const Icon(Icons.add), label: const Text('एक जाप')),
            ]),
          ]),
        )),
      ],
    );
  }

  Widget _tile(String title, IconData icon, int destination) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () => setState(() => tab = destination),
    child: Card(child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: const Color(0xFFB86B1B), size: 30),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    )),
  );

  Widget _section(String hiTitle, String enTitle, String saTitle,
      String hi, String en, String sa) {
    final title = language == 'English' ? enTitle : language == 'संस्कृत' ? saTitle : hiTitle;
    final body = language == 'English' ? en : language == 'संस्कृत' ? sa : hi;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF754414))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Text(body, style: const TextStyle(fontSize: 17, height: 1.7)))),
      const SizedBox(height: 12),
      const Text('अध्ययन सामग्री', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const Card(child: ListTile(leading: Icon(Icons.article_outlined), title: Text('परिचय'), subtitle: Text('मूल पाठ और प्रमाणिक संदर्भ अगले चरण में जोड़े जाएँगे।'))),
      const Card(child: ListTile(leading: Icon(Icons.translate), title: Text('अनुवाद एवं व्याख्या'), subtitle: Text('हिंदी • संस्कृत • English'))),
      const Card(child: ListTile(leading: Icon(Icons.bookmark_border), title: Text('बुकमार्क'), subtitle: Text('पसंदीदा सामग्री सहेजने की सुविधा'))),
    ]);
  }
}
