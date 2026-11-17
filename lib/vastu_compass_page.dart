import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class VastuCompassPage extends StatefulWidget {
  const VastuCompassPage({super.key});
  @override
  State<VastuCompassPage> createState() => _VastuCompassPageState();
}

class _VastuCompassPageState extends State<VastuCompassPage> {
  static const ink = Color(0xFF492A17);
  static const gold = Color(0xFFB86B1B);
  static const mapsKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  Position? position;
  GoogleMapController? mapController;
  final List<LatLng> boundary = [];
  LatLng? houseCentre;
  File? planImage;
  Offset? planCentre;
  double planRotation = 0;
  double declination = 0;
  double heading = 0;
  bool hasHeading = false;
  bool loadingLocation = false;
  bool satellite = true;
  bool automaticDeclination = false;
  String? locationMessage;

  double get trueHeading => (heading + declination + 360) % 360;
  bool get mapsReady => mapsKey.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    FlutterCompass.events?.listen((event) {
      final value = event.heading;
      if (!mounted || value == null || !value.isFinite) return;
      setState(() { heading = (value + 360) % 360; hasHeading = true; });
    });
  }

  @override
  void dispose() { mapController?.dispose(); super.dispose(); }

  Future<void> getLocation() async {
    setState(() { loadingLocation = true; locationMessage = null; });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('फोन की Location/GPS सुविधा बंद है।');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('लोकेशन की अनुमति नहीं मिली।');
      if (permission == LocationPermission.deniedForever) throw Exception('Settings में जाकर लोकेशन अनुमति चालू करें।');
      final result = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 20)),
      );
      if (!mounted) return;
      setState(() { position = result; locationMessage = 'GPS accuracy लगभग ${result.accuracy.toStringAsFixed(1)} मीटर'; });
      try {
        final value = await const MethodChannel('com.vedrahasya/geomagnetic').invokeMethod<double>(
          'getDeclination',
          {
            'latitude': result.latitude,
            'longitude': result.longitude,
            'altitude': result.altitude,
            'timeMillis': DateTime.now().millisecondsSinceEpoch,
          },
        );
        if (mounted && value != null && value.isFinite) {
          setState(() { declination = value; automaticDeclination = true; });
        }
      } on PlatformException {
        if (mounted) setState(() => automaticDeclination = false);
      } on MissingPluginException {
        if (mounted) setState(() => automaticDeclination = false);
      }
      if (mapsReady) {
        await mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(result.latitude, result.longitude), 19));
      }
    } catch (e) {
      if (mounted) setState(() => locationMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => loadingLocation = false); }
  }

  LatLng centroid(List<LatLng> points) {
    // Polygon centroid in the local latitude/longitude plane (adequate for a house-sized plot).
    double twiceArea = 0, cx = 0, cy = 0;
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      final cross = a.longitude * b.latitude - b.longitude * a.latitude;
      twiceArea += cross;
      cx += (a.longitude + b.longitude) * cross;
      cy += (a.latitude + b.latitude) * cross;
    }
    if (twiceArea.abs() < 1e-12) {
      return LatLng(
        points.fold<double>(0, (s, p) => s + p.latitude) / points.length,
        points.fold<double>(0, (s, p) => s + p.longitude) / points.length,
      );
    }
    return LatLng(cy / (3 * twiceArea), cx / (3 * twiceArea));
  }

  void addBoundary(LatLng point) {
    setState(() { boundary.add(point); houseCentre = boundary.length >= 3 ? centroid(boundary) : null; });
  }

  Future<void> pickPlan() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (file == null || !mounted) return;
    setState(() { planImage = File(file.path); planCentre = null; planRotation = 0; });
  }

  Future<void> openEarth() async {
    final point = houseCentre ?? (position == null ? null : LatLng(position!.latitude, position!.longitude));
    if (point == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पहले GPS लोकेशन प्राप्त करें या घर का centre चुनें।')));
      return;
    }
    final uri = Uri.parse('https://earth.google.com/web/@${point.latitude},${point.longitude},120a,800d,35y,0h,0t,0r');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String direction(double degrees) {
    const names = ['उत्तर','उत्तर-उत्तर-पूर्व','ईशान','पूर्व-उत्तर-पूर्व','पूर्व','पूर्व-दक्षिण-पूर्व','आग्नेय','दक्षिण-दक्षिण-पूर्व','दक्षिण','दक्षिण-दक्षिण-पश्चिम','नैऋत्य','पश्चिम-दक्षिण-पश्चिम','पश्चिम','पश्चिम-उत्तर-पश्चिम','वायव्य','उत्तर-उत्तर-पश्चिम'];
    return names[((degrees % 360) / 22.5).round() % 16];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('360° वास्तु हाउस एनालाइज़र'),
      actions: [IconButton(tooltip: 'Google Earth में खोलें', onPressed: openEarth, icon: const Icon(Icons.public))]),
    body: ListView(padding: const EdgeInsets.all(14), children: [
      compassCard(), const SizedBox(height: 12), locationCard(), const SizedBox(height: 12),
      mapCard(), const SizedBox(height: 12), planCard(), const SizedBox(height: 12),
      calibrationCard(), const SizedBox(height: 10),
      const Text('महत्वपूर्ण: GPS से मिला स्थान और नक्शे का centre अलग-अलग चीजें हैं। Boundary स्वयं जाँचें। फोन का magnetometer चुंबकीय व्यवधान से प्रभावित हो सकता है। यह दिशा-सहायक माप है, सर्वेक्षण-स्तर की गारंटी नहीं।',
        style: TextStyle(fontSize: 11, height: 1.55, color: Colors.brown)),
    ]),
  );

  Widget compassCard() => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
    const Text('लाइव 360° वास्तु कम्पास', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink)),
    const SizedBox(height: 5),
    Text(hasHeading ? '${direction(trueHeading)}  •  ${trueHeading.toStringAsFixed(1)}°' : 'कम्पास सेंसर की प्रतीक्षा…',
      style: const TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    AspectRatio(aspectRatio: 1, child: CustomPaint(
      painter: _DegreeCompassPainter(heading: trueHeading, hasHeading: hasHeading), child: const SizedBox.expand())),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(hasHeading ? Icons.explore : Icons.explore_off, color: hasHeading ? Colors.green : Colors.deepOrange),
      const SizedBox(width: 7), Text(hasHeading ? 'कम्पास सेंसर सक्रिय' : 'Sensor signal उपलब्ध नहीं'),
    ]),
  ])));

  Widget infoRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: Colors.brown, fontSize: 12))),
      SelectableText(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))]));

  Widget locationCard() => Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('घर की लोकेशन एवं GPS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: loadingLocation ? null : getLocation,
        icon: loadingLocation ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
        label: Text(loadingLocation ? 'लोकेशन प्राप्त हो रही है…' : 'मेरी वर्तमान लोकेशन प्राप्त करें'))),
      if (position != null) ...[
        const SizedBox(height: 10),
        infoRow('Latitude', position!.latitude.toStringAsFixed(7)),
        infoRow('Longitude', position!.longitude.toStringAsFixed(7)),
        infoRow('GPS accuracy', '${position!.accuracy.toStringAsFixed(1)} m'),
        infoRow('Altitude', '${position!.altitude.toStringAsFixed(1)} m'),
      ],
      if (locationMessage != null) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text(locationMessage!, style: const TextStyle(color: Colors.brown, fontSize: 12))),
      if (houseCentre != null) ...[
        const Divider(height: 20),
        const Text('घर का चुना हुआ centre', style: TextStyle(fontWeight: FontWeight.bold, color: ink)),
        infoRow('Centre latitude', houseCentre!.latitude.toStringAsFixed(7)),
        infoRow('Centre longitude', houseCentre!.longitude.toStringAsFixed(7)),
      ],
    ],
  )));

  Widget mapCard() => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Google Maps • Satellite House Boundary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 5),
      const Text('घर के बाहरी कोनों को क्रम से टैप करें। 3 या अधिक बिंदुओं के बाद centre का अनुमान निकलेगा; नीले marker को खींचकर centre सुधारें।',
        style: TextStyle(fontSize: 12, height: 1.45, color: Colors.brown)),
      const SizedBox(height: 10),
      if (mapsReady) SizedBox(height: 320, child: ClipRRect(borderRadius: BorderRadius.circular(14),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position == null ? const LatLng(23.7957, 86.4304) : LatLng(position!.latitude, position!.longitude), zoom: 18),
          mapType: satellite ? MapType.satellite : MapType.hybrid,
          myLocationEnabled: position != null, myLocationButtonEnabled: true, zoomControlsEnabled: true,
          onMapCreated: (c) => mapController = c, onTap: addBoundary,
          polygons: boundary.length >= 3 ? {Polygon(polygonId: const PolygonId('house'), points: boundary,
            fillColor: Colors.orange.withValues(alpha: .18), strokeColor: Colors.deepOrange, strokeWidth: 3)} : {},
          markers: {
            for (var i = 0; i < boundary.length; i++) Marker(markerId: MarkerId('corner-$i'), position: boundary[i],
              infoWindow: InfoWindow(title: 'Boundary point ${i + 1}')),
            if (houseCentre != null) Marker(markerId: const MarkerId('centre'), position: houseCentre!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), draggable: true,
              infoWindow: const InfoWindow(title: 'House centre'),
              onDragEnd: (v) => setState(() => houseCentre = v)),
          },
        )))
      else Container(height: 180, width: double.infinity, decoration: BoxDecoration(
        color: const Color(0xFFFFF2DF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE7D2B4))),
        child: const Padding(padding: EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.map_outlined, size: 42, color: gold), SizedBox(height: 8),
          Text('Google Maps API key configure करना बाकी है', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: ink)),
          SizedBox(height: 5),
          Text('API key जोड़ने के बाद Satellite/Hybrid map सक्रिय होगा। GPS और uploaded floor plan अभी इस्तेमाल किए जा सकते हैं।',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 1.4, color: Colors.brown)),
        ]))),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton.icon(onPressed: mapsReady ? () => setState(() => satellite = !satellite) : null,
          icon: const Icon(Icons.layers), label: Text(satellite ? 'Hybrid View' : 'Satellite View')),
        OutlinedButton.icon(onPressed: boundary.isEmpty ? null : () => setState(() { boundary.clear(); houseCentre = null; }),
          icon: const Icon(Icons.delete_outline), label: const Text('Boundary हटाएँ')),
        OutlinedButton.icon(onPressed: houseCentre == null ? null : () => mapController?.animateCamera(CameraUpdate.newLatLngZoom(houseCentre!, 20)),
          icon: const Icon(Icons.center_focus_strong), label: const Text('Centre पर जाएँ')),
      ]),
      Text('Boundary points: ${boundary.length}', style: const TextStyle(fontSize: 11, color: Colors.brown)),
    ],
  )));

  Widget planCard() => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('घर का Floor Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 5),
      const Text('Gallery से JPG/PNG नक्शा चुनें। नक्शे पर centre mark करें और rotation को compass reading के अनुसार adjust करें।',
        style: TextStyle(fontSize: 12, height: 1.45, color: Colors.brown)),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: pickPlan,
        icon: const Icon(Icons.upload_file), label: Text(planImage == null ? 'Floor plan image अपलोड करें' : 'दूसरा नक्शा चुनें'))),
      if (planImage != null) ...[
        const SizedBox(height: 10),
        GestureDetector(onTapDown: (d) => setState(() => planCentre = d.localPosition),
          child: SizedBox(height: 290, width: double.infinity, child: ClipRRect(borderRadius: BorderRadius.circular(12),
            child: Stack(alignment: Alignment.center, children: [
              Container(color: const Color(0xFFF8F1E6)),
              Transform.rotate(angle: planRotation * math.pi / 180,
                child: Image.file(planImage!, fit: BoxFit.contain, width: double.infinity, height: 290)),
              if (planCentre != null) Positioned(left: planCentre!.dx - 12, top: planCentre!.dy - 18,
                child: const Icon(Icons.location_on, color: Colors.red, size: 30)),
              const Positioned(bottom: 7, child: Text('नक्शे पर centre mark करने के लिए टैप करें',
                style: TextStyle(fontSize: 10, backgroundColor: Colors.white70))),
            ])))),
        Row(children: [const Text('Map rotation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(), Text('${planRotation.toStringAsFixed(1)}°', style: const TextStyle(fontWeight: FontWeight.bold))]),
        Slider(min: -180, max: 180, divisions: 720, value: planRotation.clamp(-180, 180),
          onChanged: (v) => setState(() => planRotation = v)),
        Wrap(spacing: 6, children: [
          TextButton.icon(onPressed: () => setState(() => planRotation = (planRotation - 1).clamp(-180, 180).toDouble()),
            icon: const Icon(Icons.rotate_left), label: const Text('−1°')),
          TextButton.icon(onPressed: () => setState(() => planRotation = (planRotation + 1).clamp(-180, 180).toDouble()),
            icon: const Icon(Icons.rotate_right), label: const Text('+1°')),
          TextButton(onPressed: () => setState(() { planRotation = 0; planCentre = null; }), child: const Text('Reset')),
        ]),
      ],
    ],
  )));

  Widget calibrationCard() => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('North Calibration & Declination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 5),
      const Text('फोन का compass magnetic north बताता है। GPS लोकेशन मिलने पर Android के geomagnetic model से स्थानीय declination अपने-आप निकाली जाती है। जरूरत पर नीचे manual correction भी कर सकते हैं।',
        style: TextStyle(fontSize: 12, height: 1.45, color: Colors.brown)),
      Text(automaticDeclination ? 'Automatic geomagnetic correction सक्रिय' : 'Manual correction mode', style: TextStyle(fontSize: 11, color: automaticDeclination ? Colors.green : Colors.deepOrange, fontWeight: FontWeight.w600)),
      Row(children: [const Expanded(child: Text('Declination correction', style: TextStyle(fontSize: 12))),
        Text('${declination.toStringAsFixed(1)}°', style: const TextStyle(fontWeight: FontWeight.bold, color: gold))]),
      Slider(min: -30, max: 30, divisions: 600, value: declination, onChanged: (v) => setState(() => declination = v)),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => setState(() => declination = 0), child: const Text('Reset correction'))),
        const SizedBox(width: 8),
        Expanded(child: FilledButton(onPressed: planImage == null ? null : () {
          setState(() => planRotation = (trueHeading) % 360);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan को compass north के अनुसार rotate किया गया।')));
        }, child: const Text('Align plan to North'))),
      ]),
      if (!hasHeading) const Text('Sensor unavailable होने पर manual rotation का उपयोग करें।',
        style: TextStyle(fontSize: 11, color: Colors.deepOrange)),
    ],
  )));
}

