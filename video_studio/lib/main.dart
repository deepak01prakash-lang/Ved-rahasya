import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const VideoStudioApp());

class VideoStudioApp extends StatelessWidget {
  const VideoStudioApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ved Rahasya Video Studio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFB86B1B),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF8EC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF3B2115),
            foregroundColor: Color(0xFFFFE5B4),
            centerTitle: true,
          ),
        ),
        home: const StudioHome(),
      );
}

class StudioHome extends StatefulWidget {
  const StudioHome({super.key});

  @override
  State<StudioHome> createState() => _StudioHomeState();
}

class _StudioHomeState extends State<StudioHome> {
  final topic = TextEditingController();
  final story = TextEditingController();
  final title = TextEditingController();
  final tts = FlutterTts();
  String format = 'YouTube Shorts (9:16)';
  String voice = 'मेरी रिकॉर्ड की हुई आवाज';
  String style = 'सिनेमैटिक भक्ति';
  String language = 'सरल हिंदी';
  String brief = '';
  List<Map<String, dynamic>> projects = [];
  bool busy = false;

  @override
  void initState() {
    super.initState();
    loadProjects();
    tts.setLanguage('hi-IN');
    tts.setSpeechRate(0.46);
  }

  @override
  void dispose() {
    topic.dispose();
    story.dispose();
    title.dispose();
    tts.stop();
    super.dispose();
  }

