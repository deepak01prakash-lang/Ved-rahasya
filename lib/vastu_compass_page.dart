import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:image_picker/image_picker.dart';

class VastuCompassPage extends StatefulWidget {
  const VastuCompassPage({super.key});

  @override
  State<VastuCompassPage> createState() => _VastuCompassPageState();
}

class _VastuCompassPageState extends State<VastuCompassPage> {
  static const ink = Color(0xFF492A17);
  static const gold = Color(0xFFB86B1B);

  StreamSubscription<CompassEvent>? compassSubscription;
  File? planImage;
  double sensorHeading = 0;
  double manualNorth = 0;
  double declination = 0;
  double planRotation = 0;
  bool hasHeading = false;
  bool useManualNorth = false;
  bool showChakra = true;
  final List<Offset> boundaryCorners = [];
  Offset? get planCentre => boundaryCorners.length == 4 ? _diagonalIntersection(boundaryCorners) : null;
  String selectedMarker = 'मुख्य द्वार';
  final List<_PlanMarker> planMarkers = [];

  static const markerTypes = [
    'मुख्य द्वार', 'रसोई', 'पूजा घर', 'मास्टर बेडरूम',
    'बच्चों का कमरा', 'टॉयलेट', 'सीढ़ियाँ', 'ब्रह्मस्थान',
  ];

  double get baseNorth => useManualNorth || !hasHeading ? manualNorth : sensorHeading;
  double get northHeading => (baseNorth + declination + 360) % 360;

  @override
  void initState() {
    super.initState();
    compassSubscription = FlutterCompass.events?.listen((event) {
      final value = event.heading;
      if (!mounted || value == null || !value.isFinite) return;
      setState(() {
        sensorHeading = (value + 360) % 360;
        hasHeading = true;
      });
    });
  }

  @override
  void dispose() {
    compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> pickPlan() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (file == null || !mounted) return;
    setState(() {
      planImage = File(file.path);
      boundaryCorners.clear();
      planRotation = 0;
      planMarkers.clear();
    });
  }

