import 'astronomy_engine.dart';
import 'vedic_kundli_engine.dart';
import 'graha_drishti.dart';

class HouseInsight {
  const HouseInsight({
    required this.house,
    required this.theme,
    required this.rashi,
    required this.grahas,
  });

  final int house;
  final String theme;
  final String rashi;
  final List<String> grahas;
}

class TraditionalIndicator {
  const TraditionalIndicator({
    required this.name,
    required this.description,
    required this.isPresent,
    this.caution,
  });

  final String name;
  final String description;
  final bool isPresent;
  final String? caution;
}

class HouseLordInsight {
  const HouseLordInsight({
    required this.house,
    required this.rashi,
    required this.lord,
    required this.placedHouse,
    required this.placedHouseTheme,
    required this.dignity,
    required this.isRetrograde,
    required this.aspectedBy,
  });

  final int house;
  final String rashi;
  final String lord;
  final int placedHouse;
  final String placedHouseTheme;
  final String dignity;
  final bool isRetrograde;
  final List<String> aspectedBy;
}

class DashaLordInsight {
  const DashaLordInsight({
    required this.lord,
    required this.sign,
    required this.house,
    required this.dignity,
    required this.isRetrograde,
    required this.ruledHouses,
    required this.houseTheme,
  });

  final String lord;
  final String sign;
  final int house;
  final String dignity;
  final bool isRetrograde;
  final List<int> ruledHouses;
  final String houseTheme;
}

class KundliInterpretation {
  static const houseThemes = <String>[
    'स्वभाव, शरीर और जीवन-दृष्टि',
    'परिवार, वाणी, बचत और संसाधन',
    'साहस, प्रयास, कौशल और भाई-बहन',
    'घर, माता, शिक्षा और आंतरिक सुख',
    'शिक्षा, बुद्धि, रचनात्मकता और संतान',
    'सेवा, प्रतिस्पर्धा, ऋण और दैनिक अनुशासन',
    'विवाह, साझेदारी और सार्वजनिक व्यवहार',
    'परिवर्तन, शोध, साझा संसाधन और गूढ़ विषय',
    'धर्म, गुरु, उच्च शिक्षा और दीर्घ यात्राएँ',
    'कर्म, पेशा, प्रतिष्ठा और जिम्मेदारी',
    'लाभ, नेटवर्क, मित्र और दीर्घकालीन लक्ष्य',
    'व्यय, विश्राम, एकांत और आध्यात्मिक साधना',
  ];

  static const _rashiLords = <String>[
    'मंगल', 'शुक्र', 'बुध', 'चंद्र', 'सूर्य', 'बुध',
    'शुक्र', 'मंगल', 'गुरु', 'शनि', 'शनि', 'गुरु',
  ];

  static List<HouseLordInsight> houseLords(VedicKundli chart) {
    final strengths = {
      for (final item in GrahaDrishti.strengths(chart)) item.graha: item,
    };
    final aspects = GrahaDrishti.aspects(chart);
    return List.generate(12, (index) {
      final sign = (chart.lagnaRashiIndex + index) % 12;
      final lord = _rashiLords[sign];
      final planet = chart.grahas.firstWhere((g) => g.name == lord);
      final placedHouse =
          (planet.rashiIndex - chart.lagnaRashiIndex + 12) % 12 + 1;
      final received = aspects
          .where((aspect) => aspect.toHouse == index + 1)
          .map((aspect) => aspect.fromGraha)
          .toSet()
          .toList();
      return HouseLordInsight(
        house: index + 1,
        rashi: VedicLunarPosition.rashis[sign],
        lord: lord,
        placedHouse: placedHouse,
        placedHouseTheme: houseThemes[placedHouse - 1],
        dignity: strengths[lord]?.dignity ?? 'जाँच उपलब्ध नहीं',
        isRetrograde: planet.isRetrograde,
        aspectedBy: received,
      );
    });
  }