class _DegreeCompassPainter extends CustomPainter {
  const _DegreeCompassPainter({required this.heading, required this.hasHeading});
  final double heading;
  final bool hasHeading;
  static const ink = Color(0xFF492A17);
  static const gold = Color(0xFFB86B1B);
  static const dirs = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW'];

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
      final tickPaint = Paint();
      tickPaint.color = major ? ink : const Color(0xFF9B8063);
      tickPaint.strokeWidth = major ? 1.4 : medium ? .9 : .45;
      canvas.drawLine(p1, p2, tickPaint);
      if (major) _draw(canvas, '$d', Offset(c.dx + r * .74 * math.cos(a), c.dy + r * .74 * math.sin(a)), r * .045, ink, true);
    }
    for (var i = 0; i < 16; i++) {
      final a = (i * 22.5) * math.pi / 180 - math.pi / 2;
      _draw(canvas, dirs[i], Offset(c.dx + r * .60 * math.cos(a), c.dy + r * .60 * math.sin(a)), r * .052, i % 4 == 0 ? Colors.red.shade800 : gold, true);
    }
    canvas.drawCircle(c, r * .43, Paint()..color = const Color(0xFFFFF8E9));
    canvas.drawCircle(c, r * .43, Paint()..style = PaintingStyle.stroke..color = gold..strokeWidth = 1.4);
    _draw(canvas, 'VASTU', Offset(c.dx, c.dy - r * .07), r * .10, ink, true);
    _draw(canvas, hasHeading ? '${heading.toStringAsFixed(1)}°' : '--°', Offset(c.dx, c.dy + r * .10), r * .075, gold, true);
    canvas.restore();
    canvas.drawLine(Offset(c.dx, c.dy - r * .98), Offset(c.dx, c.dy - r * .78),
      Paint()..color = Colors.red.shade700..strokeWidth = 2.5..strokeCap = StrokeCap.round);
    canvas.drawCircle(c, 4, Paint()..color = ink);
  }

  void _draw(Canvas canvas, String text, Offset centre, double size, Color color, bool bold) {
    final p = TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.w600)), textDirection: TextDirection.ltr,
      textAlign: TextAlign.center, maxLines: 1)..layout();
    p.paint(canvas, centre - Offset(p.width / 2, p.height / 2));
  }
  @override
  bool shouldRepaint(covariant _DegreeCompassPainter old) => old.heading != heading || old.hasHeading != hasHeading;
}
