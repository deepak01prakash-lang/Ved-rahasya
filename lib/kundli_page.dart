import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'astrology/vedic_kundli_engine.dart';

class KundliPage extends StatefulWidget {
  const KundliPage({super.key});
  @override
  State<KundliPage> createState() => _KundliPageState();
}

class _KundliPageState extends State<KundliPage> {
  bool loading = true;
  String? error;
  VedicKundli? chart;
  String birthPlace = '';
  DateTime? birthUtc;
  static const rashis = VedicLunarPosition.rashis;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  int? _parseOffset(String value) {
    final match = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final hours = int.parse(match.group(2)!);
    final minutes = int.parse(match.group(3)!);
    if (hours > 14 || minutes > 59 || (hours == 14 && minutes != 0)) return null;
    final total = hours * 60 + minutes;
    return match.group(1) == '-' ? -total : total;
  }

  Future<void> _calculate() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final dateRaw = prefs.getString('profile_birth_date');
      final timeRaw = prefs.getString('profile_birth_time');
      final offset = _parseOffset(prefs.getString('profile_utc_offset') ?? '+05:30');
      final lat = double.tryParse(prefs.getString('profile_latitude') ?? '');
      final lon = double.tryParse(prefs.getString('profile_longitude') ?? '');
      birthPlace = prefs.getString('profile_birth_place') ?? '';
      if (dateRaw == null || timeRaw == null) {
        throw const FormatException('पहले जन्मतिथि और जन्म का सही समय सेव करें।');
      }
      if (offset == null) throw const FormatException('UTC Offset सही नहीं है। उदाहरण: +05:30');
      if (lat == null || lon == null || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
        throw const FormatException('कुंडली के लिए सही Latitude और Longitude भरकर सेव करें।');
      }
      final date = DateTime.parse(dateRaw);
      final parts = timeRaw.split(':');
      if (parts.length != 2) throw const FormatException('जन्म समय सही नहीं है।');
      final localAsUtc = DateTime.utc(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
      birthUtc = localAsUtc.subtract(Duration(minutes: offset));
      chart = const VedicKundliEngine().calculate(
        birthUtc: birthUtc!, latitude: lat, longitudeEast: lon,
      );
    } catch (e) {
      error = e.toString().replaceFirst('FormatException: ', '');
    }
    if (mounted) setState(() => loading = false);
  }

  String _degree(double value) {
    final d = value.floor();
    final m = ((value - d) * 60).floor();
    final s = (((value - d) * 60 - m) * 60).round();
    return '$d° $m′ $s″';
  }

  String _date(DateTime value) {
    final d = value.toUtc();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Widget _sectionTitle(String title, String subtitle) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF492A17))),
      const SizedBox(height: 3),
      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.brown.shade500)),
    ]),
  );

  Widget _houseCard(int house, int sign, List<GrahaPosition> occupants) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: house == 1 ? const Color(0xFFFFE9C5) : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5CFB2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('भाव $house', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B4D20))),
        const SizedBox(height: 3),
        Text(rashis[sign], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 5),
        Expanded(child: Text(
          occupants.isEmpty ? '—' : occupants.map((g) => g.name + (g.isRetrograde ? ' व.' : '')).join('  '),
          style: const TextStyle(fontSize: 11, height: 1.35),
          overflow: TextOverflow.fade,
        )),
      ]),
    );
  }

  Widget _chartGrid(int ascendantSign, {required bool navamsha}) {
    final c = chart!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 1.12, crossAxisSpacing: 7, mainAxisSpacing: 7,
        ),
        itemBuilder: (context, index) {
          final sign = (ascendantSign + index) % 12;
          final occupants = c.grahas.where((g) =>
            (navamsha ? c.navamshaSign(g.longitude) : g.rashiIndex) == sign).toList();
          return _houseCard(index + 1, sign, occupants);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null || chart == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('पूर्ण वैदिक कुंडली')),
        body: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.info_outline, size: 42, color: Colors.brown),
            const SizedBox(height: 12),
            Text(error ?? 'कुंडली की गणना नहीं हो सकी।', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('जन्म विवरण सुधारें')),
          ]),
        )),
      );
    }

    final c = chart!;
    final d9Asc = c.navamshaSign(c.lagnaLongitude);
    final dasha = c.vimshottari.mahadashas;
    final now = DateTime.now().toUtc();
    final active = dasha.where((p) => !now.isBefore(p.start) && now.isBefore(p.end)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('मेरी वैदिक जन्म-कुंडली')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(colors: [Color(0xFF492A17), Color(0xFF9B5B25)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('लाहिरी अयनांश • वैदिक ज्योतिष', style: TextStyle(color: Color(0xFFFFD98A), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('लग्न: ${rashis[c.lagnaRashiIndex]}', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('चंद्र राशि: ${c.moon.rashi}  •  नक्षत्र: ${c.moon.nakshatra} (${c.moon.nakshatraPada})',
                style: const TextStyle(color: Colors.white, height: 1.5)),
              Text('जन्म स्थान: ${birthPlace.isEmpty ? 'स्थान नहीं भरा' : birthPlace}',
                style: const TextStyle(color: Color(0xFFFFE8BE), fontSize: 12)),
              Text('जन्म UTC: ${birthUtc!.toIso8601String()}',
                style: const TextStyle(color: Color(0xFFFFE8BE), fontSize: 11)),
            ]),
          ),
          _sectionTitle('D1 • राशि / लग्न कुंडली', 'उत्तर भारतीय whole-sign भाव व्यवस्था • 12 भाव'),
          _chartGrid(c.lagnaRashiIndex, navamsha: false),
          _sectionTitle('ग्रह स्थिति', 'निरयण longitude • लाहिरी mean अयनांश'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Card(child: Column(children: [
              for (final g in c.grahas)
                ListTile(
                  dense: true,
                  title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${rashis[g.rashiIndex]} • ${_degree(g.degreesInRashi)}'),
                  trailing: Text(g.isRetrograde ? 'वक्री' : 'मार्गी',
                    style: TextStyle(fontSize: 12, color: g.isRetrograde ? Colors.deepOrange : Colors.green.shade700)),
                ),
            ])),
          ),
          _sectionTitle('D9 • नवांश कुंडली', 'नवांश राशि विभाजन • प्रत्येक 3°20′ का एक भाग'),
          _chartGrid(d9Asc, navamsha: true),
          _sectionTitle('विंशोत्तरी महादशा', 'जन्म नक्षत्र के आधार पर पारंपरिक 120-वर्षीय दशा क्रम'),
          if (active.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Card(color: const Color(0xFFFFE9C5), child: ListTile(
                title: Text('वर्तमान महादशा: ${active.first.lord}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${_date(active.first.start)} – ${_date(active.first.end)}'),
              )),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Card(child: Column(children: [
              for (final period in dasha)
                ExpansionTile(
                  title: Text('${period.lord} महादशा', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${_date(period.start)} – ${_date(period.end)}'),
                  children: [
                    for (final sub in c.vimshottari.antardashas(period))
                      ListTile(
                        dense: true,
                        title: Text('${period.lord} / ${sub.lord}'),
                        subtitle: Text('${_date(sub.start)} – ${_date(sub.end)}'),
                      ),
                  ],
                ),
            ])),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(14, 16, 14, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFF1D9), borderRadius: BorderRadius.circular(14)),
            child: const Text(
              'गणना की सीमा: यह प्रारंभिक ऑफलाइन मॉडल Meeus/VSOP87 ग्रह स्थितियों, mean Lahiri अयनांश, mean Rahu-Ketu और whole-sign भावों पर आधारित है। D9 और विंशोत्तरी क्रम जोड़े गए हैं। D2–D60 के शेष वर्ग, भाव-चलित/श्रीपति, true node, दशा सूक्ष्म-स्तर और स्वतंत्र पंचांग/Swiss Ephemeris cross-validation अभी शेष हैं। परिणाम को प्रमाणित पेशेवर पंचांग या निश्चित भविष्यवाणी न मानें।',
              style: TextStyle(fontSize: 12, height: 1.55, color: Color(0xFF68431F)),
            ),
          ),
        ],
      ),
    );
  }
}