  String direction(double degrees) {
    const names = [
      'उत्तर', 'उत्तर-उत्तर-पूर्व', 'ईशान', 'पूर्व-उत्तर-पूर्व',
      'पूर्व', 'पूर्व-दक्षिण-पूर्व', 'आग्नेय', 'दक्षिण-दक्षिण-पूर्व',
      'दक्षिण', 'दक्षिण-दक्षिण-पश्चिम', 'नैऋत्य', 'पश्चिम-दक्षिण-पश्चिम',
      'पश्चिम', 'पश्चिम-उत्तर-पश्चिम', 'वायव्य', 'उत्तर-उत्तर-पश्चिम',
    ];
    return names[((degrees % 360) / 22.5).round() % 16];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('360° वास्तु हाउस एनालाइज़र'),
        actions: [
          IconButton(
            tooltip: 'रीसेट',
            onPressed: () => setState(() {
              planRotation = 0;
              declination = 0;
              manualNorth = 0;
              boundaryCorners.clear();
              planMarkers.clear();
            }),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          compassCard(),
          const SizedBox(height: 12),
          northCalibrationCard(),
          const SizedBox(height: 12),
          planCard(),
          const SizedBox(height: 12),
          analysisCard(),
          const SizedBox(height: 12),
          const Text(
            'सटीकता नोट: फोन का कम्पास चुंबकीय क्षेत्र, लोहे/स्टील, बिजली के उपकरण और कवर/मैग्नेट से प्रभावित हो सकता है। बेहतर परिणाम के लिए फोन को 8 के आकार में धीरे-धीरे घुमाकर कैलिब्रेट करें। True North के लिए स्थानीय magnetic declination सही भरें। यह वास्तु-अध्ययन सहायक है, सर्वेक्षण-स्तर का प्रमाणित मापक नहीं।',
            style: TextStyle(fontSize: 11, height: 1.5, color: Colors.brown),
          ),
        ],
      ),
    );
  }

  Widget compassCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          const Text(
            'लाइव 360° वास्तु कम्पास',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink),
          ),
          const SizedBox(height: 5),
          Text(
            direction(northHeading) + '  •  ' + northHeading.toStringAsFixed(1) + '°',
            style: const TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _DegreeCompassPainter(heading: northHeading, hasHeading: hasHeading || useManualNorth),
              child: const SizedBox.expand(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasHeading && !useManualNorth ? Icons.explore : Icons.tune,
                color: hasHeading && !useManualNorth ? Colors.green : Colors.deepOrange,
              ),
              const SizedBox(width: 7),
              Text(useManualNorth || !hasHeading ? 'Manual North mode' : 'फोन का कम्पास सक्रिय'),
            ],
          ),
        ],
      ),
    ),
  );

  Widget northCalibrationCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'North Calibration',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink),
          ),
          const SizedBox(height: 4),
          const Text(
            'GPS या Google Maps की जरूरत नहीं। फोन का कम्पास उपलब्ध हो तो वह दिशा पढ़ेगा। सेंसर न हो या आप नक्शे की दिशा जानते हों तो Manual North चुनें।',
            style: TextStyle(fontSize: 12, height: 1.45, color: Colors.brown),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Manual North सेट करें'),
            subtitle: Text(useManualNorth || !hasHeading ? 'मैन्युअल डिग्री से दिशा तय होगी' : 'फोन सेंसर से दिशा ली जा रही है'),
            value: useManualNorth || !hasHeading,
            onChanged: (value) => setState(() => useManualNorth = value),
          ),
          if (useManualNorth || !hasHeading) ...[
            Row(
              children: [
                const Expanded(child: Text('North bearing')),
                Text(manualNorth.toStringAsFixed(1) + '°', style: const TextStyle(fontWeight: FontWeight.bold, color: gold)),
              ],
            ),
            Slider(
              min: 0,
              max: 359,
              divisions: 359,
              value: manualNorth.clamp(0, 359).toDouble(),
              onChanged: (value) => setState(() => manualNorth = value),
            ),
            Wrap(
              spacing: 6,
              children: [
                for (final item in [
                  ('N 0°', 0.0), ('E 90°', 90.0), ('S 180°', 180.0), ('W 270°', 270.0),
                ])
                  ActionChip(
                    label: Text(item.$1),
                    onPressed: () => setState(() => manualNorth = item.$2),
                  ),
              ],
            ),
          ],
          const Divider(height: 22),
          const Text('Magnetic Declination Correction', style: TextStyle(fontWeight: FontWeight.w600)),
          const Text(
            'स्थानीय magnetic declination का मान उपलब्ध हो तो भरें। नहीं पता हो तो 0° रखें; ऐसी स्थिति में रीडिंग Magnetic North के सापेक्ष होगी।',
            style: TextStyle(fontSize: 11, color: Colors.brown, height: 1.4),
          ),
          Row(
            children: [
              const Expanded(child: Text('Correction')),
              Text(declination.toStringAsFixed(1) + '°', style: const TextStyle(fontWeight: FontWeight.bold, color: gold)),
            ],
          ),
          Slider(
            min: -30,
            max: 30,
            divisions: 600,
            value: declination,
            onChanged: (value) => setState(() => declination = value),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => declination = 0),
              child: const Text('Correction Reset'),
            ),
          ),
        ],
      ),
    ),
  );

  Widget planCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('घर का Floor Plan + Vastu Chakra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink)),
          const SizedBox(height: 5),
          const Text(
            'साफ JPG/PNG नक्शा अपलोड करें। घर की बाहरी सीमा के चार कोने क्रम से (चारों तरफ घूमते हुए) टैप करें। ऐप दोनों diagonals का intersection निकालकर Centre अपने-आप मार्क करेगा। फिर कमरों की जगहें मार्क करें।',
            style: TextStyle(fontSize: 12, height: 1.45, color: Colors.brown),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: pickPlan,
              icon: const Icon(Icons.upload_file),
              label: Text(planImage == null ? 'Floor Plan अपलोड करें' : 'दूसरा Floor Plan चुनें'),
            ),
          ),
          if (planImage != null) ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vastu Chakra 9×9 Overlay'),
              value: showChakra,
              onChanged: (value) => setState(() => showChakra = value),
            ),
            DropdownButtonFormField<String>(
              value: selectedMarker,
              decoration: const InputDecoration(labelText: 'नक्शे पर अगला स्थान मार्क करें'),
              items: markerTypes.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: (value) {
                if (value != null) setState(() => selectedMarker = value);
              },
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const height = 320.0;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final local = details.localPosition;
                    final normalized = Offset(
                      (local.dx / width).clamp(0.0, 1.0).toDouble(),
                      (local.dy / height).clamp(0.0, 1.0).toDouble(),
                    );
                    setState(() {
                      if (boundaryCorners.length < 4) {
                        boundaryCorners.add(normalized);
                      } else {
                        planMarkers.add(_PlanMarker(selectedMarker, normalized));
                      }
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: const Color(0xFFFFFCF5)),
                          Transform.rotate(
                            angle: planRotation * math.pi / 180,
                            child: Image.file(planImage!, fit: BoxFit.contain),
                          ),
                          if (showChakra) CustomPaint(painter: _VastuGridPainter()),
                          if (boundaryCorners.isNotEmpty)
                            CustomPaint(painter: _BoundaryPainter(corners: List<Offset>.of(boundaryCorners))),
                          for (var i = 0; i < boundaryCorners.length; i++)
                            Positioned(
                              left: boundaryCorners[i].dx * width - 12,
                              top: boundaryCorners[i].dy * height - 12,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue.shade700,
                                child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          if (planCentre != null)
                            Positioned(
                              left: planCentre!.dx * width - 12,
                              top: planCentre!.dy * height - 18,
                              child: const Icon(Icons.center_focus_strong, color: Colors.red, size: 30),
                            ),
                          for (final marker in planMarkers)
                            Positioned(
                              left: marker.position.dx * width - 14,
                              top: marker.position.dy * height - 14,
                              child: Tooltip(
                                message: marker.label,
                                child: const Icon(Icons.location_on, color: Colors.deepOrange, size: 28),
                              ),
                            ),
                          const Positioned(
                            bottom: 5,
                            left: 6,
                            right: 6,
                            child: Text(
                              'पहले 4 टैप: घर के चार कोने क्रम से  •  फिर चुने हुए कमरे/स्थान',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, backgroundColor: Color(0xCCFFFFFF)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('Plan Rotation', style: TextStyle(fontWeight: FontWeight.w600))),
                Text(planRotation.toStringAsFixed(1) + '°', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              min: -180,
              max: 180,
              divisions: 720,
              value: planRotation.clamp(-180, 180).toDouble(),
              onChanged: (value) => setState(() => planRotation = value),
            ),
            Wrap(
              spacing: 6,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => planRotation = (planRotation - 1).clamp(-180, 180).toDouble()),
                  icon: const Icon(Icons.rotate_left),
                  label: const Text('−1°'),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => planRotation = (planRotation + 1).clamp(-180, 180).toDouble()),
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('+1°'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    planRotation = 0;
                    boundaryCorners.clear();
                    planMarkers.clear();
                  }),
                  child: const Text('Reset Plan'),
                ),
              ],
            ),
            Text(
              'Boundary corners: ${boundaryCorners.length}/4',
              style: const TextStyle(fontSize: 11, color: Colors.brown),
            ),
            Text(
              'Centre: ' + (planCentre == null ? (boundaryCorners.length == 4 ? 'Diagonals का intersection नहीं मिला—चारों कोने क्रम से दोबारा चुनें' : 'चारों कोने मार्क करें') : (planCentre!.dx * 100).toStringAsFixed(1) + '% X, ' + (planCentre!.dy * 100).toStringAsFixed(1) + '% Y  •  Diagonal intersection'),
              style: const TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 6,
              children: [
                if (boundaryCorners.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => setState(() => boundaryCorners.removeLast()),
                    icon: const Icon(Icons.undo),
                    label: const Text('अंतिम कोना हटाएँ'),
                  ),
                if (boundaryCorners.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => setState(() {
                      boundaryCorners.clear();
                      planMarkers.clear();
                    }),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Boundary Reset'),
                  ),
              ],
            ),
            Text('Marked locations: ' + planMarkers.length.toString(), style: const TextStyle(fontSize: 11, color: Colors.brown)),
            if (planMarkers.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => planMarkers.clear()),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('सभी markers हटाएँ'),
                ),
              ),
          ],
        ],
      ),
    ),
  );

  Widget analysisCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('वास्तु दिशा सारांश', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink)),
          const SizedBox(height: 8),
          _summaryRow('उत्तर', '0°', 'कुबेर दिशा'),
          _summaryRow('ईशान', '45°', 'पूजा / जल क्षेत्र का पारंपरिक महत्व'),
          _summaryRow('पूर्व', '90°', 'प्रकाश / प्रवेश'),
          _summaryRow('आग्नेय', '135°', 'अग्नि / रसोई का पारंपरिक महत्व'),
          _summaryRow('दक्षिण', '180°', 'दक्षिण दिशा'),
          _summaryRow('नैऋत्य', '225°', 'स्थिरता'),
          _summaryRow('पश्चिम', '270°', 'पश्चिम दिशा'),
          _summaryRow('वायव्य', '315°', 'वायु / आवागमन'),
          const Divider(),
          Text(
            'वर्तमान उत्तर bearing: ' + northHeading.toStringAsFixed(1) + '° (' + direction(northHeading) + '). मार्क किए गए स्थान केवल नक्शे पर आपकी बताई स्थिति हैं; अपने-आप कमरे की पहचान नहीं होती।',
            style: const TextStyle(fontSize: 11, color: Colors.brown, height: 1.45),
          ),
        ],
      ),
    ),
  );

  Widget _summaryRow(String title, String degrees, String note) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 68, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        SizedBox(width: 48, child: Text(degrees, style: const TextStyle(color: gold, fontWeight: FontWeight.bold))),
        Expanded(child: Text(note, style: const TextStyle(fontSize: 11, color: Colors.brown))),
      ],
    ),
  );
}


