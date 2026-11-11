import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'astrology/panchang_engine.dart';

class PanchangPage extends StatefulWidget {
  const PanchangPage({super.key});
  @override
  State<PanchangPage> createState() => _PanchangPageState();
}

class _PanchangPageState extends State<PanchangPage> {
  late Future<DailyPanchang> _future;
  String _place = '';

  @override
  void initState() {
    super.initState();
    _future = _loadPanchang();
  }

  Future<DailyPanchang> _loadPanchang() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('profile_latitude');
    final longitude = prefs.getDouble('profile_longitude');
    _place = prefs.getString('profile_birth_place') ?? 'सहेजा गया जन्म-स्थान';
    if (latitude == null || longitude == null) {
      throw StateError('पंचांग दिखाने के लिए पहले मेरी जन्म-कुंडली में जन्म-स्थान खोजकर सहेजें।');
    }
    final now = DateTime.now();
    return const PanchangEngine().calculate(
      localDate: DateTime(now.year, now.month, now.day),
      latitude: latitude,
      longitudeEast: longitude,
      utcOffset: now.timeZoneOffset,
    );
  }

  String _time(DateTime? value) {
    if (value == null) return 'उपलब्ध नहीं';
    final hour = value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return h.toString() + ':' + minute + ' ' + suffix;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('दैनिक पंचांग')),
      body: FutureBuilder<DailyPanchang>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 42, color: Color(0xFF8B4D20)),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error?.toString().replaceFirst('Bad state: ', '') ?? 'पंचांग लोड नहीं हो सका।',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () => setState(() => _future = _loadPanchang()),
                      child: const Text('दोबारा प्रयास करें'),
                    ),
                  ],
                ),
              ),
            );
          }
          final p = snapshot.data!;
          final date = p.localDate.day.toString().padLeft(2, '0') + '/' +
              p.localDate.month.toString().padLeft(2, '0') + '/' +
              p.localDate.year.toString();
          final items = <(String, String, IconData)>[
            ('तिथि', p.tithiPaksha + ' • ' + p.tithi, Icons.calendar_today),
            ('वार', p.vara, Icons.wb_sunny_outlined),
            ('नक्षत्र', p.nakshatra, Icons.star_outline),
            ('योग', p.yoga, Icons.auto_awesome_outlined),
            ('करण', p.karana, Icons.brightness_5_outlined),
          ];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: const Color(0xFF492A17),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('॥ श्री गणेशाय नमः ॥',
                        style: TextStyle(color: Color(0xFFFFD98A), fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(date, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text('स्थान: ' + _place, style: const TextStyle(color: Color(0xFFFFE8BE), fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text('गणना सूर्योदय के समय के आधार पर',
                        style: TextStyle(color: Color(0xFFFFD98A), fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('सूर्योदय', style: TextStyle(color: Colors.brown)),
                        const SizedBox(height: 5),
                        Text(_time(p.sunriseLocal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ])),
                      Container(width: 1, height: 48, color: const Color(0xFFEADBC5)),
                      const SizedBox(width: 18),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('सूर्यास्त', style: TextStyle(color: Colors.brown)),
                        const SizedBox(height: 5),
                        Text(_time(p.sunsetLocal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFF0D7),
                    child: Icon(item.$3, color: const Color(0xFF8B4D20)),
                  ),
                  title: Text(item.$1, style: const TextStyle(fontSize: 12, color: Colors.brown)),
                  subtitle: Text(item.$2, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF422716))),
                ),
              )),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'नोट: तिथि, नक्षत्र, योग और करण सूर्योदय के निकट गणितीय स्थिति से निकाले गए हैं। सूर्योदय/सूर्यास्त NOAA-शैली के खगोलीय अनुमान हैं; स्थानीय पंचांग, ऊँचाई, वायुमंडलीय अपवर्तन और परंपरा-विशेष के कारण कुछ मिनट या सीमा-अंतर हो सकता है। शुभ मुहूर्त या धार्मिक निर्णय के लिए स्थानीय प्रमाणित पंचांग से मिलान करें।',
                    style: TextStyle(fontSize: 12, height: 1.6, color: Colors.brown),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _future = _loadPanchang()),
                icon: const Icon(Icons.refresh),
                label: const Text('पंचांग ताज़ा करें'),
              ),
            ],
          );
        },
      ),
    );
  }
}
