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
    if (hiTitle == 'भगवद्गीता') return const GitaLibraryPage();

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


class GitaLibraryPage extends StatelessWidget {
  const GitaLibraryPage({super.key});

  static const chapters = <({int number, String title, String transliteration, int verses, String summary, String topics})>[
    (number: 1, title: 'अर्जुनविषादयोग', transliteration: 'Arjuna Vishada Yoga', verses: 47, summary: 'अर्जुन का विषाद और धर्म-संकट', topics: 'कर्तव्य-संघर्ष • करुणा • मोह • मार्गदर्शन की आवश्यकता'),
    (number: 2, title: 'सांख्ययोग', transliteration: 'Sankhya Yoga', verses: 72, summary: 'आत्मा का स्वरूप, स्थितप्रज्ञता और कर्मयोग की नींव', topics: 'आत्मा • देह • समत्व • निष्काम कर्म • स्थितप्रज्ञ'),
    (number: 3, title: 'कर्मयोग', transliteration: 'Karma Yoga', verses: 43, summary: 'कर्तव्य-कर्म, यज्ञभाव और लोकसंग्रह', topics: 'कर्म • अकर्म • यज्ञ • स्वधर्म • लोकसंग्रह'),
    (number: 4, title: 'ज्ञानकर्मसंन्यासयोग', transliteration: 'Jnana Karma Sannyasa Yoga', verses: 42, summary: 'अवतार, ज्ञान और कर्म की सही समझ', topics: 'अवतार-तत्त्व • ज्ञानयज्ञ • गुरु • कर्म-अकर्म'),
    (number: 5, title: 'कर्मसंन्यासयोग', transliteration: 'Karma Sannyasa Yoga', verses: 29, summary: 'कर्मयोग और संन्यास का संबंध', topics: 'संन्यास • अनासक्ति • समदृष्टि • शांति'),
    (number: 6, title: 'आत्मसंयमयोग', transliteration: 'Atma Samyama Yoga', verses: 47, summary: 'ध्यान, मन का संयम और योगाभ्यास', topics: 'ध्यान • अभ्यास • वैराग्य • मन • योगभ्रष्ट'),
    (number: 7, title: 'ज्ञानविज्ञानयोग', transliteration: 'Jnana Vijnana Yoga', verses: 30, summary: 'ईश्वर का ज्ञान और प्रकृति के आयाम', topics: 'अपरा-प्रकृति • परा-प्रकृति • माया • भक्ति'),
    (number: 8, title: 'अक्षरब्रह्मयोग', transliteration: 'Akshara Brahma Yoga', verses: 28, summary: 'ब्रह्म, अध्यात्म, स्मरण और अंतिम समय का चिंतन', topics: 'ब्रह्म • अध्यात्म • स्मरण • साधना • गति'),
    (number: 9, title: 'राजविद्याराजगुह्ययोग', transliteration: 'Raja Vidya Raja Guhya Yoga', verses: 34, summary: 'भक्ति का सर्वोच्च और गोपनीय ज्ञान', topics: 'राजविद्या • ईश्वर की व्यापकता • अनन्य भक्ति'),
    (number: 10, title: 'विभूतियोग', transliteration: 'Vibhuti Yoga', verses: 42, summary: 'जगत में ईश्वर की विभूतियों का वर्णन', topics: 'विभूति • ऐश्वर्य • ध्यान के प्रतीक'),
    (number: 11, title: 'विश्वरूपदर्शनयोग', transliteration: 'Vishvarupa Darshana Yoga', verses: 55, summary: 'अर्जुन को विराट विश्वरूप का दर्शन', topics: 'दिव्यदृष्टि • काल • विराट रूप • विस्मय'),
    (number: 12, title: 'भक्तियोग', transliteration: 'Bhakti Yoga', verses: 20, summary: 'भक्ति के स्वरूप और प्रिय भक्त के गुण', topics: 'सगुण-निर्गुण उपासना • श्रद्धा • करुणा • समत्व'),
    (number: 13, title: 'क्षेत्रक्षेत्रज्ञविभागयोग', transliteration: 'Kshetra Kshetrajna Vibhaga Yoga', verses: 34, summary: 'शरीर, क्षेत्रज्ञ और ज्ञान के तत्व', topics: 'क्षेत्र • क्षेत्रज्ञ • प्रकृति • पुरुष • ज्ञान'),
    (number: 14, title: 'गुणत्रयविभागयोग', transliteration: 'Gunatraya Vibhaga Yoga', verses: 27, summary: 'सत्त्व, रजस और तमस का विवेचन', topics: 'तीन गुण • गुणों के लक्षण • गुणातीत अवस्था'),
    (number: 15, title: 'पुरुषोत्तमयोग', transliteration: 'Purushottama Yoga', verses: 20, summary: 'संसार-वृक्ष, जीव और पुरुषोत्तम का विवेचन', topics: 'अश्वत्थ वृक्ष • जीव • परमात्मा • पुरुषोत्तम'),
    (number: 16, title: 'दैवासुरसम्पद्विभागयोग', transliteration: 'Daivasura Sampad Vibhaga Yoga', verses: 24, summary: 'दैवी और आसुरी प्रवृत्तियों का अंतर', topics: 'अभय • सत्य • अहिंसा • दंभ • क्रोध • आचरण'),
    (number: 17, title: 'श्रद्धात्रयविभागयोग', transliteration: 'Shraddhatraya Vibhaga Yoga', verses: 28, summary: 'तीन गुणों के अनुसार श्रद्धा, आहार और यज्ञ', topics: 'श्रद्धा • आहार • यज्ञ • तप • दान • ॐ तत् सत्'),
    (number: 18, title: 'मोक्षसंन्यासयोग', transliteration: 'Moksha Sannyasa Yoga', verses: 78, summary: 'त्याग, स्वधर्म, ज्ञान, भक्ति और मोक्ष का समन्वय', topics: 'त्याग • कर्म के कारण • स्वधर्म • शरणागति • निष्कर्ष'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text('श्रीमद्भगवद्गीता', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF754414), fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('महाभारत के भीष्मपर्व में स्थित श्रीकृष्ण और अर्जुन का संवाद। अध्याय चुनकर क्रमबद्ध अध्ययन आरम्भ करें।', style: TextStyle(fontSize: 15, height: 1.6)),
        const SizedBox(height: 14),
        Card(
          color: const Color(0xFFFFEBCB),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('18 अध्याय  •  700 श्लोक', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF754414))),
              SizedBox(height: 6),
              Text('पारंपरिक 700-श्लोक पाठ-क्रम के अनुसार। कुछ संस्करणों में अध्याय 13 की गणना के कारण 701 की संख्या भी मिलती है; पाठ-संस्करण का उल्लेख अध्ययन सामग्री में किया जाएगा।', style: TextStyle(height: 1.5)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        const Text('अध्यायवार अध्ययन', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...chapters.map((chapter) => Card(
          margin: const EdgeInsets.only(bottom: 9),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            leading: CircleAvatar(backgroundColor: const Color(0xFFFFEBCB), foregroundColor: const Color(0xFF754414), child: Text('${chapter.number}')),
            title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${chapter.transliteration}\n${chapter.summary}', maxLines: 3, overflow: TextOverflow.ellipsis),
            isThreeLine: true,
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${chapter.verses}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const Text('श्लोक', style: TextStyle(fontSize: 11)),
            ]),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GitaChapterPage(chapter: chapter))),
          ),
        )),
        const SizedBox(height: 8),
        const Text('पाठ-संदर्भ', style: TextStyle(fontWeight: FontWeight.bold)),
        const Text('श्लोक-संख्या और पाठभेद अलग-अलग परंपरागत संस्करणों में भिन्न हो सकते हैं। इस ऐप में प्रत्येक श्लोक के साथ प्रयुक्त संस्करण और स्रोत स्पष्ट रूप से दिखाए जाएँगे।', style: TextStyle(height: 1.5)),
      ],
    );
  }
}

