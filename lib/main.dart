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
    final List<Map<String, String>> lessons = switch (hiTitle) {
      'चारों वेद' => [
        {'title':'वेद-साहित्य की रचना', 'body':'वैदिक साहित्य को समझने के लिए केवल संहिता पढ़ना पर्याप्त नहीं। परंपरागत रूप से प्रत्येक वेद से सम्बद्ध संहिता, ब्राह्मण, आरण्यक और उपनिषद् साहित्य का अध्ययन किया जाता है। शाखाओं के अनुसार पाठ और परंपरा में अंतर हो सकता है।', 'source':'स्रोत: IGNCA, Vedic Heritage Portal — Introduction'},
        {'title':'ऋग्वेद', 'body':'ऋग्वेद मुख्यतः ऋचाओं और सूक्तों का संग्रह है। इसके दस मंडल हैं। अग्नि, इन्द्र, सोम, उषस् और अन्य देवताओं को सम्बोधित सूक्त वैदिक काव्य, यज्ञ, प्रकृति-अनुभव और दार्शनिक जिज्ञासा के अनेक आयाम दिखाते हैं। प्रत्येक सूक्त को उसके ऋषि, देवता और छन्द सहित पढ़ना उपयोगी है।', 'source':'स्रोत: Vedic Heritage Portal — Rigveda Samhita'},
        {'title':'यजुर्वेद', 'body':'यजुर्वेद यज्ञीय अनुष्ठानों में प्रयुक्त यजुस्-मंत्रों और विधियों से जुड़ा है। इसकी शुक्ल और कृष्ण परंपराएँ हैं; वाजसनेयी संहिता शुक्ल यजुर्वेद से तथा तैत्तिरीय संहिता कृष्ण यजुर्वेद से सम्बद्ध है। मंत्र को उसके अनुष्ठानिक प्रसंग से अलग करके अर्थ तय नहीं करना चाहिए।', 'source':'स्रोत: Vedic Heritage Portal — Yajurveda'},
        {'title':'सामवेद', 'body':'सामवेद का विशेष महत्व गेय मंत्रों और सामगान की परंपरा में है। इसके अनेक मंत्र ऋग्वेद से सम्बद्ध ऋचाओं पर आधारित हैं, पर उनका गायन-विन्यास और अनुष्ठानिक उपयोग विशिष्ट है। इसे केवल “संगीत की पुस्तक” कहना इसकी यज्ञीय और पाठ-परंपरा को अधूरा कर देता है।', 'source':'स्रोत: Vedic Heritage Portal — Samaveda'},
        {'title':'अथर्ववेद', 'body':'अथर्ववेद में शान्ति, आरोग्य, गृहस्थ जीवन, राजधर्म, सामाजिक जीवन, प्रार्थना और दार्शनिक चिंतन से जुड़े विविध सूक्त मिलते हैं। इसकी शौनक और पैप्पलाद जैसी पाठ-परंपराओं का उल्लेख मिलता है। किसी मंत्र का अर्थ उसके सूक्त और शाखा-संदर्भ के साथ समझना चाहिए।', 'source':'स्रोत: Vedic Heritage Portal — Atharvaveda'},
        {'title':'अध्ययन की विधि', 'body':'हर वैदिक पाठ के साथ मंडल/काण्ड, सूक्त, मंत्र संख्या, शाखा, उपलब्ध पाठ-संस्करण और अनुवादक का नाम दर्ज होना चाहिए। वैदिक स्वर-चिह्नों और उच्चारण को सामान्य संस्कृत उच्चारण से एक जैसा न मानें।', 'source':'स्रोत: IGNCA Vedic Heritage Portal; Sanskrit Documents'}
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

  static const Map<int, Map<String, String>> deepStudy = {
    1: {'teaching':'कुरुक्षेत्र में अर्जुन अपने ही संबंधियों, गुरुओं और मित्रों को सामने देखकर विचलित हो जाते हैं। उनका संकट केवल युद्ध का भय नहीं, बल्कि कर्तव्य, करुणा, परिवार और धर्म के बीच टकराव है। यह अध्याय प्रश्न खड़ा करता है: कठिन परिस्थिति में भावनात्मक मोह और नैतिक करुणा में अंतर कैसे पहचाना जाए? कृष्ण का उपदेश अगले अध्याय से आरम्भ होता है।','refs':'1.28–1.47','reflect':'क्या मैं कठिन निर्णय लेते समय पूरे धर्म-संदर्भ को देखता हूँ, या केवल तत्काल भावनाओं से निर्णय करता हूँ?'},
    2: {'teaching':'कृष्ण आत्मा की नित्यता और शरीर की परिवर्तनशीलता समझाते हैं। फिर समत्व-बुद्धि, निष्काम कर्म और स्थितप्रज्ञ के लक्षण बताते हैं। यहाँ सांख्य-दृष्टि और कर्मयोग की आधारभूमि मिलती है। फल की आसक्ति छोड़ने का अर्थ कर्म छोड़ना नहीं, बल्कि अपने अधिकार के क्षेत्र में सजग और समर्पित कर्म करना है।','refs':'2.11–2.30; 2.47–2.50; 2.55–2.72','reflect':'मेरे नियंत्रण में क्या है—प्रयास और निर्णय, या परिणाम की हर परिस्थिति?'},
    3: {'teaching':'कर्मयोग में कर्तव्य-कर्म को यज्ञभाव से करने और लोकसंग्रह अर्थात समाज के हित को ध्यान में रखने की शिक्षा है। केवल कर्म न करने से निष्कर्मता नहीं मिलती; प्रकृति के गुण सबको कर्म में प्रवृत्त करते हैं। आसक्ति और स्वार्थ छोड़कर उचित कर्म करना साधना का मार्ग बनता है।','refs':'3.4–3.9; 3.19–3. do; 3.20–3.26; 3.37–3.43','reflect':'मेरे काम से परिवार, समाज और दूसरे लोगों को क्या लाभ या हानि पहुँचती है?'},
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
        const Card(child: ListTile(leading: Icon(Icons.menu_book), title: Text('श्लोक-दर-श्लोक सामग्री'), subtitle: Text('प्रमाणित मूलपाठ, पदच्छेद, शब्दार्थ और संदर्भित हिंदी व्याख्या अगले कंटेंट पैक में जोड़ी जाएगी। अभी अप्रमाणित श्लोक-सामग्री नहीं दिखाई जाती।'))),
      ]),
    );
  }
}
