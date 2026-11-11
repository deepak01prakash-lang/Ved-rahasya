import 'package:flutter/material.dart';

class BhaktiText {
  const BhaktiText({required this.title, required this.deity, required this.kind, required this.content});
  final String title;
  final String deity;
  final String kind;
  final String content;
}

const bhaktiTexts = <BhaktiText>[
  BhaktiText(
    title: 'श्री हनुमान चालीसा', deity: 'हनुमान जी', kind: 'चालीसा',
    content: '''॥ दोहा ॥
श्रीगुरु चरन सरोज रज, निज मनु मुकुरु सुधारि।
बरनऊँ रघुबर बिमल जसु, जो दायकु फल चारि॥
बुद्धिहीन तनु जानिके, सुमिरौं पवन-कुमार।
बल बुद्धि विद्या देहु मोहिं, हरहु कलेस बिकार॥

॥ चौपाई ॥
जय हनुमान ज्ञान गुन सागर।
जय कपीस तिहुँ लोक उजागर॥
राम दूत अतुलित बल धामा।
अंजनि-पुत्र पवनसुत नामा॥
महाबीर बिक्रम बजरंगी।
कुमति निवार सुमति के संगी॥
कंचन बरन बिराज सुबेसा।
कानन कुंडल कुंचित केसा॥
हाथ बज्र औ ध्वजा बिराजै।
काँधे मूँज जनेऊ साजै॥
शंकर सुवन केसरी नंदन।
तेज प्रताप महा जग वंदन॥
विद्यावान गुनी अति चातुर।
राम काज करिबे को आतुर॥
प्रभु चरित्र सुनिबे को रसिया।
राम लखन सीता मन बसिया॥
सूक्ष्म रूप धरि सियहिं दिखावा।
बिकट रूप धरि लंक जरावा॥
भीम रूप धरि असुर सँहारे।
रामचंद्र के काज सँवारे॥
लाय सजीवन लखन जियाये।
श्रीरघुबीर हरषि उर लाये॥
रघुपति कीन्ही बहुत बड़ाई।
तुम मम प्रिय भरतहि सम भाई॥
सहस बदन तुम्हरो जस गावैं।
अस कहि श्रीपति कंठ लगावैं॥
सनकादिक ब्रह्मादि मुनीसा।
नारद सारद सहित अहीसा॥
जम कुबेर दिगपाल जहाँ ते।
कवि कोविद कहि सके कहाँ ते॥
तुम उपकार सुग्रीवहिं कीन्हा।
राम मिलाय राज पद दीन्हा॥
तुम्हरो मंत्र विभीषण माना।
लंकेश्वर भए सब जग जाना॥
जुग सहस्र जोजन पर भानू।
लील्यो ताहि मधुर फल जानू॥
प्रभु मुद्रिका मेलि मुख माहीं।
जलधि लाँघि गये अचरज नाहीं॥
दुर्गम काज जगत के जेते।
सुगम अनुग्रह तुम्हरे तेते॥
राम दुआरे तुम रखवारे।
होत न आज्ञा बिनु पैसारे॥
सब सुख लहै तुम्हारी सरना।
तुम रक्षक काहू को डरना॥
आपन तेज सम्हारो आपै।
तीनों लोक हाँक तें काँपै॥
भूत पिशाच निकट नहिं आवै।
महाबीर जब नाम सुनावै॥
नासै रोग हरै सब पीरा।
जपत निरंतर हनुमत बीरा॥
संकट तें हनुमान छुड़ावै।
मन क्रम बचन ध्यान जो लावै॥
सब पर राम तपस्वी राजा।
तिनके काज सकल तुम साजा॥
और मनोरथ जो कोई लावै।
सोइ अमित जीवन फल पावै॥
चारों जुग परताप तुम्हारा।
है परसिद्ध जगत उजियारा॥
साधु संत के तुम रखवारे।
असुर निकंदन राम दुलारे॥
अष्ट सिद्धि नौ निधि के दाता।
अस बर दीन जानकी माता॥
राम रसायन तुम्हरे पासा।
सदा रहो रघुपति के दासा॥
तुम्हरे भजन राम को पावै।
जनम जनम के दुख बिसरावै॥
अंतकाल रघुबर पुर जाई।
जहाँ जन्म हरिभक्त कहाई॥
और देवता चित्त न धरई।
हनुमत सेइ सर्व सुख करई॥
संकट कटै मिटै सब पीरा।
जो सुमिरै हनुमत बलबीरा॥
जय जय जय हनुमान गोसाईं।
कृपा करहु गुरुदेव की नाईं॥
जो सत बार पाठ कर कोई।
छूटहि बंदि महा सुख होई॥
जो यह पढ़ै हनुमान चालीसा।
होय सिद्धि साखी गौरीसा॥
तुलसीदास सदा हरि चेरा।
कीजै नाथ हृदय महँ डेरा॥

॥ दोहा ॥
पवनतनय संकट हरन, मंगल मूरति रूप।
राम लखन सीता सहित, हृदय बसहु सुर भूप॥''',
  ),
  BhaktiText(
    title: 'जय गणेश देवा आरती', deity: 'श्री गणेश जी', kind: 'आरती',
    content: '''जय गणेश, जय गणेश, जय गणेश देवा।
माता जाकी पार्वती, पिता महादेवा॥

एकदंत दयावंत, चार भुजाधारी।
माथे सिंदूर सोहे, मूसे की सवारी॥

पान चढ़े, फूल चढ़े और चढ़े मेवा।
लड्डुअन का भोग लगे, संत करें सेवा॥

अंधन को आँख देत, कोढ़िन को काया।
बाँझन को पुत्र देत, निर्धन को माया॥

हार चढ़े, फूल चढ़े और चढ़े मेवा।
लड्डुअन का भोग लगे, संत करें सेवा॥

दीनन की लाज रखो, शंभु-सुतवारी।
कामना पूर्ण करो, जग बलिहारी॥

जय गणेश, जय गणेश, जय गणेश देवा।
माता जाकी पार्वती, पिता महादेवा॥''',
  ),
  BhaktiText(
    title: 'ॐ जय शिव ओंकारा आरती', deity: 'भगवान शिव', kind: 'आरती',
    content: '''ॐ जय शिव ओंकारा, स्वामी जय शिव ओंकारा।
ब्रह्मा विष्णु सदाशिव, अर्द्धांगी धारा॥

एकानन चतुरानन पंचानन राजे।
हंसासन गरुड़ासन वृषवाहन साजे॥

दो भुज चार चतुर्भुज दशभुज ते सोहे।
तीनों रूप निरखता त्रिभुवन जन मोहे॥

अक्षमाला वनमाला मुण्डमाला धारी।
चंदन मृगमद सोहै, भाले शशिधारी॥

श्वेताम्बर पीताम्बर बाघम्बर अंगे।
सनकादिक गरुणादिक भूतादिक संगे॥

करमध्ये कमंडलु चक्र त्रिशूलधारी।
सुखकर्ता दुखहर्ता जगपालनकारी॥

ब्रह्मा विष्णु सदाशिव जानत अविवेका।
प्रणवाक्षर ॐ मध्ये ये तीनों एका॥

त्रिगुण स्वामी की आरति जो कोई नर गावे।
भक्तिपूर्वक हृदय से, मनवांछित फल पावे॥

ॐ जय शिव ओंकारा, स्वामी जय शिव ओंकारा।
ब्रह्मा विष्णु सदाशिव, अर्द्धांगी धारा॥''',
  ),
  BhaktiText(
    title: 'अम्बे तू है जगदम्बे काली आरती', deity: 'माँ दुर्गा', kind: 'आरती',
    content: '''अम्बे तू है जगदम्बे काली, जय दुर्गे खप्पर वाली।
तेरे ही गुण गावें भारती, ओ मैया हम सब उतारें तेरी आरती॥

तेरे भक्त जनों पर माता, भीर पड़ी है भारी।
दानव दल पर टूट पड़ो माँ, करके सिंह सवारी॥

सौ-सौ सिंहों से बलशाली, है अष्ट भुजाओं वाली।
दुष्टों को पल में संहारती, ओ मैया हम सब उतारें तेरी आरती॥

माँ-बेटे का है इस जग में, बड़ा ही निर्मल नाता।
पूत-कपूत सुने हैं पर न माता सुनी कुमाता॥

सब पे करुणा दर्शाने वाली, अमृत बरसाने वाली।
दुखियों के दुखड़े निवारती, ओ मैया हम सब उतारें तेरी आरती॥

नहीं माँगते धन और दौलत, न चाँदी न सोना।
हम तो माँगें माँ तेरे मन में, एक छोटा सा कोना॥

सबकी बिगड़ी बनाने वाली, लाज बचाने वाली।
सतियों के सत को सँवारती, ओ मैया हम सब उतारें तेरी आरती॥''',
  ),
  BhaktiText(
    title: 'ॐ जय लक्ष्मी माता आरती', deity: 'माँ लक्ष्मी', kind: 'आरती',
    content: '''ॐ जय लक्ष्मी माता, मैया जय लक्ष्मी माता।
तुमको निशदिन सेवत, हरि विष्णु विधाता॥

उमा, रमा, ब्रह्माणी, तुम ही जग-माता।
सूर्य-चंद्रमा ध्यावत, नारद ऋषि गाता॥

दुर्गा रूप निरंजनि, सुख-संपत्ति दाता।
जो कोई तुमको ध्याता, ऋद्धि-सिद्धि धन पाता॥

तुम पाताल निवासिनि, तुम ही शुभदाता।
कर्म-प्रभाव-प्रकाशिनि, भवनिधि की त्राता॥

जिस घर में तुम रहतीं, सब सद्गुण आता।
सब संभव हो जाता, मन नहीं घबराता॥

तुम बिन यज्ञ न होते, वस्त्र न कोई पाता।
खान-पान का वैभव, सब तुमसे आता॥

शुभ-गुण मंदिर सुंदर, क्षीरोदधि-जाता।
रत्न चतुर्दश तुम बिन, कोई नहीं पाता॥

ॐ जय लक्ष्मी माता, मैया जय लक्ष्मी माता।
तुमको निशदिन सेवत, हरि विष्णु विधाता॥''',
  ),
  BhaktiText(
    title: 'सरस्वती वंदना', deity: 'माँ सरस्वती', kind: 'स्तुति',
    content: '''या कुन्देन्दुतुषारहारधवला या शुभ्रवस्त्रावृता।
या वीणावरदण्डमण्डितकरा या श्वेतपद्मासना॥
या ब्रह्माच्युतशंकरप्रभृतिभिर्देवैः सदा वन्दिता।
सा मां पातु सरस्वती भगवती निःशेषजाड्यापहा॥

ॐ ऐं सरस्वत्यै नमः।
हे माँ सरस्वती, हमें सद्बुद्धि, विद्या, विवेक और मधुर वाणी प्रदान करें।''',
  ),
];

