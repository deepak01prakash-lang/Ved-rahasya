import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VedRahasyaApp());
}

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
  bool japLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDailyJap();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadDailyJap() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('jap_date');
    final count = savedDate == _todayKey() ? (prefs.getInt('jap_count') ?? 0) : 0;
    if (!mounted) return;
    setState(() {
      japCount = count;
      japLoaded = true;
    });
    if (savedDate != _todayKey()) {
      await prefs.setString('jap_date', _todayKey());
      await prefs.setInt('jap_count', 0);
    }
  }

  Future<void> _changeJap(int value) async {
    setState(() => japCount = value < 0 ? 0 : value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jap_date', _todayKey());
    await prefs.setInt('jap_count', japCount);
  }

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
          IconButton(
            tooltip: 'धर्म और सनातन खोजें',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DharmaSearchPage()),
            ),
          ),
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
    final categories = <Map<String, dynamic>>[
      {'title': 'चारों वेद', 'subtitle': 'ऋग् • यजुः • साम • अथर्व', 'icon': Icons.menu_book_rounded, 'tab': 1},
      {'title': 'भगवद्गीता', 'subtitle': '18 अध्याय • कर्म, ज्ञान, भक्ति', 'icon': Icons.auto_stories_rounded, 'tab': 2},
      {'title': 'उपनिषद', 'subtitle': 'आत्मा और ब्रह्म का ज्ञान', 'icon': Icons.self_improvement_rounded, 'tab': 3},
      {'title': 'मंत्र एवं जाप', 'subtitle': 'मंत्र, साधना और एकाग्रता', 'icon': Icons.spa_rounded, 'tab': 4},
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DharmaSearchPage()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8D7BF)),
            ),
            child: const Row(children: [
              Icon(Icons.search, color: Color(0xFF8B4D20)),
              SizedBox(width: 10),
              Expanded(child: Text('मंत्र, व्रत, पूजा-विधि या अपना सवाल खोजें',
                style: TextStyle(color: Color(0xFF806B58), fontSize: 13))),
              Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF8B4D20)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [Color(0xFF24150F), Color(0xFF633718), Color(0xFF9B5B25)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [BoxShadow(color: Color(0x3324150F), blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: const Color(0x33FFD98A), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.self_improvement_rounded, color: Color(0xFFFFD98A), size: 30),
              ),
              const Spacer(),
              const Text('ज्ञान • साधना • संस्कृति', style: TextStyle(color: Color(0xFFFFE5B5), fontSize: 11, letterSpacing: 1)),
            ]),
            const SizedBox(height: 22),
            const Text('॥ ॐ ॥', style: TextStyle(color: Color(0xFFFFD98A), fontSize: 34, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('सनातन ज्ञान की\nएक क्रमबद्ध यात्रा', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('वेदों से उपनिषदों तक, गीता से दर्शन और साधना तक — अध्ययन करें मूल संदर्भों के साथ।',
              style: TextStyle(color: Color(0xFFFFEBD0), height: 1.55, fontSize: 14)),
            const SizedBox(height: 18),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFD98A), foregroundColor: const Color(0xFF382012)),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GranthaLibraryPage())),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('सम्पूर्ण ग्रंथालय देखें'),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        Row(children: [
          const Expanded(child: Text('ज्ञान के प्रमुख विभाग', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF422716)))),
          Text('LIBRARY', style: TextStyle(color: Colors.brown.shade400, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 11, mainAxisSpacing: 11, childAspectRatio: 1.27,
          ),
          itemBuilder: (context, index) {
            final item = categories[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => tab = item['tab'] as int),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: const Color(0xFFFFEBCB), borderRadius: BorderRadius.circular(14)),
                      child: Icon(item['icon'] as IconData, color: const Color(0xFF8B4D20), size: 24),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF422716))),
                      const SizedBox(height: 3),
                      Text(item['subtitle'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, height: 1.3, color: Colors.brown.shade500)),
                    ]),
                  ]),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        const Text('आज का श्लोक', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF422716))),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          color: const Color(0xFFFFF0D7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFEBD5B2))),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              const Text('कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 17, height: 1.8, color: Color(0xFF633718), fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('श्रीमद्भगवद्गीता 2.47', style: TextStyle(fontSize: 12, color: Colors.brown)),
              const Divider(height: 22),
              const Text('अर्थ: तुम्हारा अधिकार कर्म करने में है, उसके फलों में नहीं।', textAlign: TextAlign.center, style: TextStyle(height: 1.5)),
              TextButton.icon(
                onPressed: () => setState(() {
                  bookmarks.contains('gita247') ? bookmarks.remove('gita247') : bookmarks.add('gita247');
                }),
                icon: Icon(bookmarks.contains('gita247') ? Icons.bookmark : Icons.bookmark_border),
                label: Text(bookmarks.contains('gita247') ? 'बुकमार्क किया गया' : 'श्लोक सहेजें'),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 22),
        Row(children: [
          const Expanded(child: Text('दैनिक साधना', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF422716)))),
          const Text('JAPA COUNTER', style: TextStyle(color: Color(0xFF9B744B), fontSize: 10, letterSpacing: 1.2)),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(color: const Color(0xFFFFEBCB), borderRadius: BorderRadius.circular(17)),
              child: const Icon(Icons.spa_rounded, color: Color(0xFF8B4D20), size: 30),
            ),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ॐ नमः शिवाय', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF633718))),
              Text(japLoaded ? '$japCount जाप आज' : 'गिनती लोड हो रही है…',
                style: TextStyle(color: Colors.brown.shade500, fontSize: 12)),
            ])),
            IconButton(onPressed: () => _changeJap(0), tooltip: 'रीसेट', icon: const Icon(Icons.refresh)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF754414), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 15)),
              onPressed: japLoaded ? () => _changeJap(japCount + 1) : null,
              child: const Text('+1 जाप'),
            ),
          ]),
        ),
        const SizedBox(height: 18),
        Card(
          elevation: 0,
          color: const Color(0xFF492A17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
            leading: const Icon(Icons.account_balance_rounded, color: Color(0xFFFFD98A), size: 30),
            title: const Text('महाग्रंथ एवं भारतीय दर्शन', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('रामायण • महाभारत • पुराण • योग • वेदान्त', style: TextStyle(color: Color(0xFFFFE5B5), fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFFD98A), size: 16),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GranthaLibraryPage())),
          ),
        ),
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
    final List<Map<String, String>> lessons = switch (hiTitle) {
      'चारों वेद' => [
        {'title':'वेद-साहित्य की रचना', 'body':'वैदिक साहित्य को समझने के लिए केवल संहिता पढ़ना पर्याप्त नहीं। परंपरागत रूप से प्रत्येक वेद से सम्बद्ध संहिता, ब्राह्मण, आरण्यक और उपनिषद् साहित्य का अध्ययन किया जाता है। शाखाओं के अनुसार पाठ और परंपरा में अंतर हो सकता है।', 'source':'स्रोत: IGNCA, Vedic Heritage Portal — Introduction'},
        {'title':'ऋग्वेद', 'body':'ऋग्वेद मुख्यतः ऋचाओं और सूक्तों का संग्रह है। इसके दस मंडल हैं। अग्नि, इन्द्र, सोम, उषस् और अन्य देवताओं को सम्बोधित सूक्त वैदिक काव्य, यज्ञ, प्रकृति-अनुभव और दार्शनिक जिज्ञासा के अनेक आयाम दिखाते हैं। प्रत्येक सूक्त को उसके ऋषि, देवता और छन्द सहित पढ़ना उपयोगी है।', 'source':'स्रोत: Vedic Heritage Portal — Rigveda Samhita'},
        {'title':'यजुर्वेद', 'body':'यजुर्वेद यज्ञीय अनुष्ठानों में प्रयुक्त यजुस्-मंत्रों और विधियों से जुड़ा है। इसकी शुक्ल और कृष्ण परंपराएँ हैं; वाजसनेयी संहिता शुक्ल यजुर्वेद से तथा तैत्तिरीय संहिता कृष्ण यजुर्वेद से सम्बद्ध है। मंत्र को उसके अनुष्ठानिक प्रसंग से अलग करके अर्थ तय नहीं करना चाहिए।', 'source':'स्रोत: Vedic Heritage Portal — Yajurveda'},
        {'title':'सामवेद', 'body':'सामवेद का विशेष महत्व गेय मंत्रों और सामगान की परंपरा में है। इसके अनेक मंत्र ऋग्वेद से सम्बद्ध ऋचाओं पर आधारित हैं, पर उनका गायन-विन्यास और अनुष्ठानिक उपयोग विशिष्ट है। इसे केवल “संगीत की पुस्तक” कहना इसकी यज्ञीय और पाठ-परंपरा को अधूरा कर देता है।', 'source':'स्रोत: Vedic Heritage Portal — Samaveda'},
        {'title':'अथर्ववेद', 'body':'अथर्ववेद में शान्ति, आरोग्य, गृहस्थ जीवन, राजधर्म, सामाजिक जीवन, प्रार्थना और दार्शनिक चिंतन से जुड़े विविध सूक्त मिलते हैं। इसकी शौनक और पैप्पलाद जैसी पाठ-परंपराओं का उल्लेख मिलता है। किसी मंत्र का अर्थ उसके सूक्त और शाखा-संदर्भ के साथ समझना चाहिए।', 'source':'स्रोत: Vedic Heritage Portal — Atharvaveda'},
        {'title':'अध्ययन की विधि', 'body':'हर वैदिक पाठ के साथ मंडल/काण्ड, सूक्त, मंत्र संख्या, शाखा, उपलब्ध पाठ-संस्करण और अनुवादक का नाम दर्ज होना चाहिए। वैदिक स्वर-चिह्नों और उच्चारण को सामान्य संस्कृत उच्चारण से एक जैसा न मानें।', 'source':'स्रोत: IGNCA Vedic Heritage Portal; Sanskrit Documents'},
        {'title':'ब्राह्मण और आरण्यक ग्रंथ', 'body':'ब्राह्मण ग्रंथ वैदिक यज्ञों, अनुष्ठानों और उनसे जुड़े अर्थ-विवेचन को विस्तार से समझाते हैं। आरण्यक साहित्य में अनुष्ठान के प्रतीकात्मक और चिंतनपरक पक्ष पर बल मिलता है। इन श्रेणियों की सीमाएँ हर वेद में बिल्कुल एक जैसी नहीं हैं; कई आरण्यक और उपनिषद् किसी ब्राह्मण ग्रंथ से जुड़े हुए मिलते हैं।', 'source':'स्रोत: IGNCA Vedic Heritage Portal — Vedic literature structure'},
        {'title':'वेद की छह वेदांग विद्याएँ', 'body':'वेदों के अध्ययन में छह वेदांग सहायक माने गए हैं: शिक्षा—ध्वनि और उच्चारण; कल्प—अनुष्ठान-विधि; व्याकरण—शब्द-रचना; निरुक्त—वैदिक शब्दों की व्युत्पत्ति और अर्थ; छन्द—मंत्रों की मात्रिक/अक्षरिक संरचना; ज्योतिष—वैदिक अनुष्ठानों के काल-निर्णय से जुड़ी परंपरा। ये छहों अलग-अलग अध्ययन-विषय हैं।', 'source':'स्रोत: मुण्डकोपनिषद् 1.1.5; Vedic Heritage Portal — Introduction'},
        {'title':'शिक्षा और वैदिक स्वर', 'body':'शिक्षा वेदांग में वर्ण, स्वर, मात्रा, बल, साम और सन्तान जैसे उच्चारण-संबंधी विषयों का अध्ययन होता है। उदात्त, अनुदात्त और स्वरित जैसे वैदिक स्वर-चिह्न पाठ की परंपरा में महत्वपूर्ण हैं। सही पाठ के लिए किसी प्रमाणित शाखा और प्रशिक्षित वेदपाठी से सीखना चाहिए; केवल सामान्य लिप्यंतरण पर्याप्त नहीं।', 'source':'संदर्भ: तैत्तिरीयोपनिषद्, शिक्षावल्ली; प्रातिशाख्य परंपराएँ'},
        {'title':'कल्प: श्रौत, गृह्य और धर्मसूत्र', 'body':'कल्प वेदांग अनुष्ठान और आचार-विधियों के सूत्र-साहित्य से जुड़ा है। श्रौतसूत्र बड़े वैदिक यज्ञों, गृह्यसूत्र घरेलू संस्कारों और गृहस्थ अनुष्ठानों, जबकि धर्मसूत्र सामाजिक-नैतिक आचरण और कर्तव्यों पर चर्चा करते हैं। शुल्बसूत्र यज्ञ-वेदियों की रचना और मापन से जुड़े ज्यामितीय नियम भी देते हैं।', 'source':'संदर्भ: वैदिक कल्पसूत्र साहित्य; शुल्बसूत्र परंपरा'},
        {'title':'व्याकरण, निरुक्त और छन्द', 'body':'व्याकरण भाषा की संरचना और रूपों को समझने में मदद करता है। निरुक्त वैदिक शब्दों की व्युत्पत्ति तथा संदर्भगत अर्थ पर विचार करता है। छन्द मंत्रों की लयात्मक संरचना का अध्ययन है; गायत्री, त्रिष्टुप् और जगती इसके प्रसिद्ध छन्द हैं। किसी ऋचा का अर्थ समझने में शब्द, व्याकरण और छन्द—तीनों का योगदान हो सकता है।', 'source':'संदर्भ: यास्क का निरुक्त; पाणिनीय व्याकरण; पिङ्गल छन्दःशास्त्र'},
        {'title':'ज्योतिष वेदांग और काल-निर्णय', 'body':'वेदांग ज्योतिष का प्राचीन प्रयोजन वैदिक अनुष्ठानों के लिए समय और काल-चक्र का निर्धारण करना था। इसे आधुनिक खगोल-विज्ञान या जन्मकुंडली-आधारित फलादेश के समान नहीं मानना चाहिए। ऐतिहासिक ग्रंथों में प्रयुक्त गणना-पद्धति को उसके काल और उद्देश्य के संदर्भ में पढ़ना चाहिए।', 'source':'संदर्भ: वेदांग ज्योतिष; वैदिक काल-गणना का ऐतिहासिक अध्ययन'}
      ],
      'उपनिषद' => [
        {'title':'उपनिषद् क्या हैं?', 'body':'उपनिषद् वैदिक साहित्य के ज्ञान-काण्ड से विशेष रूप से जुड़े ग्रंथ हैं। इनमें आत्मा, ब्रह्म, जगत, ज्ञान, मृत्यु, चेतना और मुक्ति जैसे प्रश्न संवाद, दृष्टान्त और शिक्षाओं के माध्यम से उठते हैं। सभी उपनिषद् एक ही दार्शनिक शैली या एक ही मत प्रस्तुत नहीं करते।', 'source':'स्रोत: Vedic Heritage Portal — Upanishads'},
        {'title':'दशोपनिषद्', 'body':'प्रमुख दस उपनिषदों की प्रचलित सूची में ईश, केन, कठ, प्रश्न, मुण्डक, माण्डूक्य, तैत्तिरीय, ऐतरेय, छान्दोग्य और बृहदारण्यक शामिल हैं। श्वेताश्वतर, कौषीतकि और मैत्रायणी को भी कई विद्वत् सूचियों में प्रमुख स्थान दिया जाता है।', 'source':'स्रोत: Vedic Heritage Portal — Upanishads'},
        {'title':'ईश और केन', 'body':'ईशोपनिषद् त्याग, ईश्वर-व्याप्ति और कर्म-ज्ञान के संबंध पर संक्षिप्त मंत्रों में विचार करता है। केनोपनिषद् पूछता है कि मन, वाणी और इन्द्रियों को प्रेरित करने वाला आधार क्या है; इसका शिक्षण प्रश्नोत्तर और उमा हैमवती के प्रसंग से आगे बढ़ता है।', 'source':'स्रोत: IIT Kanpur Heritage — Isha / Kena Upanishad'},
        {'title':'कठ और मुण्डक', 'body':'कठोपनिषद् नचिकेता और यम के संवाद के माध्यम से श्रेय-प्रेय, आत्मविद्या और मृत्यु के प्रश्न उठाता है। मुण्डकोपनिषद् परा और अपरा विद्या का भेद बताता है तथा सत्य, तप, श्रद्धा और ब्रह्मविद्या पर विचार करता है।', 'source':'स्रोत: IIT Kanpur Heritage; Vedic Heritage Portal'},
        {'title':'माण्डूक्य और तैत्तिरीय', 'body':'माण्डूक्योपनिषद् ओंकार और जाग्रत, स्वप्न, सुषुप्ति तथा तुरीय की चर्चा के लिए प्रसिद्ध है। तैत्तिरीयोपनिषद् में शिक्षावल्ली, ब्रह्मानन्दवल्ली और भृगुवल्ली के माध्यम से शिक्षा, आचार, पंचकोश और ब्रह्मानुभूति पर विचार मिलता है।', 'source':'स्रोत: IIT Kanpur Heritage — Mandukya / Taittiriya'},
        {'title':'भाष्य पढ़ते समय', 'body':'शंकर, रामानुज, मध्व और अन्य आचार्यों की व्याख्याएँ कई स्थानों पर अलग दार्शनिक निष्कर्ष देती हैं। ऐप में मूल मंत्र, शब्दार्थ, अनुवाद और भाष्य को अलग-अलग दिखाना चाहिए; किसी एक भाष्य को सभी परंपराओं की सर्वसम्मत व्याख्या न बताएं।', 'source':'स्रोत: IIT Kanpur Heritage — Sources and editorial approach'}
      ],
      'मंत्र एवं जाप' => [
        {'title':'मंत्र का अर्थ और प्रसंग', 'body':'मंत्र केवल दोहराए जाने वाले शब्द नहीं हैं। वैदिक मंत्र का ऋषि, देवता, छन्द, शाखा और पाठ-प्रसंग हो सकता है; स्तोत्र, नाम-मंत्र और आगमिक मंत्रों की अपनी अलग परंपराएँ हैं। इसलिए सभी मंत्रों पर एक ही नियम लागू नहीं होता।', 'source':'स्रोत: Vedic Heritage Portal — Samhita / Veda Paath'},
        {'title':'जप के प्रकार', 'body':'परंपराओं में वाचिक, उपांशु और मानसिक जप का वर्णन मिलता है। साधक अपनी परंपरा और शिक्षक के निर्देश के अनुसार अभ्यास करे। दीक्षा या विशिष्ट विधि से जुड़े मंत्रों के लिए योग्य आचार्य से मार्गदर्शन लेना उचित है।', 'source':'अध्ययन टिप्पणी: परंपरा-विशिष्ट नियमों का सम्मान करें'},
        {'title':'उच्चारण और सावधानी', 'body':'वैदिक पाठ में स्वर और उच्चारण का विशेष महत्व है। रिकॉर्डिंग सुनकर बिना प्रशिक्षण के वैदिक स्वर-पाठ में दक्षता मान लेना उचित नहीं। ऐप में जहाँ प्रमाणित पाठ उपलब्ध हो, वहाँ शाखा और पाठ-स्रोत का नाम भी दिखाया जाएगा।', 'source':'स्रोत: IGNCA Vedic Heritage Portal; Sanskrit Documents'},
        {'title':'दैनिक अभ्यास', 'body':'सामान्य नाम-स्मरण के लिए शांत स्थान चुनें, सहज श्वास रखें और अपनी क्षमता के अनुसार निश्चित समय तक अभ्यास करें। संख्या को साधना का एक सहायक अनुशासन मानें, आध्यात्मिक उपलब्धि का प्रमाण नहीं।', 'source':'व्यावहारिक मार्गदर्शन; यह किसी दीक्षा-विधि का विकल्प नहीं'}
      ],
      'ध्यान साधना' => [
        {'title':'गीता में ध्यानयोग', 'body':'भगवद्गीता के छठे अध्याय में अभ्यास, वैराग्य, मन-संयम, आसन, आहार-विहार में संतुलन और ध्यान की चर्चा है। ध्यान को केवल आँख बंद करने की क्रिया नहीं, बल्कि चित्त को क्रमशः स्थिर करने का अनुशासन बताया गया है।', 'source':'स्रोत: श्रीमद्भगवद्गीता, अध्याय 6; IIT Kanpur Gita Supersite'},
        {'title':'अभ्यास और वैराग्य', 'body':'गीता 6.35 में मन को कठिनता से वश में आने वाला कहा गया है, पर अभ्यास और वैराग्य से उसे साधने की बात कही गई है। इसका आशय विचारों से लड़ना नहीं, बल्कि बार-बार सजग होकर ध्यान के विषय पर लौटना है।', 'source':'संदर्भ: भगवद्गीता 6.35'},
        {'title':'संतुलित दिनचर्या', 'body':'गीता 6.16–17 अतिशय भोजन, अतिशय उपवास, अत्यधिक सोने और बिल्कुल न सोने—इन अतियों से बचते हुए आहार, विहार, कर्म और निद्रा में संतुलन की बात करती है। इसे अपने स्वास्थ्य और परिस्थिति के अनुरूप समझें।', 'source':'संदर्भ: भगवद्गीता 6.16–17'},
        {'title':'सरल शुरुआती अभ्यास', 'body':'आरामदायक और स्थिर आसन में बैठें। श्वास को जबरन नियंत्रित न करें। कुछ मिनट सहज श्वास का निरीक्षण करें; मन भटके तो बिना झुंझलाहट ध्यान वापस लाएँ। दर्द, चक्कर या असुविधा हो तो अभ्यास रोकें।', 'source':'सामान्य शुरुआती अभ्यास; पारंपरिक प्राणायाम-निर्देश अलग हो सकते हैं'}
      ],
      _ => [
        {'title':'अध्ययन परिचय', 'body':body, 'source':'प्रारंभिक परिचय'},
        {'title':'स्रोत और पाठ-परंपरा', 'body':'प्रत्येक मूल पाठ के साथ ग्रंथ, अध्याय/सूक्त/मंत्र संख्या, पाठ-संस्करण, अनुवादक और भाष्यकार का विवरण देना आवश्यक है। अलग-अलग परंपराओं के पाठभेद और मतभेदों को स्पष्ट रूप से दिखाया जाएगा।', 'source':'संपादकीय नीति: स्रोत-पारदर्शिता'}
      ],
    };

    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: const Color(0xFF754414))),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Text(body, style: const TextStyle(fontSize: 17, height: 1.7)))),
      const SizedBox(height: 12),
      Text('विस्तृत अध्ययन • ${lessons.length} विषय', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...lessons.map((lesson) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ExpansionTile(
          leading: const Icon(Icons.menu_book, color: Color(0xFFB86B1B)),
          title: Text(lesson['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(lesson['body']!, style: const TextStyle(fontSize: 16, height: 1.7))),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: Text(lesson['source']!, style: const TextStyle(fontSize: 12, color: Colors.brown, fontStyle: FontStyle.italic))),
          ],
        ),
      )),
      const SizedBox(height: 12),
      const Card(child: ListTile(leading: Icon(Icons.verified_outlined), title: Text('स्रोत-पारदर्शिता'), subtitle: Text('मूल पाठ, संस्करण, अनुवाद और भाष्य को अलग-अलग दर्ज किया जाएगा। जहाँ मतभेद होंगे, वहाँ उन्हें स्पष्ट रूप से दिखाया जाएगा।'))),
    ]);
  }
}



