import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('scripture catalog has transparent status for every listed work', () async {
    final raw = await rootBundle.loadString('assets/data/scripture_catalog.json');
    final catalog = jsonDecode(raw) as Map<String, dynamic>;
    final collections = (catalog['collections'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    expect(collections.length, 18);
    expect(collections.every((item) =>
        (item['id'] as String?)?.isNotEmpty == true &&
        (item['title_hi'] as String?)?.isNotEmpty == true &&
        (item['text_status'] as String?)?.isNotEmpty == true), isTrue);
    expect(
      collections.any((item) => item['id'] == 'bhagavad-gita'),
      isTrue,
    );
  });

  test('existing Gita Sanskrit corpus is readable and structurally indexed', () async {
    final raw = await rootBundle.loadString('assets/data/gita_verses.json');
    final verses = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();

    expect(verses.length, 701);
    expect(
      verses.every((verse) =>
          verse['chapter_number'] is int &&
          verse['verse_number'] is int &&
          (verse['text'] as String?)?.trim().isNotEmpty == true),
      isTrue,
    );

    final chapterNumbers = verses
        .map((verse) => verse['chapter_number'] as int)
        .toSet();
    expect(chapterNumbers, Set<int>.from(List<int>.generate(18, (i) => i + 1)));

    final verseKeys = verses
        .map((verse) => '${verse['chapter_number']}.${verse['verse_number']}')
        .toList();
    expect(verseKeys.toSet().length, verseKeys.length);

    final chapterThirteenFirst = verses.firstWhere((verse) =>
        verse['chapter_number'] == 13 && verse['verse_number'] == 1);
    expect((chapterThirteenFirst['text'] as String).contains('अर्जुन उवाच'), isTrue);
  });
}
