import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  static const _durations = [5, 10, 15, 20];
  Timer? _timer;
  int _durationMinutes = 5;
  int _remainingSeconds = 5 * 60;
  int _elapsedSeconds = 0;
  bool _running = false;

  static const _phaseLengths = [4, 4, 6];
  static const _phaseNames = ['श्वास लें', 'रोकें', 'धीरे छोड़ें'];

  int get _phaseIndex {
    var secondInCycle = _elapsedSeconds % 14;
    for (var i = 0; i < _phaseLengths.length; i++) {
      if (secondInCycle < _phaseLengths[i]) return i;
      secondInCycle -= _phaseLengths[i];
    }
    return 2;
  }

  void _start() {
    if (_running || _remainingSeconds <= 0) return;
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _elapsedSeconds++;
          _running = false;
        });
        _saveSession();
        return;
      }
      setState(() {
        _remainingSeconds--;
        _elapsedSeconds++;
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remainingSeconds = _durationMinutes * 60;
      _elapsedSeconds = 0;
    });
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final key = 'meditation_${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final previous = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, previous + _elapsedSeconds);
  }

  String _format(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _elapsedSeconds / (_durationMinutes * 60);
    return Scaffold(
      appBar: AppBar(title: const Text('ध्यान साधना')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'कुछ क्षण स्वयं के साथ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color(0xFF754414)),
          ),
          const SizedBox(height: 8),
          const Text(
            'आरामदायक आसन में बैठें। श्वास को सहज रखें; किसी भी असुविधा पर सामान्य श्वास लें और अभ्यास रोक दें।',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.6, color: Colors.brown),
          ),
          const SizedBox(height: 24),
          Card(
            color: const Color(0xFFFFF0D7),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Text(
                    _running ? _phaseNames[_phaseIndex] : (_remainingSeconds == 0 ? 'साधना पूर्ण' : 'जब तैयार हों, आरंभ करें'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF754414)),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            strokeWidth: 9,
                            backgroundColor: const Color(0xFFEAD7B8),
                            color: const Color(0xFF9B642B),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_format(_remainingSeconds), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFF492A17))),
                            const Text('शेष समय', style: TextStyle(color: Colors.brown)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('श्वास चक्र: 4 सेकंड लें • 4 सेकंड सहज रोकें • 6 सेकंड छोड़ें',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.brown.shade700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('अवधि चुनें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _durations.map((minutes) => ChoiceChip(
              label: Text('$minutes मिनट'),
              selected: _durationMinutes == minutes,
              onSelected: _running ? null : (_) {
                setState(() {
                  _durationMinutes = minutes;
                  _remainingSeconds = minutes * 60;
                  _elapsedSeconds = 0;
                });
              },
            )).toList(),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _running ? _pause : (_remainingSeconds == 0 ? null : _start),
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? 'रोकें' : 'शुरू करें'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF754414), minimumSize: const Size.fromHeight(48)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('रीसेट'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(110, 48)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'यह सामान्य श्वास-जागरूकता अभ्यास है, चिकित्सकीय उपचार या प्राणायाम-दीक्षा का विकल्प नहीं। श्वास को जबरन न रोकें। चक्कर, घबराहट या सांस की तकलीफ हो तो तुरंत सामान्य श्वास लें और अभ्यास बंद करें।',
                style: TextStyle(fontSize: 12, height: 1.6, color: Colors.brown),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
