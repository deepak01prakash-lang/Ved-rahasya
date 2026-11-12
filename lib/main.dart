import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rashi_profile_page.dart';
import 'bhakti_library_page.dart';
import 'panchang_page.dart';
import 'meditation_page.dart';
import 'account_page.dart';
import 'firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
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
      home: const SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;
  bool _musicEnabled = true;
  bool _ready = false;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _startIntro();
  }

  Future<void> _startIntro() async {
    final prefs = await SharedPreferences.getInstance();
    _musicEnabled = prefs.getBool('intro_music_enabled') ?? true;
    if (!mounted) return;
    setState(() => _ready = true);
    if (_musicEnabled) {
      try {
        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.setVolume(0.32);
        await _player.play(AssetSource('audio/ved_rahasya_theme.wav'));
      } catch (_) {
        // The splash and navigation remain usable if audio is unavailable.
      }
    }
    _timer = Timer(const Duration(milliseconds: 5500), _openHome);
  }

  Future<void> _toggleMusic() async {
    final next = !_musicEnabled;
    setState(() => _musicEnabled = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_music_enabled', next);
    if (next) {
      try {
        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.setVolume(0.32);
        await _player.play(AssetSource('audio/ved_rahasya_theme.wav'));
      } catch (_) {}
    } else {
      await _player.stop();
    }
  }

  void _openHome() {
    if (_opened || !mounted) return;
    _opened = true;
    _timer?.cancel();
    _player.stop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF160D09), Color(0xFF492A17), Color(0xFF8B4D20)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD98A), width: 1.5),
                  color: const Color(0x22FFD98A),
                ),
                child: const Icon(Icons.temple_hindu_rounded,
                    color: Color(0xFFFFD98A), size: 62),
              ),
              const SizedBox(height: 28),
              const Text('॥ ॐ ॥',
                  style: TextStyle(color: Color(0xFFFFD98A), fontSize: 28)),
              const SizedBox(height: 12),
              const Text('वेद रहस्य',
                  style: TextStyle(
                    color: Color(0xFFFFE8BE),
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  )),
              const SizedBox(height: 9),
              const Text('VED RAHASYA',
                  style: TextStyle(
                    color: Color(0xFFFFD98A),
                    fontSize: 13,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w500,
                  )),
              const SizedBox(height: 20),
              const Text('भक्ति  •  शांति  •  ज्योतिष',
                  style: TextStyle(color: Color(0xFFFFE8BE), fontSize: 13)),
              const Spacer(),
              if (_ready)
                TextButton.icon(
                  onPressed: _toggleMusic,
                  icon: Icon(
                    _musicEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: const Color(0xFFFFD98A),
                  ),
                  label: Text(
                    _musicEnabled ? 'परिचय संगीत बंद करें' : 'परिचय संगीत चालू करें',
                    style: const TextStyle(color: Color(0xFFFFE8BE)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 26, top: 4),
                child: TextButton(
                  onPressed: _openHome,
                  child: const Text('आगे बढ़ें  ›',
                      style: TextStyle(
                        color: Color(0xFFFFD98A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
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
  final Set<String> bookmarks = {};
  Map<String, int> japHistory = {};
  bool japLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDailyJap();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_bookmarks') ?? <String>[];
    final rawHistory = prefs.getString('jap_history') ?? '{}';
    Map<String, int> history = {};
    try {
      final decoded = jsonDecode(rawHistory) as Map<String, dynamic>;
      history = decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      bookmarks
        ..clear()
        ..addAll(saved);
      japHistory = history;
    });
  }

  Future<void> _toggleBookmark(String key) async {
    setState(() {
      if (!bookmarks.add(key)) bookmarks.remove(key);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_bookmarks', bookmarks.toList());
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
    japHistory[_todayKey()] = japCount;
    await prefs.setString('jap_history', jsonEncode(japHistory));
  }

  String tr(String hi, String sa, String en) =>
      language == 'English' ? en : language == 'संस्कृत' ? sa : hi;

  @override
  Widget build(BuildContext context) {
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
            tooltip: 'यूज़र अकाउंट / Login',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AccountPage()),
            ),
          ),
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
      body: SafeArea(child: _home()),
    );
  }

  Widget _home() {
    Widget sectionCard({
      required String title,
      required String subtitle,
      required IconData icon,
      required Color tint,
      required VoidCallback onTap,
      String? tag,
    }) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFEADBC5)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(icon, color: tint, size: 29),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(title, style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: Color(0xFF422716),
                        ))),
                        if (tag != null) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0D7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(tag, style: const TextStyle(
                            fontSize: 9, color: Color(0xFF8B4D20),
                            fontWeight: FontWeight.bold,
                          )),
                        ),
                      ]),
                      const SizedBox(height: 5),
                      Text(subtitle, style: TextStyle(
                        fontSize: 12, height: 1.35, color: Colors.brown.shade500,
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF9B744B), size: 25),
              ],
            ),
          ),
        ),
      );
    }

    Widget heading(String title, String subtitle) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 11),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF422716),
        )),
        const SizedBox(height: 3),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.brown.shade500)),
      ]),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
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
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xFFE8D7BF)),
            ),
            child: const Row(children: [
              Icon(Icons.search_rounded, color: Color(0xFF8B4D20)),
              SizedBox(width: 10),
              Expanded(child: Text('मंत्र, श्लोक, पूजा-विधि या विषय खोजें',
                style: TextStyle(color: Color(0xFF806B58), fontSize: 13))),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF8B4D20)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            gradient: const LinearGradient(
              colors: [Color(0xFF1D120D), Color(0xFF573018), Color(0xFFA7662B)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            boxShadow: const [BoxShadow(
              color: Color(0x3324150F), blurRadius: 20, offset: Offset(0, 8),
            )],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x33FFD98A), borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.temple_hindu_rounded, color: Color(0xFFFFD98A), size: 29),
              ),
              const Spacer(),
              const Text('भक्ति  •  शांति  •  ज्योतिष',
                style: TextStyle(color: Color(0xFFFFE5B5), fontSize: 11, letterSpacing: 1)),
            ]),
            const SizedBox(height: 20),
            const Text('॥ ॐ ॥', style: TextStyle(
              color: Color(0xFFFFD98A), fontSize: 34, fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 7),
            const Text('भक्ति और शांति का\nआपका अपना केंद्र',
              style: TextStyle(color: Colors.white, fontSize: 27, height: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 9),
            const Text('भगवान के वॉलपेपर, आरती, भजन और ध्यान के साथ अपनी दिनचर्या को भक्तिमय बनाएँ।',
              style: TextStyle(color: Color(0xFFFFEBD0), height: 1.5, fontSize: 13)),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD98A),
                foregroundColor: const Color(0xFF382012),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BhaktiLibraryPage()),
              ),
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('आरती और चालीसा देखें'),
            ),
          ]),
        ),
        heading('ज्योतिष एवं पंचांग', 'अपनी जन्म-कुंडली और दैनिक ज्योतिषीय जानकारी'),
        sectionCard(
          title: 'मेरी जन्म-कुंडली',
          subtitle: 'जन्म विवरण • चंद्र राशि • नक्षत्र • लग्न • ग्रह स्थिति',
          icon: Icons.nightlight_round, tint: const Color(0xFF6B4AA1),
          tag: 'लाहिरी',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RashiProfilePage()),
          ),
        ),
        const SizedBox(height: 10),
        sectionCard(
          title: 'दैनिक पंचांग',
          subtitle: 'तिथि • वार • नक्षत्र • योग • करण • सूर्योदय/सूर्यास्त',
          icon: Icons.calendar_month_rounded, tint: const Color(0xFF287A68),
          tag: 'सूर्योदय आधारित',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PanchangPage()),
          ),
        ),
        heading('भक्ति मीडिया', 'वॉलपेपर • रिंगटोन • आरती • ध्यान संगीत'),
        sectionCard(
          title: 'भगवान के वॉलपेपर',
          subtitle: 'HD भक्ति वॉलपेपर • डाउनलोड और शेयर',
          icon: Icons.wallpaper_rounded, tint: const Color(0xFF9B5B25),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const MediaComingSoonPage(
              title: 'भगवान के वॉलपेपर',
              description: 'शिव, श्रीराम, श्रीकृष्ण, हनुमानजी, माता रानी और अन्य देवी-देवताओं के HD वॉलपेपर यहाँ उपलब्ध होंगे।',
              icon: Icons.wallpaper_rounded,
            ),
          )),
        ),
        const SizedBox(height: 10),
        sectionCard(
          title: 'भक्ति रिंगटोन',
          subtitle: 'मंत्र • शंख • मंदिर की घंटी • भक्ति धुन',
          icon: Icons.notifications_active_rounded, tint: const Color(0xFFB47724),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const MediaComingSoonPage(
              title: 'भक्ति रिंगटोन',
              description: 'मंत्र, शंख, मंदिर की घंटी और छोटी भक्ति धुनों की रिंगटोन यहाँ जोड़ी जाएँगी।',
              icon: Icons.notifications_active_rounded,
            ),
          )),
        ),
        const SizedBox(height: 10),
        heading('भक्ति एवं साधना', 'देवी-देवताओं के पाठ और दैनिक अभ्यास'),
        sectionCard(
          title: 'चालीसा और आरती',
          subtitle: 'देवी-देवता चुनें और उनका पाठ अलग से पढ़ें',
          icon: Icons.local_fire_department_rounded, tint: const Color(0xFFB65A36),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BhaktiLibraryPage()),
          ),
        ),
        const SizedBox(height: 10),
        sectionCard(
          title: 'मंत्र एवं जाप',
          subtitle: 'मंत्र संग्रह • जाप काउंटर • दैनिक प्रगति',
          icon: Icons.spa_rounded, tint: const Color(0xFF34806D),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const DharmaSearchPage(),
          )),
        ),
        const SizedBox(height: 10),
        sectionCard(
          title: 'ध्यान साधना',
          subtitle: 'श्वास अभ्यास • एकाग्रता • ध्यान संगीत जल्द उपलब्ध',
          icon: Icons.self_improvement, tint: const Color(0xFF647D9C),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MeditationPage()),
          ),
        ),
        heading('आज की साधना', 'अपनी दैनिक प्रगति जारी रखें'),
        Card(
          elevation: 0,
          color: const Color(0xFFFFF0D7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFEBD5B2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE2B5), borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.spa_rounded, color: Color(0xFF8B4D20), size: 29),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ॐ नमः शिवाय', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF633718),
                )),
                Text(japLoaded ? '$japCount जाप आज' : 'गिनती लोड हो रही है…',
                  style: TextStyle(color: Colors.brown.shade500, fontSize: 12)),
              ])),
              IconButton(onPressed: () => _changeJap(0), tooltip: 'रीसेट',
                icon: const Icon(Icons.refresh_rounded)),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF754414), foregroundColor: Colors.white,
                ),
                onPressed: japLoaded ? () => _changeJap(japCount + 1) : null,
                child: const Text('+1'),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0, color: Colors.white,
          child: ListTile(
            leading: const Icon(Icons.bookmark_outline, color: Color(0xFF8B4D20)),
            title: const Text('मेरे सहेजे हुए पाठ'),
            subtitle: const Text('बुकमार्क और अध्ययन सामग्री'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SavedItemsPage(savedGita247: bookmarks.contains('gita247')),
            )),
          ),
        ),
      ],
    );
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



class MediaComingSoonPage extends StatelessWidget {
  const MediaComingSoonPage({super.key, required this.title, required this.description, required this.icon});
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBCB),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(icon, size: 54, color: const Color(0xFF8B4D20)),
              ),
              const SizedBox(height: 22),
              Text(title, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xFF492A17))),
              const SizedBox(height: 10),
              Text(description, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.7, color: Colors.brown)),
              const SizedBox(height: 18),
              const Chip(avatar: Icon(Icons.hourglass_top_rounded, size: 18), label: Text('सामग्री जल्द जोड़ी जाएगी')),
            ],
          ),
        ),
      ),
    );
  }
}