class BhaktiLibraryPage extends StatefulWidget {
  const BhaktiLibraryPage({super.key});

  @override
  State<BhaktiLibraryPage> createState() => _BhaktiLibraryPageState();
}

class _BhaktiLibraryPageState extends State<BhaktiLibraryPage> {
  String filter = 'सभी';
  String query = '';

  @override
  Widget build(BuildContext context) {
    final items = bhaktiTexts.where((item) {
      final matchesFilter = filter == 'सभी' || item.kind == filter;
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.deity.toLowerCase().contains(query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('चालीसा और आरती')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF492A17), Color(0xFF9B5B25)],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('भक्ति पाठ संग्रह',
                    style: TextStyle(color: Color(0xFFFFD98A), fontSize: 21, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('प्रमुख देवी-देवताओं की आरती, चालीसा और स्तुति पढ़ें।',
                    style: TextStyle(color: Colors.white, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'देवता या पाठ खोजें',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => query = value.trim()),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['सभी', 'चालीसा', 'आरती', 'स्तुति'].map((value) {
              return ChoiceChip(
                label: Text(value),
                selected: filter == value,
                onSelected: (_) => setState(() => filter = value),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFE8C2),
                    child: Icon(
                      item.kind == 'चालीसा' ? Icons.menu_book : Icons.local_fire_department,
                      color: const Color(0xFF754414),
                    ),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${item.deity} • ${item.kind}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BhaktiReaderPage(item: item),
                  )),
                ),
              )),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('इस खोज से मिलता-जुलता पाठ नहीं मिला।')),
            ),
          const SizedBox(height: 12),
          const Text(
            'नोट: यह प्रारंभिक पाठ-संग्रह है। अलग-अलग क्षेत्रों और परंपराओं में आरती/पाठ के शब्दों में अंतर मिल सकता है। आगे अन्य देवी-देवताओं के प्रमाणित पाठ जोड़े जाएंगे।',
            style: TextStyle(color: Colors.brown, height: 1.45, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class BhaktiReaderPage extends StatelessWidget {
  const BhaktiReaderPage({super.key, required this.item});
  final BhaktiText item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(item.deity,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF754414))),
          const SizedBox(height: 6),
          Text(item.kind, textAlign: TextAlign.center, style: TextStyle(color: Colors.brown.shade500)),
          const Divider(height: 28),
          SelectableText(
            item.content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, height: 2, color: Color(0xFF382012)),
          ),
        ],
      ),
    );
  }
}
