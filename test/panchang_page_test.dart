import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ved_rahasya/panchang_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('daily Panchanga reads saved string coordinates and timezone', (tester) async {
    SharedPreferences.setMockInitialValues({
      'profile_latitude': '24.48',
      'profile_longitude': '86.69',
      'profile_birth_place': 'Deoghar',
      'profile_utc_offset': '+05:30',
      'profile_timezone_id': 'Asia/Kolkata',
    });

    await tester.pumpWidget(const MaterialApp(home: PanchangPage()));
    await tester.pumpAndSettle();

    expect(find.text('दैनिक पंचांग'), findsOneWidget);
    expect(find.text('स्थान: Deoghar'), findsOneWidget);
    expect(find.text('तिथि'), findsOneWidget);
    expect(find.text('नक्षत्र'), findsOneWidget);
    expect(find.text('योग'), findsOneWidget);
    expect(find.text('करण'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