class DharmaSearchPage extends StatefulWidget {
  const DharmaSearchPage({super.key});

  @override
  State<DharmaSearchPage> createState() => _DharmaSearchPageState();
}

class _DharmaSearchPageState extends State<DharmaSearchPage> {
  final TextEditingController controller = TextEditingController();
  String query = '';

  static const topics = <Map<String, String>>[
    {'title':'ॐ नमः शिवाय मंत्र', 'category':'मंत्र', 'keywords':'शिव महादेव पंचाक्षर मंत्र जाप', 'body':'“ॐ नमः शिवाय” भगवान शिव से सम्बद्ध प्रसिद्ध पंचाक्षर मंत्र है। इसे श्रद्धा और शांत मन से जपा जाता है। उच्चारण और साधना की विशेष विधि के लिए अपनी परंपरा के योग्य आचार्य से मार्गदर्शन लें।'},
    {'title':'महामृत्युंजय मंत्र', 'category':'मंत्र', 'keywords':'शिव आरोग्य त्र्यम्बकं यजामहे', 'body':'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्। उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय मामृतात्॥ यह ऋग्वेद 7.59.12 में मिलता है और यजुर्वेदीय परंपराओं में भी प्रचलित है।'},
    {'title':'गायत्री मंत्र', 'category':'मंत्र', 'keywords':'सूर्य सविता वेद ऋग्वेद', 'body':'ॐ भूर्भुवः स्वः। तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि। धियो यो नः प्रचोदयात्॥ संदर्भ: ऋग्वेद 3.62.10।'},
    {'title':'हनुमान चालीसा', 'category':'पाठ', 'keywords':'हनुमान मंगलवार शनिवार बजरंगबली', 'body':'हनुमान चालीसा गोस्वामी तुलसीदास की अवधी भक्ति-रचना है। भक्त इसे श्रद्धा से पढ़ते और सुनते हैं। पाठ का समय व्यक्तिगत परंपरा और सुविधा के अनुसार रखा जा सकता है।'},
    {'title':'सुन्दरकाण्ड का महत्व', 'category':'रामायण', 'keywords':'रामायण हनुमान सीता लंका पाठ', 'body':'वाल्मीकि रामायण के सुन्दरकाण्ड में हनुमानजी की लंका यात्रा, सीताजी से भेंट और रामदूत के रूप में उनका कार्य वर्णित है। पाठ के लिए अपनी पसंद का प्रमाणित संस्करण चुनें।'},
    {'title':'एकादशी व्रत', 'category':'व्रत', 'keywords':'विष्णु उपवास तिथि पारण', 'body':'एकादशी चंद्र-पक्ष की ग्यारहवीं तिथि है। व्रत की तिथि, हरिवासर और पारण का समय स्थान तथा पंचांग पर निर्भर करता है; स्थानीय पंचांग देखकर निर्णय करें।'},
    {'title':'प्रदोष व्रत', 'category':'व्रत', 'keywords':'शिव त्रयोदशी संध्या पूजा', 'body':'प्रदोष व्रत कृष्ण और शुक्ल पक्ष की त्रयोदशी से जुड़ा शिव-उपासना व्रत है। पूजा का समय स्थानीय सूर्यास्त और पंचांग के अनुसार देखना चाहिए।'},
    {'title':'सोमवार व्रत', 'category':'व्रत', 'keywords':'शिव सोमवार उपवास पूजा', 'body':'सोमवार का व्रत अनेक भक्त भगवान शिव की आराधना के लिए रखते हैं। व्रत-विधि और आहार के नियम अलग-अलग पारिवारिक और क्षेत्रीय परंपराओं में भिन्न हो सकते हैं।'},
    {'title':'शिवलिंग पूजा की सामान्य विधि', 'category':'पूजा', 'keywords':'शिवलिंग अभिषेक जल बिल्वपत्र पूजा', 'body':'सामान्य गृह-पूजा में स्वच्छता, श्रद्धा, जल अर्पण, बिल्वपत्र और शिव-मंत्र स्मरण शामिल हो सकते हैं। स्थानीय परंपरा तथा मंदिर के नियमों का सम्मान करें।'},
    {'title':'दीपावली पूजा', 'category':'पूजा', 'keywords':'लक्ष्मी गणेश दीपावली अमावस्या', 'body':'दीपावली पर अनेक परिवार गणेश-लक्ष्मी पूजन, दीप प्रज्वलन और मंगलकामना करते हैं। पूजा-मुहूर्त शहर और पंचांग के अनुसार बदलता है।'},
    {'title':'भगवद्गीता 2.47', 'category':'गीता', 'keywords':'कर्मण्येवाधिकारस्ते कर्म फल निष्काम कर्म', 'body':'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन। यह श्लोक कर्म करने के अधिकार और फल में आसक्ति न रखने की शिक्षा देता है। संदर्भ: श्रीमद्भगवद्गीता 2.47।'},
    {'title':'मन को शांत करने का सरल अभ्यास', 'category':'ध्यान', 'keywords':'ध्यान श्वास मन एकाग्रता तनाव', 'body':'आराम से बैठें, सहज श्वास पर ध्यान दें और विचार आने पर बिना संघर्ष फिर श्वास पर लौटें। शुरुआत 3–5 मिनट से करें। यह सामान्य ध्यान-अभ्यास है, चिकित्सा का विकल्प नहीं।'},
    {'title':'प्रेमानंद महाराज के उपदेश', 'category':'संत-विचार', 'keywords':'प्रेमानंद जी महाराज राधा नाम भक्ति सत्संग', 'body':'इस विषय में आधिकारिक सत्संग, प्रवचन और प्रकाशित स्रोतों को प्राथमिकता दें। किसी संत के नाम से अप्रमाणित उद्धरण या मनगढ़ंत कथन साझा न करें।'},
    {'title':'राशि के अनुसार मंत्र', 'category':'ज्योतिष', 'keywords':'राशि मेष वृष मिथुन कर्क सिंह कन्या तुला वृश्चिक धनु मकर कुंभ मीन', 'body':'राशि-आधारित मंत्रों की सूचियाँ अलग-अलग ज्योतिषीय और धार्मिक परंपराओं में भिन्न मिलती हैं। ऐप में इन्हें परंपरा और स्रोत सहित दिखाया जाएगा; इन्हें निश्चित फल की गारंटी नहीं बताया जाएगा।'},
    {'title':'आज का पंचांग कैसे पढ़ें?', 'category':'पंचांग', 'keywords':'तिथि वार नक्षत्र योग करण सूर्योदय', 'body':'पंचांग के पाँच मुख्य अंग तिथि, वार, नक्षत्र, योग और करण हैं। इनके समय स्थान के सूर्योदय और स्थानीय गणना के अनुसार बदलते हैं।'},
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final results = topics.where((item) {
      final haystack = '${item['title']} ${item['category']} ${item['keywords']} ${item['body']}'.toLowerCase();
      return q.isEmpty || haystack.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('धर्म एवं सनातन खोज')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            onChanged: (value) => setState(() => query = value),
            decoration: InputDecoration(
              hintText: 'अपना सवाल या मंत्र लिखें…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty ? null : IconButton(
                onPressed: () { controller.clear(); setState(() => query = ''); },
                icon: const Icon(Icons.close),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 18),
          const Text('लोकप्रिय खोज', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF492A17))),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['शिव मंत्र', 'हनुमान चालीसा', 'एकादशी', 'प्रदोष व्रत', 'राशि', 'पंचांग', 'प्रेमानंद महाराज']
                .map((label) => ActionChip(
                  label: Text(label),
                  onPressed: () { controller.text = label; setState(() => query = label); },
                )).toList(),
          ),
          const SizedBox(height: 18),
          Text(q.isEmpty ? 'चुनिंदा विषय' : '${results.length} परिणाम',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF492A17))),
          const SizedBox(height: 8),
          if (results.isEmpty)
            const Card(child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('इस विषय पर सामग्री अभी उपलब्ध नहीं है। खोज के लिए दूसरे शब्द आजमाएँ।',
                style: TextStyle(height: 1.5)),
            )),
          ...results.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFEBCB),
                child: Icon(Icons.auto_awesome, color: Color(0xFF754414)),
              ),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['category']!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DharmaTopicDetailPage(item: item),
              )),
            ),
          )),
          const SizedBox(height: 12),
          const Text('नोट: अभी यह ऐप के भीतर उपलब्ध संपादकीय सामग्री की खोज है। लाइव इंटरनेट खोज और AI प्रश्नोत्तर अगली तकनीकी सुविधा में जोड़े जाएँगे।',
            style: TextStyle(fontSize: 12, color: Colors.brown, height: 1.5)),
        ],
      ),
    );
  }
}