Offset? _diagonalIntersection(List<Offset> points) {
  if (points.length != 4) return null;
  final a = points[0];
  final b = points[2];
  final c = points[1];
  final d = points[3];
  final rx = b.dx - a.dx;
  final ry = b.dy - a.dy;
  final sx = d.dx - c.dx;
  final sy = d.dy - c.dy;
  final denominator = rx * sy - ry * sx;
  if (denominator.abs() < 1e-8) return null;
  final qpx = c.dx - a.dx;
  final qpy = c.dy - a.dy;
  final t = (qpx * sy - qpy * sx) / denominator;
  final u = (qpx * ry - qpy * rx) / denominator;
  if (t < 0 || t > 1 || u < 0 || u > 1) return null;
  return Offset(a.dx + t * rx, a.dy + t * ry);
}

class _BoundaryPainter extends CustomPainter {
  const _BoundaryPainter({required this.corners});
  final List<Offset> corners;

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.isEmpty) return;
    final points = corners.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();
    final outline = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (points.length == 4) path.close();
    canvas.drawPath(path, outline);
    if (points.length == 4) {
      final diagonal = Paint()
        ..color = Colors.red.shade600
        ..strokeWidth = 1.8;
      canvas.drawLine(points[0], points[2], diagonal);
      canvas.drawLine(points[1], points[3], diagonal);
      final centre = _diagonalIntersection(corners);
      if (centre != null) {
        final c = Offset(centre.dx * size.width, centre.dy * size.height);
        canvas.drawCircle(c, 8, Paint()..color = Colors.red.shade700);
        canvas.drawCircle(c, 12, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoundaryPainter oldDelegate) => oldDelegate.corners != corners;
}

class _PlanMarker {
  const _PlanMarker(this.label, this.position);
  final String label;
  final Offset position;
}

class _VastuGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final cellW = size.width / 9;
    final cellH = size.height / 9;
    final fill = Paint()..color = const Color(0x22D08A24);
    canvas.drawRect(Rect.fromLTWH(cellW * 3, cellH * 3, cellW * 3, cellH * 3), fill);
    final line = Paint()
      ..color = const Color(0xB8A45C24)
      ..strokeWidth = 1;
    for (var i = 0; i <= 9; i++) {
      final x = i * cellW;
      final y = i * cellH;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final border = Paint()
      ..color = const Color(0xFF8B4B1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, border);
    _text(canvas, 'ब्रह्मस्थान', Offset(size.width / 2, size.height / 2), math.min(cellW, cellH) * .22);
    _text(canvas, 'N', Offset(size.width / 2, 10), 11);
    _text(canvas, 'S', Offset(size.width / 2, size.height - 10), 11);
    _text(canvas, 'W', Offset(10, size.height / 2), 11);
    _text(canvas, 'E', Offset(size.width - 10, size.height / 2), 11);
  }

  void _text(Canvas canvas, String value, Offset centre, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: TextStyle(fontSize: fontSize, color: const Color(0xFF7A3D13), fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    painter.paint(canvas, centre - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _VastuGridPainter oldDelegate) => false;
}

class _DegreeCompassPainter extends CustomPainter {
  const _DegreeCompassPainter({required this.heading, required this.hasHeading});
  final double heading;
  final bool hasHeading;
  static const ink = Color(0xFF492A17);
  static const gold = Color(0xFFB86B1B);
  static const dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * .44;
    canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = gold);
    canvas.drawCircle(c, r * .91, Paint()..style = PaintingStyle.stroke..color = const Color(0xFFD9BE98));
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-heading * math.pi / 180);
    canvas.translate(-c.dx, -c.dy);
    for (var d = 0; d < 360; d++) {
      final major = d % 10 == 0;
      final medium = d % 5 == 0;
      final inner = r * (major ? .82 : medium ? .86 : .89);
      final outer = r * .91;
      final a = d * math.pi / 180 - math.pi / 2;
      final p1 = Offset(c.dx + inner * math.cos(a), c.dy + inner * math.sin(a));
      final p2 = Offset(c.dx + outer * math.cos(a), c.dy + outer * math.sin(a));
      final tickPaint = Paint()
        ..color = major ? ink : const Color(0xFF9B8063)
        ..strokeWidth = major ? 1.4 : medium ? .9 : .45;
      canvas.drawLine(p1, p2, tickPaint);
      if (major) _draw(canvas, '$d', Offset(c.dx + r * .74 * math.cos(a), c.dy + r * .74 * math.sin(a)), r * .045, ink);
    }
    for (var i = 0; i < 16; i++) {
      final a = (i * 22.5) * math.pi / 180 - math.pi / 2;
      _draw(canvas, dirs[i], Offset(c.dx + r * .60 * math.cos(a), c.dy + r * .60 * math.sin(a)), r * .052, i % 4 == 0 ? Colors.red.shade800 : gold);
    }
    canvas.drawCircle(c, r * .43, Paint()..color = const Color(0xFFFFF8E9));
    canvas.drawCircle(c, r * .43, Paint()..style = PaintingStyle.stroke..color = gold..strokeWidth = 1.4);
    _draw(canvas, 'VASTU', Offset(c.dx, c.dy - r * .07), r * .10, ink);
    _draw(canvas, hasHeading ? heading.toStringAsFixed(1) + '°' : '--°', Offset(c.dx, c.dy + r * .10), r * .075, gold);
    canvas.restore();
    canvas.drawLine(
      Offset(c.dx, c.dy - r * .98),
      Offset(c.dx, c.dy - r * .78),
      Paint()..color = Colors.red.shade700..strokeWidth = 2.5..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 4, Paint()..color = ink);
  }

  void _draw(Canvas canvas, String text, Offset centre, double size, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout();
    painter.paint(canvas, centre - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DegreeCompassPainter old) =>
      old.heading != heading || old.hasHeading != hasHeading;
}
