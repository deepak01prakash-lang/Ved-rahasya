import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

enum DevotionalMediaKind { wallpapers, ringtones, meditation }

class DevotionalMediaPage extends StatefulWidget {
  const DevotionalMediaPage({super.key, required this.kind});
  final DevotionalMediaKind kind;
  @override
  State<DevotionalMediaPage> createState() => _DevotionalMediaPageState();
}

class _DevotionalMediaPageState extends State<DevotionalMediaPage> {
  final AudioPlayer _player = AudioPlayer();
  String? _playing;
  bool _busy = false;

  static const _ringtoneTracks = [
    ('मंदिर की घंटी', 'मौलिक घंटी-धुन • 20 सेकंड', 'audio/temple_bell.wav'),
    ('शंख-प्रेरित धुन', 'मौलिक सिंथेसाइज़्ड धुन • 20 सेकंड', 'audio/conch_tone.wav'),
    ('भक्ति स्वर', 'मौलिक छोटी धुन • 20 सेकंड', 'audio/devotional_tune.wav'),
  ];
  static const _meditationTracks = [
    ('शांत ध्यान स्वर', 'मौलिक शांत वाद्य ध्वनि • 60 सेकंड', 'audio/meditation_calm.wav'),
    ('एकाग्रता ड्रोन', 'मौलिक स्थिर ध्यान ध्वनि • 60 सेकंड', 'audio/meditation_focus.wav'),
  ];

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(String asset) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_playing == asset) {
        await _player.stop();
        if (mounted) setState(() => _playing = null);
      } else {
        await _player.stop();
        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.play(AssetSource(asset));
        if (mounted) setState(() => _playing = asset);
        _player.onPlayerComplete.first.then((_) {
          if (mounted && _playing == asset) setState(() => _playing = null);
        });
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ऑडियो चल नहीं पाया। दोबारा प्रयास करें।')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallpaper = widget.kind == DevotionalMediaKind.wallpapers;
    final ringtone = widget.kind == DevotionalMediaKind.ringtones;
    final title = wallpaper ? 'देव-वॉलपेपर' : ringtone ? 'भक्ति रिंगटोन' : 'ध्यान संगीत';
    final tracks = ringtone ? _ringtoneTracks : _meditationTracks;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF30190F), Color(0xFF8B4D20), Color(0xFFD29A48)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.self_improvement_rounded, color: Color(0xFFFFE2A5), size: 34),
            const SizedBox(height: 12),
            Text(wallpaper ? 'भक्ति के रंग' : ringtone ? 'पवित्र ध्वनियाँ' : 'मन को दें विश्राम',
              style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(wallpaper ? 'ऐप में बने मौलिक आध्यात्मिक डिज़ाइन' :
              ringtone ? 'सुनने के लिए तैयार मौलिक छोटी धुनें' : 'मौलिक शांत ध्वनियाँ • अपनी गति से ध्यान करें',
              style: const TextStyle(color: Color(0xFFFFE9C5), height: 1.5)),
          ]),
        ),
        const SizedBox(height: 18),
        if (wallpaper) ...[
          const Text('आध्यात्मिक थीम', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF492A17))),
          const SizedBox(height: 10),
          const _WallpaperTile(title: 'ॐ नमः शिवाय', subtitle: 'शिव-प्रेरित शांत थीम', symbol: 'ॐ', colors: [Color(0xFF172C48), Color(0xFF65859A)]),
          const _WallpaperTile(title: 'राधे कृष्ण', subtitle: 'प्रेम और भक्ति थीम', symbol: 'राधे', colors: [Color(0xFF542B68), Color(0xFFD28C9C)]),
          const _WallpaperTile(title: 'जय श्रीराम', subtitle: 'साहस और मर्यादा थीम', symbol: 'श्रीराम', colors: [Color(0xFF9B4A1E), Color(0xFFE3AD55)]),
          const _WallpaperTile(title: 'जय हनुमान', subtitle: 'शक्ति और सेवा थीम', symbol: 'जय बजरंगबली', colors: [Color(0xFF6C261D), Color(0xFFC96A35)]),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('ये ऐप के भीतर बने सजावटी डिज़ाइन हैं, वास्तविक देवी-देवताओं के फोटो नहीं। फोन वॉलपेपर के रूप में डाउनलोड/सेट करने की सुविधा अभी नहीं है।',
              style: TextStyle(fontSize: 12, height: 1.5, color: Colors.brown)),
          ),
        ] else ...[
          Text(ringtone ? 'रिंगटोन सुनें' : 'ध्यान ध्वनियाँ सुनें',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF492A17))),
          const SizedBox(height: 8),
          ...tracks.map((track) {
            final active = _playing == track.$3;
            return Card(child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFFEBCB),
                child: Icon(active ? Icons.graphic_eq_rounded :
                  (ringtone ? Icons.notifications_active_rounded : Icons.spa_rounded),
                  color: const Color(0xFF8B4D20)),
              ),
              title: Text(track.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(track.$2),
              trailing: IconButton(
                tooltip: active ? 'रोकें' : 'सुनें',
                onPressed: _busy ? null : () => _toggle(track.$3),
                icon: Icon(active ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                  size: 34, color: const Color(0xFF8B4D20)),
              ),
            ));
          }),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('ये मौलिक सिंथेसाइज़्ड ध्वनियाँ हैं; किसी कलाकार की रिकॉर्डिंग या पारंपरिक मंत्र-पाठ नहीं।',
              style: TextStyle(fontSize: 12, height: 1.5, color: Colors.brown)),
          ),
        ],
      ]),
    );
  }
}

class _WallpaperTile extends StatelessWidget {
  const _WallpaperTile({required this.title, required this.subtitle, required this.symbol, required this.colors});
  final String title, subtitle, symbol;
  final List<Color> colors;
  @override
  Widget build(BuildContext context) => Container(
    height: 178,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3))],
    ),
    child: Stack(children: [
      Positioned(right: -18, top: -28, child: Icon(Icons.auto_awesome, size: 150, color: Colors.white.withValues(alpha: .08))),
      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(symbol, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFE8B4), fontSize: 31, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black45, blurRadius: 8)])),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(subtitle, style: const TextStyle(color: Color(0xFFFFE8D2), fontSize: 12)),
      ])),
    ]),
  );
}