  Future<void> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('studio_projects') ?? '[]';
    try {
      final parsed = jsonDecode(raw) as List;
      if (mounted) setState(() => projects = parsed
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList());
    } catch (_) {}
  }

  String makeBrief() {
    final subject = topic.text.trim();
    final sourceStory = story.text.trim();
    return '''
तुम मेरे YouTube चैनल Ved Rahasya के हिंदी रिसर्च, स्क्रिप्ट और वीडियो-प्रोडक्शन सहायक हो।

विषय: ${subject.isEmpty ? 'मेरी दी हुई कहानी' : subject}
मेरी दी हुई कहानी/संदर्भ: ${sourceStory.isEmpty ? 'पहले विषय पर मौलिक, तथ्य-जाँची कहानी तैयार करो।' : sourceStory}
फॉर्मेट: $format
वॉइस: $voice
दृश्य शैली: $style
भाषा: $language

काम:
1. आकर्षक लेकिन भ्रामक न होने वाला शीर्षक और शुरुआती 5 सेकंड का हुक दो।
2. कहानी को दृश्य-दर-दृश्य बाँटो। हर दृश्य के लिए अवधि, हिंदी वॉइसओवर, स्क्रीन टेक्स्ट और विस्तृत cinematic visual prompt दो।
3. धार्मिक/ऐतिहासिक दावों को प्रमाणित तथ्य, परंपरागत मान्यता और लोककथा के रूप में अलग-अलग पहचानो। स्रोत न मिले तो दावा मत गढ़ो।
4. अंत में प्रभावशाली निष्कर्ष और दर्शकों से स्वाभाविक CTA दो।
5. हर दृश्य के लिए 9:16 या 16:9 के अनुसार कैमरा मूवमेंट, प्रकाश, वातावरण और ध्वनि निर्देश दो।
6. कॉपीराइट संगीत या किसी फिल्म/सीरियल के दृश्य की नकल मत सुझाओ। केवल royalty-free या स्वयं रिकॉर्ड की गई ध्वनि सुझाओ।
7. आउटपुट हिंदी में दो और इसे सीधे वीडियो एडिटर में इस्तेमाल करने लायक रखो।
''';
  }

  Future<void> saveProject() async {
    if (topic.text.trim().isEmpty && story.text.trim().isEmpty) {
      message('पहले विषय या कहानी लिखें।');
      return;
    }
    setState(() => busy = true);
    final item = <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'name': title.text.trim().isEmpty
          ? (topic.text.trim().isEmpty ? 'नई कहानी' : topic.text.trim())
          : title.text.trim(),
      'topic': topic.text.trim(),
      'story': story.text.trim(),
      'format': format,
      'voice': voice,
      'style': style,
      'created': DateTime.now().toIso8601String(),
    };
    final next = [item, ...projects];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studio_projects', jsonEncode(next));
    if (!mounted) return;
    setState(() {
      projects = next;
      busy = false;
      brief = makeBrief();
    });
    message('प्रोजेक्ट इस फोन में सेव हो गया।');
  }

  Future<void> deleteProject(String id) async {
    final next = projects.where((p) => p['id'] != id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studio_projects', jsonEncode(next));
    if (mounted) setState(() => projects = next);
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> copyBrief() async {
    final value = makeBrief();
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    setState(() => brief = value);
    message('प्रोडक्शन प्रॉम्प्ट कॉपी हो गया। अब ChatGPT में पेस्ट करें।');
  }

  Future<void> openChatGPT() async {
    final uri = Uri.parse('https://chatgpt.com/');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      message('ChatGPT खोलने में समस्या आई।');
    }
  }

  Future<void> speak() async {
    final text = story.text.trim().isNotEmpty ? story.text.trim() : brief;
    if (text.isEmpty) {
      message('पहले कहानी लिखें या प्रॉम्प्ट तैयार करें।');
      return;
    }
    await tts.speak(text);
  }

  Widget section(String title, String sub) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF492A17))),
          const SizedBox(height: 3),
          Text(sub, style: TextStyle(fontSize: 12, color: Colors.brown.shade500)),
        ]),
      );

  Widget dropdown(String label, String value, List<String> values,
          ValueChanged<String?> onChanged) =>
      DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        ),
        items: values
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: onChanged,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Ved Rahasya • Video Studio'),
          actions: [
            IconButton(
              tooltip: 'ChatGPT खोलें',
              onPressed: openChatGPT,
              icon: const Icon(Icons.auto_awesome),
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF20130D), Color(0xFF70401F), Color(0xFFB87932)],
                ),
              ),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.movie_creation_outlined,
                        color: Color(0xFFFFD98A), size: 34),
                    SizedBox(height: 10),
                    Text('कहानी से वीडियो की तैयारी तक',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 21)),
                    SizedBox(height: 7),
                    Text(
                        'विषय लिखें, ChatGPT से स्क्रिप्ट और सीन-प्लान बनवाएँ, फिर मुफ्त एडिटिंग टूल में वीडियो तैयार करें।',
                        style: TextStyle(
                            color: Color(0xFFFFEBD0), height: 1.5)),
                  ]),
            ),
            section('1. अपनी कहानी शुरू करें', 'टॉपिक दें या अपनी स्क्रिप्ट पेस्ट करें'),
            TextField(
              controller: title,
              decoration: const InputDecoration(
                  labelText: 'प्रोजेक्ट का नाम (वैकल्पिक)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: topic,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'वीडियो का विषय',
                  hintText: 'जैसे: महादेव के तीसरे नेत्र का रहस्य',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: story,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                  labelText: 'अपनी कहानी / स्क्रिप्ट (वैकल्पिक)',
                  hintText: 'यहाँ हिंदी कहानी पेस्ट करें…',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder()),
            ),
            section('2. वीडियो सेटिंग', 'कहानी के हिसाब से सीन और अवधि तय करें'),
            dropdown('वीडियो फॉर्मेट', format,
                ['YouTube Shorts (9:16)', 'YouTube Long Video (16:9)'],
                (v) => setState(() => format = v ?? format)),
            const SizedBox(height: 12),
            dropdown('वॉइसओवर', voice,
                ['मेरी रिकॉर्ड की हुई आवाज', 'हिंदी AI आवाज (फोन TTS)'],
                (v) => setState(() => voice = v ?? voice)),
            const SizedBox(height: 12),
            dropdown('दृश्य शैली', style, [
              'सिनेमैटिक भक्ति',
              'पौराणिक महाकाव्य',
              'प्राचीन भारत डॉक्यूमेंट्री',
              'रहस्य और सस्पेंस'
            ], (v) => setState(() => style = v ?? style)),
            const SizedBox(height: 12),
            dropdown('भाषा', language, ['सरल हिंदी', 'शुद्ध हिंदी', 'हिंदी + सामान्य English'],
                (v) => setState(() => language = v ?? language)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: copyBrief,
              icon: const Icon(Icons.copy_all),
              label: const Text('ChatGPT प्रोडक्शन प्रॉम्प्ट कॉपी करें'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: const Color(0xFF492A17)),
            ),
            const SizedBox(height: 9),
            OutlinedButton.icon(
              onPressed: openChatGPT,
              icon: const Icon(Icons.open_in_new),
              label: const Text('ChatGPT खोलें और प्रॉम्प्ट पेस्ट करें'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 9),
            OutlinedButton.icon(
              onPressed: speak,
              icon: const Icon(Icons.record_voice_over),
              label: const Text('कहानी / प्रॉम्प्ट सुनें (फोन की हिंदी TTS)'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 9),
            FilledButton.tonalIcon(
              onPressed: busy ? null : saveProject,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: const Text('प्रोजेक्ट सेव करें'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
            if (brief.isNotEmpty) ...[
              section('तैयार प्रोडक्शन प्रॉम्प्ट', 'इसे ChatGPT में पेस्ट करें'),
              SelectableText(brief,
                  style: const TextStyle(fontSize: 12, height: 1.55)),
            ],
            section('3. मेरे सेव किए गए प्रोजेक्ट', 'ड्राफ्ट इसी फोन में सेव होते हैं'),
            if (projects.isEmpty)
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('अभी कोई प्रोजेक्ट सेव नहीं है।')))
            else
              ...projects.map((p) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                          child: Icon(Icons.movie_filter_outlined)),
                      title: Text(p['name']?.toString() ?? 'वीडियो प्रोजेक्ट'),
                      subtitle: Text(p['format']?.toString() ?? ''),
                      trailing: IconButton(
                          tooltip: 'हटाएँ',
                          onPressed: () => deleteProject(p['id'].toString()),
                          icon: const Icon(Icons.delete_outline)),
                    ),
                  )),
            const SizedBox(height: 12),
            const Card(
              color: Color(0xFFFFF0D7),
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'मुफ्त और ईमानदार सीमा: यह संस्करण प्रोजेक्ट सेव करता है, ChatGPT के लिए विस्तृत सीन/स्क्रिप्ट प्रॉम्प्ट बनाता है और फोन की TTS से टेक्स्ट पढ़ सकता है। यह अभी खुद AI cinematic clips या MP4 render नहीं करता। असली AI वीडियो जनरेशन की मुफ्त, अनलिमिटेड सेवा उपलब्ध होने की गारंटी नहीं है। किसी भी पेड सेवा या API को बिना तुम्हारी अनुमति नहीं जोड़ा जाएगा।',
                  style: TextStyle(fontSize: 12, height: 1.55),
                ),
              ),
            ),
          ],
        ),
      );
}
