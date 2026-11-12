import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScriptureCatalogPage extends StatelessWidget {
  const ScriptureCatalogPage({super.key, required this.onOpenGita});

  final VoidCallback onOpenGita;

  Future<List<Map<String, dynamic>>> _loadCatalog() async {
    final raw = await rootBundle.loadString('assets/data/scripture_catalog.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['collections'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  String _status(Map<String, dynamic> item) {
    if (item['id'] == 'bhagavad-gita') {
      return 'मूल संस्कृत पाठ उपलब्ध • संस्करण/श्लोक-क्रम की समीक्षा जारी';
    }
    return 'पूर्ण मूल पाठ अभी ऐप में शामिल नहीं है';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('मूल ग्रंथ-संग्रह')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadCatalog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('ग्रंथ-सूची लोड नहीं हो सकी।'));
          }
          final items = snapshot.data!;
          final groups = <String, List<Map<String, dynamic>>>{};
          for (final item in items) {
            final group = item['group'] as String? ?? 'अन्य';
            groups.putIfAbsent(group, () => []).add(item);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                color: Color(0xFFFFF0D7),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'यह सूची ग्रंथों और उनकी उपलब्धता का पारदर्शी रिकॉर्ड है। जहाँ मूल पाठ उपलब्ध नहीं है, वहाँ केवल परिचय को पूरा ग्रंथ नहीं बताया गया है। संस्कृत मूल, हिंदी अनुवाद और अंग्रेज़ी अनुवाद अलग-अलग दिखाए जाएँगे।',
                    style: TextStyle(height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${items.length} ग्रंथ / संग्रह सूचीबद्ध',
                style: const TextStyle(
                  color: Color(0xFF754414),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              for (final entry in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 6),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF754414),
                    ),
                  ),
                ),
                for (final item in entry.value)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFFB86B1B),
                      ),
                      title: Text(
                        item['title_hi'] as String? ?? item['title_en'] as String? ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title_sa'] as String? ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              _status(item),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'हिंदी / English अनुवाद: अभी उपलब्ध नहीं',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      trailing: item['id'] == 'bhagavad-gita'
                          ? const Icon(Icons.arrow_forward_ios, size: 16)
                          : const Icon(Icons.lock_outline, size: 18),
                      onTap: item['id'] == 'bhagavad-gita'
                          ? onOpenGita
                          : null,
                    ),
                  ),
              ],
              const SizedBox(height: 10),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'स्रोत-नीति: हर डिजिटल पाठ के संस्करण, स्रोत और लाइसेंस की जाँच आवश्यक है। आधुनिक अनुवाद या भाष्य को बिना अनुमति कॉपी नहीं किया जाएगा।',
                    style: TextStyle(fontSize: 12, height: 1.6),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
