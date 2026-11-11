import 'package:flutter_test/flutter_test.dart';
import 'package:ved_rahasya/bhakti_library_page.dart';

void main() {
  group('Bhakti library', () {
    test('includes Hanuman, Ganesh, Durga and Shiva chalisas', () {
      final chalisas = bhaktiTexts.where((item) => item.kind == 'चालीसा');
      final titles = chalisas.map((item) => item.title).toSet();

      expect(titles, contains('श्री हनुमान चालीसा'));
      expect(titles, contains('श्री गणेश चालीसा'));
      expect(titles, contains('श्री दुर्गा चालीसा'));
      expect(titles, contains('श्री शिव चालीसा'));
    });

    test('newly added chalisas include source attribution', () {
      final sourcedTitles = bhaktiTexts
          .where((item) => item.kind == 'चालीसा' && item.source != null)
          .map((item) => item.title)
          .toSet();

      expect(sourcedTitles, contains('श्री गणेश चालीसा'));
      expect(sourcedTitles, contains('श्री दुर्गा चालीसा'));
      expect(sourcedTitles, contains('श्री शिव चालीसा'));
    });
  });
}