class DharmaTopicDetailPage extends StatelessWidget {
  const DharmaTopicDetailPage({super.key, required this.item});
  final Map<String, String> item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item['category']!)),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Text(item['title']!, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: const Color(0xFF754414), fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Text(
          item['body']!, style: const TextStyle(fontSize: 17, height: 1.8)))),
        const SizedBox(height: 12),
        const Text('धार्मिक मत, क्षेत्रीय परंपरा और पंचांग के अनुसार विधियों में अंतर हो सकता है। जहाँ आवश्यक हो, मूल शास्त्र और योग्य आचार्य से पुष्टि करें.',
          style: TextStyle(color: Colors.brown, height: 1.6, fontSize: 13)),
      ]),
    );
  }
}

class GranthaLibraryPage extends StatefulWidget {
  const GranthaLibraryPage({super.key});

  @override
  State<GranthaLibraryPage> createState() => _GranthaLibraryPageState();
}

class _GranthaLibraryPageState extends State<GranthaLibraryPage> {
  String searchQuery = '';

  static const entries = <Map<String, String>>[
    {
      'title':'वाल्मीकि रामायण: रचना और सात काण्ड',
      'body':'वाल्मीकि रामायण संस्कृत का आदिकाव्य माना जाता है। प्रचलित पाठ में बालकाण्ड, अयोध्याकाण्ड, अरण्यकाण्ड, किष्किन्धाकाण्ड, सुन्दरकाण्ड, युद्धकाण्ड और उत्तरकाण्ड—सात काण्ड हैं। कथा राम के वनगमन, सीता-हरण, हनुमान के कार्य, लंका-युद्ध और अयोध्या-वापसी के साथ धर्म, वचनपालन, संबंध, शासन और मानवीय मर्यादा के प्रश्न उठाती है। पाठ-परंपराओं में सर्ग-संख्या और कुछ प्रसंगों के पाठभेद मिलते हैं।',
      'source':'अध्ययन-संदर्भ: वाल्मीकि रामायण; IIT Kanpur Heritage — Vālmīki Rāmāyaṇa'
    },
    {
      'title':'रामायण के प्रमुख पात्र और धर्म-संकट',
      'body':'राम, सीता, लक्ष्मण, भरत, हनुमान, सुग्रीव, विभीषण और रावण को केवल एक-रेखीय पात्रों की तरह नहीं पढ़ना चाहिए। उनके निर्णयों में कर्तव्य, निष्ठा, वचन, करुणा, सत्ता, अहंकार और परिणाम के प्रश्न दिखाई देते हैं। किसी पात्र के आचरण का मूल्यांकन करते समय प्रसंग, काण्ड, संवाद और अलग-अलग रामायण परंपराओं को साथ पढ़ें।',
      'source':'अध्ययन-पद्धति: मूल काण्ड-सर्ग संदर्भ के साथ तुलनात्मक पठन'
    },
    {
      'title':'महाभारत: विशाल आख्यान और धर्म',
      'body':'महाभारत केवल कुरु-पाण्डव युद्ध का वृत्तांत नहीं; इसमें राजधर्म, आपद्धर्म, दान, नीति, मोक्ष, परिवार, प्रतिज्ञा और न्याय पर अनेक संवाद हैं। परंपरागत रूप से इसे अठारह पर्वों में व्यवस्थित किया जाता है। भीष्मपर्व में भगवद्गीता आती है। शान्तिपर्व और अनुशासनपर्व में राजधर्म, दान और आचरण पर विस्तृत शिक्षाएँ मिलती हैं।',
      'source':'अध्ययन-संदर्भ: महाभारत, विशेषतः भीष्म, शान्ति और अनुशासन पर्व'
    },
    {
      'title':'महाभारत के अध्ययन की विधि',
      'body':'किसी प्रसंग को पढ़ते समय वक्ता, श्रोता, परिस्थिति और कथा के बड़े संदर्भ को पहचानें। महाभारत में कई बार एक ही प्रश्न पर अलग पात्र अलग उत्तर देते हैं; यह विविधता ग्रंथ की विचार-समृद्धि का हिस्सा है। आलोचनात्मक संस्करण, प्रचलित पाठ और क्षेत्रीय कथन-परंपराओं को एक ही पाठ मानकर न मिलाएँ।',
      'source':'अध्ययन-पद्धति: BORI Critical Edition का परिचय तथा पारंपरिक संस्करणों की तुलना'
    },
    {
      'title':'श्रीमद्भागवत महापुराण',
      'body':'भागवत पुराण बारह स्कन्धों में व्यवस्थित है और भक्ति, अवतार-कथाओं, सृष्टि-विचार, भक्त-चरित्र तथा कृष्ण-लीला का विस्तृत आख्यान प्रस्तुत करता है। प्रह्लाद, ध्रुव, अम्बरीष, गजेन्द्र और उद्धव जैसे प्रसंग भक्ति के विविध रूप दिखाते हैं। दशम स्कन्ध में कृष्ण-कथा का विस्तार है। इसे पढ़ते समय कथा, दर्शन और भक्ति-परंपरा के स्तर अलग-अलग पहचानें।',
      'source':'अध्ययन-संदर्भ: श्रीमद्भागवत महापुराण, द्वादश स्कन्ध'
    },
    {
      'title':'अठारह महापुराण: परिचय',
      'body':'पुराण-साहित्य में सृष्टि, प्रतिसृष्टि, वंश, मन्वन्तर, राजवंश, तीर्थ, व्रत, उपासना और धर्मोपदेश जैसे विषय मिलते हैं। परंपरा में अठारह महापुराणों की सूची प्रसिद्ध है, पर प्रत्येक पुराण की रचना-परतें, पाठ और संप्रदायगत प्रभाव जटिल हैं। किसी पुराण के कथन को सभी पुराणों या सभी हिन्दू परंपराओं का एकमात्र मत न मानें।',
      'source':'अध्ययन-संदर्भ: पुराण-साहित्य की पारंपरिक सूची और संबंधित पुराणों के मूल पाठ'
    },
    {
      'title':'षड्दर्शन: भारतीय दर्शन की छह परंपराएँ',
      'body':'न्याय ज्ञान के साधनों और तर्क-विचार पर, वैशेषिक पदार्थों और उनके वर्गीकरण पर, सांख्य पुरुष-प्रकृति विवेक पर, योग चित्तवृत्ति-निरोध और साधना पर, पूर्वमीमांसा वैदिक कर्म तथा वाक्य-अर्थ पर, और वेदान्त ब्रह्म-आत्मा तथा उपनिषद्-विचार पर केंद्रित है। इन परंपराओं के भीतर भी अनेक आचार्य, उपशाखाएँ और मतभेद हैं।',
      'source':'अध्ययन-संदर्भ: न्यायसूत्र, वैशेषिकसूत्र, सांख्यकारिका, योगसूत्र, मीमांसासूत्र, ब्रह्मसूत्र'
    },
    {
      'title':'पतञ्जलि योगसूत्र: चित्त और अभ्यास',
      'body':'योगसूत्र चार पादों—समाधि, साधना, विभूति और कैवल्य—में व्यवस्थित है। दूसरे सूत्र में योग को चित्तवृत्तियों के निरोध के रूप में परिभाषित किया गया है। अभ्यास और वैराग्य, अष्टाङ्गयोग, क्लेश, समाधि और कैवल्य इसके प्रमुख विषय हैं। सूत्रों का अर्थ परंपरागत भाष्यों के साथ पढ़ें; आधुनिक योग-व्यायाम और शास्त्रीय योगदर्शन एक ही चीज नहीं हैं।',
      'source':'संदर्भ: पतञ्जलि योगसूत्र 1.2, 1.12; साधनपाद 2.29'
    },
    {
      'title':'धर्म, आचार और जीवन के निर्णय',
      'body':'धर्मशास्त्रीय साहित्य में आचार, व्यवहार, प्रायश्चित्त, आश्रम, संस्कार और सामाजिक दायित्वों पर चर्चा है। स्मृतियों और निबन्धों के विधान काल, क्षेत्र, समुदाय और परंपरा के अनुसार अलग-अलग रूप में समझे गए हैं। ऐतिहासिक विधान को आज के कानून या सार्वभौमिक नैतिक आदेश के रूप में सीधे लागू न करें; संदर्भ, इतिहास और वर्तमान संवैधानिक व्यवस्था का ध्यान रखें।',
      'source':'अध्ययन-संदर्भ: धर्मसूत्र, मनुस्मृति, याज्ञवल्क्य स्मृति और आधुनिक अकादमिक अध्ययन'
    },
    {
      'title':'अठारह महापुराणों के नाम',
      'body':'परंपरागत अठारह महापुराणों की प्रसिद्ध सूची है: ब्रह्म, पद्म, विष्णु, शिव, भागवत, नारद, मार्कण्डेय, अग्नि, भविष्य, ब्रह्मवैवर्त, लिंग, वराह, स्कन्द, वामन, कूर्म, मत्स्य, गरुड़ और ब्रह्माण्ड पुराण। सूचियों के क्रम और कुछ नाम-रूपों में परंपरा के अनुसार अंतर मिल सकता है। प्रत्येक पुराण को उसके अपने पाठ, विषय-विन्यास और संप्रदायगत संदर्भ में पढ़ना चाहिए।',
      'source':'अध्ययन-संदर्भ: पुराण-साहित्य की पारंपरिक अष्टादश महापुराण सूची; संबंधित पुराणों के मूल पाठ'
    },
    {
      'title':'रामायण के सात काण्ड: क्रमिक अध्ययन',
      'body':'बालकाण्ड में रामकथा की भूमिका और आरम्भिक जीवन; अयोध्याकाण्ड में राज्याभिषेक की तैयारी, वनवास और भरत का प्रसंग; अरण्यकाण्ड में वनजीवन और सीता-हरण; किष्किन्धाकाण्ड में सुग्रीव से मैत्री और सीता की खोज; सुन्दरकाण्ड में हनुमान का लंका-गमन; युद्धकाण्ड में लंका-युद्ध और अयोध्या-वापसी; उत्तरकाण्ड में उत्तरवर्ती कथा आती है। काण्डों के पाठ और उत्तरकाण्ड की स्थिति पर विद्वानों में चर्चा है।',
      'source':'अध्ययन-संदर्भ: वाल्मीकि रामायण, सात काण्ड; पाठ-परंपरा का तुलनात्मक अध्ययन'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final q = searchQuery.trim().toLowerCase();
    final filtered = entries.where((entry) =>
      q.isEmpty || entry.values.any((value) => value.toLowerCase().contains(q))
    ).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('महाग्रंथ एवं दर्शन')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('सनातन साहित्य का विस्तृत परिचय', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xFF754414))),
          const SizedBox(height: 8),
          const Text('महाकाव्य, पुराण और दर्शन को उनके मूल संदर्भ, पाठ-परंपरा और अलग-अलग व्याख्याओं के साथ पढ़ें।', style: TextStyle(fontSize: 15, height: 1.6)),
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: 'ग्रंथ, विषय या दर्शन खोजें…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty ? null : IconButton(
                tooltip: 'खोज मिटाएँ',
                onPressed: () => setState(() => searchQuery = ''),
                icon: const Icon(Icons.close),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Text('${filtered.length} अध्ययन विषय', style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            const Card(child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Icon(Icons.search_off, size: 34, color: Colors.brown),
                SizedBox(height: 8),
                Text('इस शब्द से कोई विषय नहीं मिला।', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('दूसरा शब्द लिखकर खोजें।'),
              ]),
            )),
          ...filtered.map((entry) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              leading: const Icon(Icons.auto_stories, color: Color(0xFFB86B1B)),
              title: Text(entry['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Align(alignment: Alignment.centerLeft, child: Text(entry['body']!, style: const TextStyle(fontSize: 16, height: 1.7))),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: Text(entry['source']!, style: const TextStyle(fontSize: 12, color: Colors.brown, fontStyle: FontStyle.italic))),
              ],
            ),
          )),
          const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('पाठ और परंपरा'), subtitle: Text('जहाँ पाठभेद या मतभेद हैं, वहाँ उन्हें स्पष्ट रूप से अलग रखा जाएगा। मूल ग्रंथ, अनुवाद और आधुनिक व्याख्या को एक-दूसरे के स्थान पर प्रस्तुत नहीं किया जाएगा।'))),
        ],
      ),
    );
  }
}

