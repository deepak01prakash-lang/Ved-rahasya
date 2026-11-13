import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

enum DevotionalMediaKind { wallpapers, ringtones, meditation }

class DevotionalMediaPage extends StatefulWidget {
  const DevotionalMediaPage({super.key, required this.kind});
  final DevotionalMediaKind kind;
  @override
  State<DevotionalMediaPage> createState() => _DevotionalMediaPageState();
}

class _DevotionalMediaPageState extends State<DevotionalMediaPage> {
  static const _native = MethodChannel('com.vedrahasya/media');
  final AudioPlayer _player = AudioPlayer();
  String? _playing;
  bool _busy = false;
  final List<GlobalKey> _wallpaperKeys = List.generate(4, (_) => GlobalKey());

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

  Future<Uint8List?> _wallpaperBytes(GlobalKey key) async {
    await WidgetsBinding.instance.endOfFrame;
    final render = key.currentContext?.findRenderObject();
    if (render is! RenderRepaintBoundary) return null;
    final image = await render.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }

  Future<void> _saveWallpaper(GlobalKey key, String name) async {
    try {
      final bytes = await _wallpaperBytes(key);
      if (bytes == null) throw StateError('Wallpaper not ready');
      await Gal.putImageBytes(bytes, name: name, album: 'Ved Rahasya');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('वॉलपेपर गैलरी में सेव हो गया।')),
      );
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('सेव नहीं हो पाया। गैलरी की अनुमति जाँचें।')),
      );
    }
  }

  Future<void> _shareWallpaper(GlobalKey key, String name, String title) async {
    try {
      final bytes = await _wallpaperBytes(key);
      if (bytes == null) throw StateError('Wallpaper not ready');
      await SharePlus.instance.share(ShareParams(
        title: title,
        files: [XFile.fromData(bytes, mimeType: 'image/png')],
        fileNameOverrides: ['$name.png'],
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('शेयर नहीं हो पाया। दोबारा प्रयास करें।')),
      );
    }
  }

  Future<void> _shareRingtone(String asset, String name) async {
    try {
      final data = await rootBundle.load('assets/$asset');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await SharePlus.instance.share(ShareParams(
        title: name,
        files: [XFile.fromData(bytes, mimeType: 'audio/wav')],
        fileNameOverrides: ['$name.wav'],
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('रिंगटोन फ़ाइल शेयर नहीं हो पाई।')),
      );
    }
  }

  Future<void> _setRingtone(String asset, String title) async {
    try {
      await _native.invokeMethod<bool>('setRingtoneFromAsset', {
        'assetPath': 'assets/$asset',
        'title': title,
      });
    } on PlatformException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'रिंगटोन सेट नहीं हो पाई।')),
      );
    } on MissingPluginException {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('रिंगटोन सेट करने की सुविधा इस बिल्ड में उपलब्ध नहीं है।')),
      );
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
              ringtone ? 'सुनें, शेयर करें या सिस्टम रिंगटोन के रूप में चुनें' : 'मौलिक शांत ध्वनियाँ • अपनी गति से ध्यान करें',
              style: const TextStyle(color: Color(0xFFFFE9C5), height: 1.5)),
          ]),
        ),
        const SizedBox(height: 18),
        if (wallpaper) ...[
          const Text('आध्यात्मिक थीम', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF492A17))),
          const SizedBox(height: 10),
          _WallpaperTile(key: _wallpaperKeys[0], title: 'ॐ नमः शिवाय', subtitle: 'शिव-प्रेरित शांत थीम', symbol: 'ॐ', colors: const [Color(0xFF172C48), Color(0xFF65859A)], onSave: () => _saveWallpaper(_wallpaperKeys[0], 'om-namah-shivaya'), onShare: () => _shareWallpaper(_wallpaperKeys[0], 'om-namah-shivaya', 'ॐ नमः शिवाय')),
          _WallpaperTile(key: _wallpaperKeys[1], title: 'राधे कृष्ण', subtitle: 'प्रेम और भक्ति थीम', symbol: 'राधे', colors: const [Color(0xFF542B68), Color(0xFFD28C9C)], onSave: () => _saveWallpaper(_wallpaperKeys[1], 'radhe-krishna'), onShare: () => _shareWallpaper(_wallpaperKeys[1], 'radhe-krishna', 'राधे कृष्ण')),
          _WallpaperTile(key: _wallpaperKeys[2], title: 'जय श्रीराम', subtitle: 'साहस और मर्यादा थीम', symbol: 'श्रीराम', colors: const [Color(0xFF9B4A1E), Color(0xFFE3AD55)], onSave: () => _saveWallpaper(_wallpaperKeys[2], 'jai-shri-ram'), onShare: () => _shareWallpaper(_wallpaperKeys[2], 'jai-shri-ram', 'जय श्रीराम')),
          _WallpaperTile(key: _wallpaperKeys[3], title: 'जय हनुमान', subtitle: 'शक्ति और सेवा थीम', symbol: 'जय बजरंगबली', colors: const [Color(0xFF6C261D), Color(0xFFC96A35)], onSave: () => _saveWallpaper(_wallpaperKeys[3], 'jai-hanuman'), onShare: () => _shareWallpaper(_wallpaperKeys[3], 'jai-hanuman', 'जय हनुमान')),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('ये ऐप के भीतर बने सजावटी डिज़ाइन हैं, वास्तविक देवी-देवताओं के फोटो नहीं।',
              style: TextStyle(fontSize: 12, height: 1.5, color: Colors.brown)),
          ),
        ] else ...[
          Text(ringtone ? 'रिंगटोन सुनें' : 'ध्यान ध्वनियाँ सुनें',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF492A17))),
          const SizedBox(height: 8),
          ...tracks.map((track) {
            final active = _playing == track.$3;
            return Card(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(children: [
                ListTile(
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
                ),
                if (ringtone) Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Row(children: [
                    Expanded(child: TextButton.icon(
                      onPressed: () => _shareRingtone(track.$3, track.$1),
                      icon: const Icon(Icons.share_rounded), label: const Text('फ़ाइल शेयर करें'),
                    )),
                    Expanded(child: FilledButton.tonalIcon(
                      onPressed: () => _setRingtone(track.$3, track.$1),
                      icon: const Icon(Icons.notifications_active_rounded), label: const Text('रिंगटोन सेट करें'),
                    )),
                  ]),
                ),
              ]),
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
  const _WallpaperTile({super.key, required this.title, required this.subtitle, required this.symbol, required this.colors, required this.onSave, required this.onShare});
  final String title, subtitle, symbol;
  final List<Color> colors;
  final VoidCallback onSave, onShare;
  @override
  Widget build(BuildContext context) => Column(children: [
    RepaintBoundary(
      key: key,
      child: Container(
        height: 178,
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
      ),
    ),
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton.icon(onPressed: onSave, icon: const Icon(Icons.download_rounded), label: const Text('सेव करें')),
      TextButton.icon(onPressed: onShare, icon: const Icon(Icons.share_rounded), label: const Text('शेयर करें')),
    ]),
  ]);
}