  /// Chart-specific context for a Vimshottari period lord. This is a
  /// traditional placement summary, not a deterministic prediction.
  static DashaLordInsight dashaLord(VedicKundli chart, String lord) {
    final planet = chart.grahas.firstWhere((g) => g.name == lord);
    final house = (planet.rashiIndex - chart.lagnaRashiIndex + 12) % 12 + 1;
    final ruled = <int>[];
    for (var index = 0; index < 12; index++) {
      if (_rashiLords[(chart.lagnaRashiIndex + index) % 12] == lord) {
        ruled.add(index + 1);
      }
    }
    final strength = GrahaDrishti.strengths(chart)
        .firstWhere((item) => item.graha == lord);
    return DashaLordInsight(
      lord: lord,
      sign: VedicLunarPosition.rashis[planet.rashiIndex],
      house: house,
      dignity: strength.dignity,
      isRetrograde: planet.isRetrograde,
      ruledHouses: List.unmodifiable(ruled),
      houseTheme: houseThemes[house - 1],
    );
  }

  static List<HouseInsight> houses(VedicKundli chart) {
    return List.generate(12, (index) {
      final sign = (chart.lagnaRashiIndex + index) % 12;
      final occupants = chart.grahas
          .where((g) => g.rashiIndex == sign)
          .map((g) => g.name + (g.isRetrograde ? ' (वक्री)' : ''))
          .toList();
      return HouseInsight(
        house: index + 1,
        theme: houseThemes[index],
        rashi: VedicLunarPosition.rashis[sign],
        grahas: occupants,
      );
    });
  }

  static List<TraditionalIndicator> indicators(VedicKundli chart) {
    GrahaPosition byName(String name) => chart.grahas.firstWhere((g) => g.name == name);
    final sun = byName('सूर्य');
    final moon = byName('चंद्र');
    final mars = byName('मंगल');
    final mercury = byName('बुध');
    final jupiter = byName('गुरु');

    int houseDistance(int fromSign, int toSign) => (toSign - fromSign + 12) % 12 + 1;
    final jupiterFromMoon = houseDistance(moon.rashiIndex, jupiter.rashiIndex);
    final marsFromLagna = houseDistance(chart.lagnaRashiIndex, mars.rashiIndex);
    final marsFromMoon = houseDistance(moon.rashiIndex, mars.rashiIndex);
    final manglikHouses = {1, 2, 4, 7, 8, 12};

    return [
      TraditionalIndicator(
        name: 'बुध-आदित्य योग',
        description: 'सूर्य और बुध एक ही राशि में हैं। पारंपरिक व्याख्या में बुद्धि, सीखने और अभिव्यक्ति से जोड़ा जाता है; वास्तविक फल भाव, अंश और अस्त स्थिति पर निर्भर करता है।',
        isPresent: sun.rashiIndex == mercury.rashiIndex,
      ),
      TraditionalIndicator(
        name: 'गजकेसरी योग',
        description: 'गुरु चंद्रमा से केंद्र (1, 4, 7 या 10) में है। पारंपरिक ज्योतिष में ज्ञान, मार्गदर्शन और प्रतिष्ठा से संबंधित माना जाता है; शक्ति और दोषों की जाँच अलग से आवश्यक है।',
        isPresent: {1, 4, 7, 10}.contains(jupiterFromMoon),
      ),
      TraditionalIndicator(
        name: 'चंद्र-मंगल योग',
        description: 'चंद्रमा और मंगल एक ही राशि में हैं। कुछ परंपराएँ इसे ऊर्जा, उद्यम और वित्तीय सक्रियता से जोड़ती हैं; भाव और ग्रहबल के अनुसार व्याख्या बदलती है।',
        isPresent: moon.rashiIndex == mars.rashiIndex,
      ),
      TraditionalIndicator(
        name: 'गुरु-मंगल योग',
        description: 'गुरु और मंगल एक ही राशि में हैं। पारंपरिक अर्थ में ज्ञान को कर्म में बदलने की क्षमता का संकेत माना जाता है।',
        isPresent: jupiter.rashiIndex == mars.rashiIndex,
      ),
      TraditionalIndicator(
        name: 'मांगलिक संकेत',
        description: 'मंगल लग्न या चंद्र राशि से पारंपरिक मांगलिक भावों में आता है। यह अकेले विवाह-विच्छेद या वैवाहिक समस्या का निष्कर्ष नहीं है; पूर्ण मिलान और क्षेत्रीय नियम आवश्यक हैं।',
        isPresent: manglikHouses.contains(marsFromLagna) || manglikHouses.contains(marsFromMoon),
        caution: 'मांगलिक नियम अलग-अलग ज्योतिष परंपराओं में बदलते हैं।',
      ),
    ];
  }
}