class GitaLibraryPage extends StatefulWidget {
  const GitaLibraryPage({super.key});

  @override
  State<GitaLibraryPage> createState() => _GitaLibraryPageState();
}

class _GitaLibraryPageState extends State<GitaLibraryPage> {
  String searchQuery = '';

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
    (number: 13, title: 'क्षेत्रक्षेत्रज्ञविभागयोग', transliteration: 'Kshetra Kshetrajna Vibhaga Yoga', verses: 35, summary: 'शरीर, क्षेत्रज्ञ और ज्ञान के तत्व', topics: 'क्षेत्र • क्षेत्रज्ञ • प्रकृति • पुरुष • ज्ञान'),
    (number: 14, title: 'गुणत्रयविभागयोग', transliteration: 'Gunatraya Vibhaga Yoga', verses: 27, summary: 'सत्त्व, रजस और तमस का विवेचन', topics: 'तीन गुण • गुणों के लक्षण • गुणातीत अवस्था'),
    (number: 15, title: 'पुरुषोत्तमयोग', transliteration: 'Purushottama Yoga', verses: 20, summary: 'संसार-वृक्ष, जीव और पुरुषोत्तम का विवेचन', topics: 'अश्वत्थ वृक्ष • जीव • परमात्मा • पुरुषोत्तम'),
    (number: 16, title: 'दैवासुरसम्पद्विभागयोग', transliteration: 'Daivasura Sampad Vibhaga Yoga', verses: 24, summary: 'दैवी और आसुरी प्रवृत्तियों का अंतर', topics: 'अभय • सत्य • अहिंसा • दंभ • क्रोध • आचरण'),
    (number: 17, title: 'श्रद्धात्रयविभागयोग', transliteration: 'Shraddhatraya Vibhaga Yoga', verses: 28, summary: 'तीन गुणों के अनुसार श्रद्धा, आहार और यज्ञ', topics: 'श्रद्धा • आहार • यज्ञ • तप • दान • ॐ तत् सत्'),
    (number: 18, title: 'मोक्षसंन्यासयोग', transliteration: 'Moksha Sannyasa Yoga', verses: 78, summary: 'त्याग, स्वधर्म, ज्ञान, भक्ति और मोक्ष का समन्वय', topics: 'त्याग • कर्म के कारण • स्वधर्म • शरणागति • निष्कर्ष'),
  ];

  @override
  Widget build(BuildContext context) {
    final q = searchQuery.trim().toLowerCase();
    final filtered = chapters.where((chapter) =>
      q.isEmpty ||
      chapter.title.toLowerCase().contains(q) ||
      chapter.transliteration.toLowerCase().contains(q) ||
      chapter.summary.toLowerCase().contains(q) ||
      chapter.topics.toLowerCase().contains(q) ||
      chapter.number.toString() == q
    ).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('श्रीमद्भगवद्गीता')),
      body: ListView(
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
                Text('18 अध्याय  •  प्रचलित गणना 700 श्लोक', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF754414))),
                SizedBox(height: 6),
                Text('पारंपरिक 700-श्लोक पाठ-क्रम के अनुसार। इस ऐप में प्रयुक्त डिजिटल पाठ में अध्याय 13 का आरम्भिक प्रश्न अलग गिनने से 701 प्रविष्टियाँ हैं; प्रचलित पाठ-गणना 700 श्लोक की है। दोनों गणनाओं का अंतर स्पष्ट रखा गया है।', style: TextStyle(height: 1.5)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: 'अध्याय का नाम, विषय या नंबर खोजें…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty ? null : IconButton(
                tooltip: 'खोज मिटाएँ',
                onPressed: () => setState(() => searchQuery = ''),
                icon: const Icon(Icons.close),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Text('${filtered.length} अध्याय मिले', style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            const Card(child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('कोई अध्याय नहीं मिला। दूसरा शब्द या अध्याय नंबर खोजें।')),
            )),
          ...filtered.map((chapter) => Card(
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
      ),
    );
  }
}

