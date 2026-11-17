import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class VastuCompassPage extends StatelessWidget {
  const VastuCompassPage({super.key});

  static const _ink = Color(0xFF492A17);
  static const _gold = Color(0xFFB86B1B);

  String _direction(double heading) {
    const directions = [
      'उत्तर', 'उत्तर-उत्तर-पूर्व', 'ईशान', 'पूर्व-उत्तर-पूर्व',
      'पूर्व', 'पूर्व-दक्षिण-पूर्व', 'आग्नेय', 'दक्षिण-दक्षिण-पूर्व',
      'दक्षिण', 'दक्षिण-दक्षिण-पश्चिम', 'नैऋत्य', 'पश्चिम-दक्षिण-पश्चिम',
      'पश्चिम', 'पश्चिम-उत्तर-पश्चिम', 'वायव्य', 'उत्तर-उत्तर-पश्चिम',
    ];
    final index = ((heading % 360) / 22.5).round() % 16;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('वास्तु चक्र एवं कम्पास')),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          final heading = snapshot.data?.heading;
          final available = heading != null && heading.isFinite;
          final safeHeading = available ? heading! : 0.0;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
                  child: Column(
                    children: [
                      const Text('लाइव दिशा के साथ वास्तु पुरुष मंडल',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _ink)),
                      const SizedBox(height: 6),
                      Text(
                        available ? '${_direction(safeHeading)}  •  ${safeHeading.toStringAsFixed(0)}°'
                          : 'कम्पास सेंसर से दिशा प्राप्त की जा रही है…',
                        style: const TextStyle(fontSize: 15, color: _gold, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 14),
                      AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: _VastuCompassPainter(heading: safeHeading),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.explore, color: _gold),
                          const SizedBox(width: 7),
                          Text(available ? 'कम्पास सक्रिय' : 'कम्पास उपलब्ध नहीं',
                            style: TextStyle(
                              color: available ? Colors.green.shade700 : Colors.deepOrange,
                              fontWeight: FontWeight.w600,
                            )),
                        ],
                      ),
                      if (!available)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'यदि आपके फोन में कम्पास सेंसर नहीं है, तो लाइव दिशा उपलब्ध नहीं होगी। फोन को धीरे-धीरे घुमाएँ और मैग्नेटिक कवर/चुंबक से दूर रखें।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, height: 1.5, color: Colors.brown),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('दिशा पहचान', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _ink)),
                    SizedBox(height: 8),
                    Text('• उत्तर (N) — 337.5° से 22.5°\n'
                      '• ईशान — 22.5° से 67.5°\n'
                      '• पूर्व (E) — 67.5° से 112.5°\n'
                      '• आग्नेय — 112.5° से 157.5°\n'
                      '• दक्षिण (S) — 157.5° से 202.5°\n'
                      '• नैऋत्य — 202.5° से 247.5°\n'
                      '• पश्चिम (W) — 247.5° से 292.5°\n'
                      '• वायव्य — 292.5° से 337.5°',
                      style: TextStyle(height: 1.75, color: Colors.brown)),
                  ]),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(
                  'नोट: यह दिशा-सहायक टूल है। चुंबकीय कम्पास में स्थानीय magnetic declination और फोन सेंसर की calibration के कारण अंतर हो सकता है। सटीक भवन-निर्णय से पहले वास्तविक उत्तर दिशा की पुष्टि करें।',
                  style: TextStyle(fontSize: 11, height: 1.5, color: Colors.brown),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VastuCompassPainter extends CustomPainter {
  const _VastuCompassPainter({required this.heading});
  final double heading;

  static const _brown = Color(0xFF754414);
  static const _gold = Color(0xFFB86B1B);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .43;
    final gridSize = radius * 1.48;
    final rect = Rect.fromCenter(center: center, width: gridSize, height: gridSize);

    final ring = Paint()..color = _gold..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(center, radius, ring);
    canvas.drawCircle(center, radius * .91, Paint()
      ..color = const Color(0xFFE9D5B7)..style = PaintingStyle.stroke..strokeWidth = 1);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);

    final gridFill = Paint()..color = const Color(0xFFFFF8E9);
    canvas.drawRect(rect, gridFill);
    final line = Paint()..color = const Color(0xFFB98A58)..style = PaintingStyle.stroke..strokeWidth = .8;
    final cell = gridSize / 9;
    for (var i = 0; i <= 9; i++) {
      final offset = i * cell;
      canvas.drawLine(Offset(rect.left + offset, rect.top), Offset(rect.left + offset, rect.bottom), line);
      canvas.drawLine(Offset(rect.left, rect.top + offset), Offset(rect.right, rect.top + offset), line);
    }
    final centerCell = Rect.fromLTWH(rect.left + 4 * cell, rect.top + 4 * cell, cell, cell);
    canvas.drawRect(centerCell, Paint()..color = const Color(0xFFFFE4AE));
    _text(canvas, 'ब्रह्मस्थान', centerCell.center, cell * .19, _brown, bold: true);

    const labels = [
      ['ई', 4, 0], ['आ', 8, 4], ['प', 4, 8], ['उ', 0, 4],
      ['ईशान', 0, 0], ['आग्नेय', 8, 0], ['नैऋत्य', 8, 8], ['वायव्य', 0, 8],
    ];
    for (final item in labels) {
      final x = item[1] as int;
      final y = item[2] as int;
      final cellRect = Rect.fromLTWH(rect.left + x * cell, rect.top + y * cell, cell, cell);
      canvas.drawRect(cellRect, Paint()..color = const Color(0xFFFFEED2));
      _text(canvas, item[0] as String, cellRect.center, cell * .18, _brown, bold: true);
    }

    final northArrow = Paint()..color = Colors.red.shade700..style = PaintingStyle.fill;
    final arrowPath = Path()
      ..moveTo(center.dx, rect.top - radius * .10)
      ..lineTo(center.dx - 7, rect.top + 7)
      ..lineTo(center.dx + 7, rect.top + 7)
      ..close();
    canvas.drawPath(arrowPath, northArrow);
    _text(canvas, 'N', Offset(center.dx, center.dy - radius - 12), 13, Colors.red.shade700, bold: true);
    _text(canvas, 'E', Offset(center.dx + radius + 12, center.dy), 13, _brown, bold: true);
    _text(canvas, 'S', Offset(center.dx, center.dy + radius + 12), 13, _brown, bold: true);
    _text(canvas, 'W', Offset(center.dx - radius - 12, center.dy), 13, _brown, bold: true);
    canvas.restore();
  }

  void _text(Canvas canvas, String value, Offset center, double fontSize, Color color, {bool bold = false}) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: TextStyle(
        color: color, fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      )),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout(maxWidth: 100);
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _VastuCompassPainter oldDelegate) => oldDelegate.heading != heading;
}
