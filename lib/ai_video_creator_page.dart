import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiVideoCreatorPage extends StatefulWidget {
  const AiVideoCreatorPage({super.key});

  @override
  State<AiVideoCreatorPage> createState() => _AiVideoCreatorPageState();
}

class _AiVideoCreatorPageState extends State<AiVideoCreatorPage> {
  static const _saffron = Color(0xFFB86B1B);
  static const _dark = Color(0xFF492A17);

  final _topicController = TextEditingController();
  final _storyController = TextEditingController();
  final _projectNameController = TextEditingController();
  String _contentMode = 'topic';
  String _format = '9:16 Shorts';
  String _voice = 'AI Hindi voice';
  String _visualStyle = 'Cinematic devotional';
  bool _busy = false;
  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _storyController.dispose();
    _projectNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ai_video_creator_projects') ?? '[]';
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      if (!mounted) return;
      setState(() => _projects = decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList());
    } catch (_) {
      if (mounted) setState(() => _projects = []);
    }
  }

  Future<void> _saveProject() async {
    final topic = _topicController.text.trim();
    final story = _storyController.text.trim();
    if (_contentMode == 'topic' && topic.isEmpty) {
      _message('पहले वीडियो का विषय लिखें।');
      return;
    }
    if (_contentMode == 'story' && story.isEmpty) {
      _message('पहले अपनी कहानी या स्क्रिप्ट लिखें।');
      return;
    }
    if (_contentMode == 'both' && topic.isEmpty && story.isEmpty) {
      _message('विषय या कहानी में से कम-से-कम एक जानकारी दें।');
      return;
    }

    setState(() => _busy = true);
    final project = <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'name': _projectNameController.text.trim().isEmpty
          ? (topic.isNotEmpty ? topic : 'मेरी नई कहानी')
          : _projectNameController.text.trim(),
      'mode': _contentMode,
      'topic': topic,
      'story': story,
      'format': _format,
      'voice': _voice,
      'style': _visualStyle,
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'Draft',
    };
    final next = [project, ..._projects];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_video_creator_projects', jsonEncode(next));
    if (!mounted) return;
    setState(() {
      _projects = next;
      _busy = false;
    });
    _message('प्रोजेक्ट सेव हो गया। AI वीडियो बनाने के लिए सर्विस कनेक्शन बाकी है।');
  }

  Future<void> _deleteProject(String id) async {
    final next = _projects.where((item) => item['id'] != id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_video_creator_projects', jsonEncode(next));
    if (mounted) setState(() => _projects = next);
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _sectionTitle(String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(
            color: _dark, fontWeight: FontWeight.w800, fontSize: 18,
          )),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(
            color: Colors.brown.shade500, fontSize: 12,
          )),
        ]),
      );

  Widget _choice(String value, String title, String subtitle, IconData icon) {
    final selected = _contentMode == value;
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => setState(() => _contentMode = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF0D7) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? _saffron : const Color(0xFFEADBC5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Icon(icon, color: _saffron, size: 23),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(
              color: _dark, fontWeight: FontWeight.bold, fontSize: 14,
            )),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(
              color: Colors.brown.shade500, fontSize: 11,
            )),
          ])),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? _saffron : Colors.brown.shade300,
          ),
        ]),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
          color: _dark, fontWeight: FontWeight.w700, fontSize: 13,
        )),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(13)),
              borderSide: BorderSide(color: Color(0xFFEADBC5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(13)),
              borderSide: BorderSide(color: Color(0xFFEADBC5)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          ),
          items: options.map((item) => DropdownMenuItem(
            value: item, child: Text(item, overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: onChanged,
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _dark,
        foregroundColor: const Color(0xFFFFE4AE),
        title: const Text('AI Video Creator Studio'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF21130D), Color(0xFF75421F), Color(0xFFB87932)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.movie_creation_outlined, color: Color(0xFFFFD98A), size: 34),
              SizedBox(height: 10),
              Text('अपनी कल्पना को सिनेमैटिक वीडियो में बदलें',
                style: TextStyle(color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.w800, height: 1.25)),
              SizedBox(height: 7),
              Text('वेद रहस्य के लिए सनातन ज्ञान, पौराणिक कथाएँ और आध्यात्मिक रहस्य।',
                style: TextStyle(color: Color(0xFFFFEBD0), fontSize: 12, height: 1.5)),
            ]),
          ),
          _sectionTitle('1. कंटेंट कैसे देना है?', 'विषय से शुरुआत करें या अपनी पूरी कहानी दें'),
          _choice('topic', 'सिर्फ विषय लिखूँगा',
              'AI से कहानी और सीन स्क्रिप्ट तैयार करवाने के लिए', Icons.lightbulb_outline),
          _choice('story', 'अपनी कहानी / स्क्रिप्ट दूँगा',
              'मेरी लिखी सामग्री से वीडियो तैयार करना है', Icons.article_outlined),
          _choice('both', 'दोनों विकल्प',
              'विषय और अपनी कहानी—दोनों का उपयोग कर सकूँ', Icons.auto_awesome),
          TextField(
            controller: _projectNameController,
            decoration: const InputDecoration(
              labelText: 'प्रोजेक्ट का नाम (वैकल्पिक)',
              hintText: 'जैसे: शिवजी के तीसरे नेत्र का रहस्य',
              border: OutlineInputBorder(),
            ),
          ),
          if (_contentMode != 'story') ...[
            const SizedBox(height: 13),
            TextField(
              controller: _topicController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'वीडियो का विषय',
                hintText: 'जैसे: समुद्र मंथन का अनसुना रहस्य',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (_contentMode != 'topic') ...[
            const SizedBox(height: 13),
            TextField(
              controller: _storyController,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'अपनी कहानी / पूरी स्क्रिप्ट',
                hintText: 'यहाँ अपनी हिंदी कहानी या स्क्रिप्ट पेस्ट करें…',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
          _sectionTitle('2. वीडियो सेटिंग', 'वीडियो की लंबाई कहानी के अनुसार रहेगी'),
          Row(children: [
            Expanded(child: _dropdown(
              label: 'वीडियो फॉर्मेट',
              value: _format,
              options: const ['9:16 Shorts', '16:9 Long Video'],
              onChanged: (v) => setState(() => _format = v ?? _format),
            )),
            const SizedBox(width: 10),
            Expanded(child: _dropdown(
              label: 'वॉइसओवर',
              value: _voice,
              options: const ['AI Hindi voice', 'मेरी रिकॉर्ड की हुई आवाज'],
              onChanged: (v) => setState(() => _voice = v ?? _voice),
            )),
          ]),
          const SizedBox(height: 14),
          _dropdown(
            label: 'वीडियो का दृश्य स्टाइल',
            value: _visualStyle,
            options: const [
              'Cinematic devotional',
              'Mythological epic',
              'Ancient India documentary',
              'Mystery and suspense',
            ],
            onChanged: (v) => setState(() => _visualStyle = v ?? _visualStyle),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E6),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFEADBC5)),
            ),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, color: _saffron),
              SizedBox(width: 9),
              Expanded(child: Text(
                'अवधि पर कोई तय सीमा नहीं होगी। सीन की संख्या और वीडियो की लंबाई कहानी के हिसाब से तय होगी।',
                style: TextStyle(color: _dark, fontSize: 12, height: 1.45),
              )),
            ]),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _dark,
              foregroundColor: const Color(0xFFFFE4AE),
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: _busy ? null : _saveProject,
            icon: _busy
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_alt_rounded),
            label: const Text('वीडियो प्रोजेक्ट सेव करें'),
          ),
          _sectionTitle('3. मेरे प्रोजेक्ट', 'सेव किए गए ड्राफ्ट इसी डिवाइस पर उपलब्ध रहेंगे'),
          if (_projects.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEADBC5)),
              ),
              child: const Text('अभी कोई प्रोजेक्ट सेव नहीं है। ऊपर से पहला प्रोजेक्ट बनाएँ।',
                style: TextStyle(color: Color(0xFF806B58), fontSize: 13)),
            )
          else
            ..._projects.map((project) => Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFF0D7),
                  child: Icon(Icons.movie_outlined, color: _saffron),
                ),
                title: Text(project['name']?.toString() ?? 'नया प्रोजेक्ट',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${project['format'] ?? ''} • ${project['voice'] ?? ''}\nDraft • AI provider connection pending',
                  style: const TextStyle(fontSize: 11, height: 1.4),
                ),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: 'प्रोजेक्ट हटाएँ',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteProject(project['id'].toString()),
                ),
              ),
            )),
          const SizedBox(height: 8),
          const Text(
            'महत्वपूर्ण: अभी यह पहला काम करने योग्य स्टूडियो स्क्रीन और लोकल ड्राफ्ट सेविंग है। असली AI कहानी, सिनेमैटिक text-to-video क्लिप, रिकॉर्डेड वॉइस अपलोड, एडिटिंग और MP4 एक्सपोर्ट के लिए सुरक्षित सर्वर तथा वीडियो/वॉइस प्रोवाइडर API जोड़ना अगला तकनीकी चरण है। बिना उस कनेक्शन के ऐप नकली वीडियो जनरेट नहीं दिखाएगा।',
            style: TextStyle(color: Color(0xFF806B58), fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }
}