class GitaChapterPage extends StatelessWidget {
  const GitaChapterPage({super.key, required this.chapter});
  final ({int number, String title, String transliteration, int verses, String summary, String topics}) chapter;

  static const Map<int, Map<String, String>> deepStudy = {
    1: {'teaching':'कुरुक्षेत्र में अर्जुन अपने ही संबंधियों, गुरुओं और मित्रों को सामने देखकर विचलित हो जाते हैं। उनका संकट केवल युद्ध का भय नहीं, बल्कि कर्तव्य, करुणा, परिवार और धर्म के बीच टकराव है। यह अध्याय प्रश्न खड़ा करता है: कठिन परिस्थिति में भावनात्मक मोह और नैतिक करुणा में अंतर कैसे पहचाना जाए? कृष्ण का उपदेश अगले अध्याय से आरम्भ होता है।','refs':'1.28–1.47','reflect':'क्या मैं कठिन निर्णय लेते समय पूरे धर्म-संदर्भ को देखता हूँ, या केवल तत्काल भावनाओं से निर्णय करता हूँ?'},
    2: {'teaching':'कृष्ण आत्मा की नित्यता और शरीर की परिवर्तनशीलता समझाते हैं। फिर समत्व-बुद्धि, निष्काम कर्म और स्थितप्रज्ञ के लक्षण बताते हैं। यहाँ सांख्य-दृष्टि और कर्मयोग की आधारभूमि मिलती है। फल की आसक्ति छोड़ने का अर्थ कर्म छोड़ना नहीं, बल्कि अपने अधिकार के क्षेत्र में सजग और समर्पित कर्म करना है।','refs':'2.11–2.30; 2.47–2.50; 2.55–2.72','reflect':'मेरे नियंत्रण में क्या है—प्रयास और निर्णय, या परिणाम की हर परिस्थिति?'},
    3: {'teaching':'कर्मयोग में कर्तव्य-कर्म को यज्ञभाव से करने और लोकसंग्रह अर्थात समाज के हित को ध्यान में रखने की शिक्षा है। केवल कर्म न करने से निष्कर्मता नहीं मिलती; प्रकृति के गुण सबको कर्म में प्रवृत्त करते हैं। आसक्ति और स्वार्थ छोड़कर उचित कर्म करना साधना का मार्ग बनता है।','refs':'3.4–3.9; 3.19–3.26; 3.20–3.26; 3.37–3.43','reflect':'मेरे काम से परिवार, समाज और दूसरे लोगों को क्या लाभ या हानि पहुँचती है?'},
    4: {'teaching':'यह अध्याय योग-परंपरा की निरंतरता, धर्म की रक्षा के लिए अवतार, कर्म-अकर्म की सूक्ष्मता और ज्ञानयज्ञ का विवेचन करता है। कर्म का मूल्य केवल बाहरी क्रिया से तय नहीं होता; उसके पीछे का भाव, समझ और आसक्ति भी महत्वपूर्ण हैं। गुरु के पास विनय, प्रश्न और सेवा से ज्ञान ग्रहण करने की बात कही गई है।','refs':'4.1–4.8; 4.16–4.18; 4.33–4.39','reflect':'किसी कर्म का बाहरी रूप और उसके पीछे की नीयत—दोनों को क्या मैं अलग-अलग परखता हूँ?'},
    5: {'teaching':'कर्मसंन्यास और कर्मयोग के संबंध को स्पष्ट करते हुए कृष्ण बताते हैं कि आसक्ति-रहित कर्म भी आंतरिक संन्यास का मार्ग है। समदृष्टि, आत्मसंयम और शांति इस अध्याय के प्रमुख सूत्र हैं। संन्यास का अर्थ केवल बाहरी भूमिका बदलना नहीं; मन में कर्तापन और फल-आसक्ति का क्षय भी आवश्यक है।','refs':'5.2–5.12; 5.18; 5.27–5.29','reflect':'क्या मैं जिम्मेदारियाँ निभाते हुए भी अहंकार और फल की बेचैनी कम कर सकता हूँ?'},
    6: {'teaching':'ध्यानयोग में मन को संयमित करने, अभ्यास और वैराग्य, उचित आसन तथा भोजन-निद्रा में संतुलन का निर्देश है। मन चंचल है, पर निरंतर अभ्यास से उसे साधा जा सकता है। अध्याय योगभ्रष्ट साधक के प्रश्न का उत्तर देकर आध्यात्मिक प्रयास की निरंतरता पर भी आश्वासन देता है।','refs':'6.5–6.7; 6.10–6.17; 6.26; 6.35–6.47','reflect':'जब ध्यान भटकता है, क्या मैं स्वयं को दोष देता हूँ या धैर्य से वापस लौटता हूँ?'},
    7: {'teaching':'ज्ञान-विज्ञानयोग में कृष्ण अपनी प्रकृति के जड़ और चेतन आयाम, जगत के आधार और माया की कठिनाई बताते हैं। चार प्रकार के भक्तों का वर्णन आता है और ज्ञानी भक्त की विशेषता बताई जाती है। यह अध्याय ईश्वर को केवल किसी एक सीमित रूप में नहीं, बल्कि समस्त अस्तित्व के आधार के रूप में समझने की दिशा देता है।','refs':'7.4–7.7; 7.14–7.19','reflect':'क्या मेरी आध्यात्मिक जिज्ञासा केवल लाभ पाने तक सीमित है, या सत्य को जानने की इच्छा भी है?'},
    8: {'teaching':'अक्षरब्रह्मयोग में ब्रह्म, अध्यात्म, कर्म और अधिभूत आदि प्रश्नों का उत्तर दिया गया है। अंतिम समय का स्मरण महत्वपूर्ण बताया गया है, पर यह स्मरण जीवनभर के अभ्यास और चित्त की दिशा से जुड़ा है। अध्याय साधना, निरंतर स्मरण और परम गति पर विचार करता है।','refs':'8.3–8.7; 8.13–8.15; 8.20–8.22','reflect':'मेरे दैनिक विचार और आदतें मेरे मन को किस दिशा में प्रशिक्षित कर रही हैं?'},
    9: {'teaching':'राजविद्याराजगुह्ययोग में ईश्वर की व्यापकता, जगत के साथ उसका संबंध और अनन्य भक्ति की सरलता बताई गई है। कृष्ण पत्र, पुष्प, फल या जल को प्रेमपूर्वक अर्पित करने की बात कहते हैं। अध्याय यह भी स्पष्ट करता है कि व्यक्ति का वर्तमान आचरण और भक्ति उसकी आध्यात्मिक दिशा बदल सकते हैं।','refs':'9.4–9.11; 9.22; 9.26–9.34','reflect':'मैं अपने सामान्य दैनिक कार्यों को कृतज्ञता और समर्पण से कैसे जोड़ सकता हूँ?'},
    10: {'teaching':'विभूतियोग में जगत की श्रेष्ठता, सामर्थ्य, सौंदर्य और व्यवस्था को ईश्वर की विभूतियों के रूप में देखने की दृष्टि दी गई है। सूची का उद्देश्य केवल नाम याद करना नहीं, बल्कि विविधता में एक व्यापक दिव्य आधार का स्मरण करना है। अंत में कृष्ण अपनी विभूतियों की अनंतता बताते हैं।','refs':'10.8–10.11; 10.19–10.42','reflect':'प्रकृति, ज्ञान, साहस या करुणा में महानता देखकर क्या मेरे भीतर अहंकार के बजाय विस्मय और विनम्रता आती है?'},
    11: {'teaching':'अर्जुन दिव्यदृष्टि से विराट विश्वरूप देखते हैं। इस दर्शन में सृष्टि, पालन, संहार, काल और असंख्य रूपों का एक साथ अनुभव है। अर्जुन विस्मय और भय दोनों अनुभव करते हैं। अध्याय मनुष्य की सीमित दृष्टि और विराट सत्ता के सामने विनम्रता का बोध कराता है।','refs':'11.8–11.14; 11.32; 11.45–11.55','reflect':'क्या मैं जीवन की विशालता और अपनी सीमाओं को स्वीकार कर पाता हूँ?'},
    12: {'teaching':'भक्तियोग साकार उपासना और अव्यक्त अक्षर की उपासना पर प्रश्न का उत्तर देता है। कृष्ण मन को ईश्वर में स्थिर करने से लेकर अभ्यास, कर्मार्पण और त्याग तक क्रमिक उपाय बताते हैं। आगे अद्वेष्टा, मैत्री, करुणा, क्षमा, संतोष और समत्व जैसे प्रिय भक्त के गुण बताए गए हैं।','refs':'12.2–12.12; 12.13–12.20','reflect':'क्या मेरी भक्ति मेरे व्यवहार में दया, क्षमा, सत्य और संतुलन बढ़ा रही है?'},
    13: {'teaching':'क्षेत्र और क्षेत्रज्ञ का विवेचन शरीर-मन के अनुभव-क्षेत्र और उसे जानने वाले चेतन तत्व के भेद से आरम्भ होता है। विनम्रता, अहिंसा, क्षमा, सरलता और आत्मचिंतन को ज्ञान के अंग कहा गया है। प्रकृति, पुरुष और परमात्मा के संबंध पर विभिन्न वेदान्त परंपराएँ अलग व्याख्याएँ देती हैं।','refs':'13.1–13.7; 13.19–13.23','reflect':'क्या मैं अपने शरीर, विचार और भावनाओं को देख सकता हूँ, बिना हर अनुभव को अपनी पूरी पहचान मान लिए?'},
    14: {'teaching':'सत्त्व, रजस और तमस प्रकृति के तीन गुण हैं, जो मनुष्य की प्रवृत्ति और अनुभव को प्रभावित करते हैं। सत्त्व प्रकाश और स्पष्टता, रजस सक्रिय इच्छा और आसक्ति, तथा तमस जड़ता और प्रमाद से जुड़ा है। अध्याय गुणों के प्रभाव को पहचानने और उनसे ऊपर उठने की दिशा देता है।','refs':'14.5–14.18; 14.19–14.26','reflect':'मेरे निर्णयों में इस समय कौन-सी प्रवृत्ति अधिक सक्रिय है—स्पष्टता, बेचैनी या जड़ता?'},
    15: {'teaching':'ऊर्ध्वमूल अश्वत्थ वृक्ष का रूपक संसार की जटिल जड़ता और आसक्ति को समझाता है। वैराग्यरूपी दृढ़ साधन से उसके बंधन को काटकर परम पद की खोज का संदेश है। अध्याय जीव, क्षर-अक्षर और पुरुषोत्तम के भेद का विवेचन करता है।','refs':'15.1–15.6; 15.7–15.11; 15.16–15.20','reflect':'कौन-सी आदतें या आसक्तियाँ मुझे अपने वास्तविक लक्ष्य से दूर रखती हैं?'},
    16: {'teaching':'दैवी और आसुरी संपदाओं का वर्णन नैतिक जीवन की कसौटी प्रस्तुत करता है। अभय, सत्य, दान, आत्मसंयम और अहिंसा जैसे गुणों के विपरीत दंभ, अहंकार, क्रोध और कठोरता का उल्लेख है। अध्याय आचरण के परिणाम और शास्त्रीय विवेक के महत्व पर बल देता है।','refs':'16.1–16.5; 16.7–16.24','reflect':'मेरे व्यवहार में कौन-सा एक दैवी गुण मैं आज सचेत रूप से विकसित कर सकता हूँ?'},
    17: {'teaching':'श्रद्धा को भी तीन गुणों के अनुसार समझाया गया है। भोजन, यज्ञ, तप और दान के सात्त्विक, राजस और तामस रूप बताए गए हैं। केवल बाहरी कर्म पर्याप्त नहीं; उसका उद्देश्य, विधि, समय, पात्र और मनोभाव भी उसके स्वरूप को प्रभावित करते हैं। ॐ तत् सत् का प्रसंग भी आता है।','refs':'17.2–17.6; 17.7–17.22; 17.23–17.28','reflect':'मेरे दान, अनुशासन या धार्मिक कर्म के पीछे दिखावा है, लाभ है या निष्ठा?'},
    18: {'teaching':'अंतिम अध्याय पूर्ववर्ती शिक्षाओं का समन्वय करता है: संन्यास और त्याग, कर्म के कारण, ज्ञान-कर्म-कर्ता के गुणभेद, स्वधर्म, बुद्धि-धृति और भक्ति। कृष्ण अर्जुन को विचारपूर्वक निर्णय लेने की स्वतंत्रता देते हैं। समर्पण का संदेश विवेक और उत्तरदायित्व को मिटाता नहीं, बल्कि उन्हें गहरा करता है।','refs':'18.1–18.12; 18.13–18.18; 18.41–18.48; 18.63–18.66','reflect':'सभी पक्षों पर विचार करने के बाद क्या मैं अपने कर्तव्य का निर्णय स्पष्टता और समर्पण से लेता हूँ?'},
  };

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
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('गहन अध्ययन', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Color(0xFF754414))),
              const SizedBox(height: 8),
              Text(deepStudy[chapter.number]!['teaching']!, style: const TextStyle(fontSize: 16, height: 1.7)),
              const SizedBox(height: 12),
              const Text('महत्वपूर्ण श्लोक-संदर्भ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(deepStudy[chapter.number]!['refs']!, style: const TextStyle(height: 1.5, color: Colors.brown)),
              const Divider(height: 24),
              const Text('मनन के प्रश्न', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(deepStudy[chapter.number]!['reflect']!, style: const TextStyle(fontSize: 15, height: 1.6)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        const Text('इस अध्याय का अध्ययन कैसे करें?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('पहले अध्याय का सार पढ़ें। फिर श्लोकों को क्रम से पढ़ते हुए मूल संस्कृत पाठ, पदच्छेद, शब्दार्थ, अनुवाद और भावार्थ का अध्ययन करें। जहाँ अलग-अलग आचार्यों के भाष्य उपलब्ध हों, वहाँ उन्हें अलग-अलग मत के रूप में पढ़ें।', style: TextStyle(height: 1.6)))),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book, color: Color(0xFF754414)),
            title: const Text('इस अध्याय के मूल श्लोक पढ़ें'),
            subtitle: const Text('मूल संस्कृत पाठ • उच्चारण-सहायक लिप्यंतरण • उपलब्ध हिंदी शब्दार्थ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => GitaVerseListPage(chapterNumber: chapter.number, chapterTitle: chapter.title),
            )),
          ),
        ),
      ]),
    );
  }
}