class GitaChapterPage extends StatelessWidget {
  const GitaChapterPage({super.key, required this.chapter});
  final ({int number, String title, String transliteration, int verses, String summary, String topics}) chapter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('अध्याय ${chapter.number}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(chapter.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF754414), fontWeight: FontWeight.bold)),
        Text(chapter.transliteration, style: const TextStyle(color: Colors.brown)),
        const SizedBox(height: 14),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('अध्याय का सार', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          const SizedBox(height: 8),
          Text(chapter.summary, style: const TextStyle(fontSize: 17, height: 1.6)),
          const SizedBox(height: 14),
          Text('श्लोक: ${chapter.verses}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(height: 22),
          const Text('मुख्य विषय', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(chapter.topics, style: const TextStyle(height: 1.6)),
        ]))),
        const SizedBox(height: 14),
        const Text('इस अध्याय का अध्ययन कैसे करें?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('पहले अध्याय का सार पढ़ें। फिर श्लोकों को क्रम से पढ़ते हुए मूल संस्कृत पाठ, पदच्छेद, शब्दार्थ, अनुवाद और भावार्थ का अध्ययन करें। जहाँ अलग-अलग आचार्यों के भाष्य उपलब्ध हों, वहाँ उन्हें अलग-अलग मत के रूप में पढ़ें।', style: TextStyle(height: 1.6)))),
        const SizedBox(height: 12),
        const Card(child: ListTile(leading: Icon(Icons.menu_book), title: Text('श्लोक-दर-श्लोक सामग्री'), subtitle: Text('प्रमाणित मूलपाठ, पदच्छेद, शब्दार्थ और संदर्भित हिंदी व्याख्या अगले कंटेंट पैक में जोड़ी जाएगी। अभी अप्रमाणित श्लोक-सामग्री नहीं दिखाई जाती।'))),
      ]),
    );
  }
}