/// Verse corpus is sourced from the public-domain gita/gita dataset (Unlicense).
/// Hindi lexical glosses below are original editorial notes and are deliberately
/// shown only for verses that have been manually reviewed.
class GitaVerseListPage extends StatefulWidget {
  const GitaVerseListPage({super.key, required this.chapterNumber, required this.chapterTitle});
  final int chapterNumber;
  final String chapterTitle;

  @override
  State<GitaVerseListPage> createState() => _GitaVerseListPageState();
}

class _GitaVerseListPageState extends State<GitaVerseListPage> {
  late Future<List<Map<String, dynamic>>> versesFuture;
  String query = '';

  @override
  void initState() {
    super.initState();
    versesFuture = _loadVerses();
  }

  Future<List<Map<String, dynamic>>> _loadVerses() async {
    final raw = await rootBundle.loadString('assets/data/gita_verses.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .where((v) => v['chapter_number'] == widget.chapterNumber)
        .toList()
      ..sort((a, b) => (a['verse_number'] as int).compareTo(b['verse_number'] as int));
  }

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(title: Text('अध्याय ${widget.chapterNumber} • मूल श्लोक')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('श्लोक सामग्री लोड नहीं हो सकी।'));
          }
          final all = snapshot.data!;
          final filtered = all.where((v) {
            final text = '${v['text']} ${v['transliteration']} ${v['verse_number']}'.toLowerCase();
            return q.isEmpty || text.contains(q);
          }).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(widget.chapterTitle, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF754414), fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('इस अध्याय में ${all.length} श्लोक • मूल संस्कृत पाठ', style: const TextStyle(color: Colors.brown)),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: InputDecoration(
                  hintText: 'श्लोक संख्या या संस्कृत शब्द खोजें',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty ? null : IconButton(
                    onPressed: () => setState(() => query = ''),
                    icon: const Icon(Icons.close),
                  ),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              Text('${filtered.length} श्लोक मिले', style: const TextStyle(color: Colors.brown)),
              const SizedBox(height: 8),
              ...filtered.map((v) => Card(
                margin: const EdgeInsets.only(bottom: 9),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFEBCB),
                    foregroundColor: const Color(0xFF754414),
                    child: Text('${v['verse_number']}'),
                  ),
                  title: Text('श्लोक ${widget.chapterNumber}.${v['verse_number']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text((v['text'] as String).replaceAll(RegExp(r'\s+'), ' ').trim(),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(height: 1.5, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => GitaVerseDetailPage(verse: v),
                  )),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

class GitaVerseDetailPage extends StatelessWidget {
  const GitaVerseDetailPage({super.key, required this.verse});
  final Map<String, dynamic> verse;

  static const Map<String, String> reviewedHindiGlosses = {
    '1.1': 'धर्मक्षेत्रे — धर्मभूमि में; कुरुक्षेत्रे — कुरुक्षेत्र में; समवेताः — एकत्र हुए; युयुत्सवः — युद्ध की इच्छा रखने वाले; मामकाः — मेरे पुत्र; पाण्डवाः — पाण्डु के पुत्र; च — और; एव — ही/भी; किम् — क्या; अकुर्वत — उन्होंने किया; सञ्जय — हे संजय।',
    '2.47': 'कर्मणि — कर्मों में; एव — ही; अधिकारः — अधिकार; ते — तुम्हारा; मा — मत; फलेषु — फलों में; कदाचन — कभी भी; मा — मत; कर्मफलहेतुः — कर्मफल को ही उद्देश्य बनाने वाला; भूः — हो; ते — तुम्हारी; सङ्गः — आसक्ति; अस्तु — हो; अकर्मणि — कर्म न करने में।',
    '2.48': 'योगस्थः — योग में स्थित होकर; कुरु — करो; कर्माणि — कर्म; सङ्गम् — आसक्ति; त्यक्त्वा — त्यागकर; धनञ्जय — हे धनंजय; सिद्धि-असिद्ध्योः — सफलता और असफलता में; समः — समान; भूत्वा — होकर; समत्वम् — समभाव; योगः — योग; उच्यते — कहा जाता है।',
    '1.2': 'दृष्ट्वा — देखकर; तु — तो/किन्तु; पाण्डव-अनीकम् — पाण्डवों की सेना; व्यूढम् — व्यूह में सजी हुई; दुर्योधनः — दुर्योधन; तदा — तब; आचार्यम् — आचार्य द्रोण को; उपसङ्गम्य — पास जाकर; राजा — राजा; वचनम् — वचन; अब्रवीत् — बोला।',
    '1.3': 'पश्य — देखिए; एताम् — इस; पाण्डुपुत्राणाम् — पाण्डु-पुत्रों की; आचार्य — हे आचार्य; महतीम् — विशाल; चमूम् — सेना को; व्यूढाम् — व्यूहबद्ध; द्रुपदपुत्रेण — द्रुपद-पुत्र (धृष्टद्युम्न) द्वारा; तव — आपके; शिष्येण — शिष्य द्वारा; धीमता — बुद्धिमान।',
    '1.4': 'अत्र — यहाँ; शूराः — वीर; महेष्वासाः — महान धनुर्धर; भीम-अर्जुन-समाः — भीम और अर्जुन के समान; युधि — युद्ध में; युयुधानः — युयुधान (सात्यकि); विराटः — विराट; च — और; द्रुपदः — द्रुपद; महारथः — महारथी।',
    '1.5': 'धृष्टकेतुः — धृष्टकेतु; चेकितानः — चेकितान; काशिराजः — काशी के राजा; च — और; वीर्यवान् — पराक्रमी; पुरुजित् — पुरुजित; कुन्तिभोजः — कुन्तिभोज; शैब्यः — शैब्य; नरपुङ्गवः — पुरुषों में श्रेष्ठ।',
    '2.49': 'दूरेण — बहुत दूर/निम्नतर; हि — निश्चय ही; अवरम् — हीन; कर्म — कर्म; बुद्धियोगात् — बुद्धियोग की अपेक्षा; धनञ्जय — हे धनंजय; बुद्धौ — समबुद्धि में; शरणम् — आश्रय; अन्विच्छ — खोजो; कृपणाः — दीन/अल्पदृष्टि लोग; फलहेतवः — फल को ही उद्देश्य मानने वाले।',
    '2.50': 'बुद्धियुक्तः — समबुद्धि से युक्त; जहाति — छोड़ देता है; इह — इसी जीवन में; उभे — दोनों; सुकृत-दुष्कृते — पुण्य और पाप; तस्मात् — इसलिए; योगाय — योग के लिए; युज्यस्व — स्वयं को लगाओ; योगः — योग; कर्मसु — कर्मों में; कौशलम् — कुशलता/समत्वपूर्ण दक्षता।',
  };

  @override
  Widget build(BuildContext context) {
    final chapter = verse['chapter_number'] as int;
    final number = verse['verse_number'] as int;
    final key = '$chapter.$number';
    final original = (verse['text'] as String).trim();
    final transliteration = (verse['transliteration'] as String).trim();
    final gloss = reviewedHindiGlosses[key];
    return Scaffold(
      appBar: AppBar(title: Text('गीता $key')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('श्रीमद्भगवद्गीता', style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF754414), fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Card(
            color: const Color(0xFFFFF0D7),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SelectableText(original, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21, height: 2, color: Color(0xFF492A17), fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('लिप्यंतरण (उच्चारण में सहायता)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Card(child: Padding(padding: const EdgeInsets.all(14),
            child: SelectableText(transliteration, style: const TextStyle(height: 1.7)))),
          const SizedBox(height: 12),
          const Text('हिंदी शब्दार्थ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(
            gloss ?? 'इस श्लोक का पदच्छेद और हिंदी शब्द-दर-शब्द अर्थ संपादकीय सत्यापन के बाद जोड़ा जाएगा। अभी अनुमानित अर्थ नहीं दिया जा रहा है।',
            style: const TextStyle(fontSize: 16, height: 1.8)))),
          const SizedBox(height: 12),
          const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
            'पाठ-स्रोत: gita/gita सार्वजनिक डोमेन Sanskrit verse dataset (Unlicense)। मूल पाठ को ऐप में शामिल किया गया है; हिंदी शब्दार्थ अलग से जाँचे और तैयार किए जा रहे हैं। अलग संस्करणों में पाठ/गणना के छोटे अंतर संभव हैं।',
            style: TextStyle(fontSize: 12, height: 1.6, color: Colors.brown)))),
        ],
      ),
    );
  }
}
