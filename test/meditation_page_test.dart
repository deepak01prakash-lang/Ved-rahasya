import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ved_rahasya/meditation_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('meditation timer starts, pauses and resets', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MeditationPage()));

    expect(find.text('05:00'), findsOneWidget);
    await tester.ensureVisible(find.text('शुरू करें'));
    await tester.tap(find.text('शुरू करें'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('04:58'), findsOneWidget);

    await tester.ensureVisible(find.text('रोकें'));
    await tester.tap(find.text('रोकें'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('04:58'), findsOneWidget);

    await tester.ensureVisible(find.text('रीसेट'));
    await tester.tap(find.text('रीसेट'));
    await tester.pump();
    expect(find.text('05:00'), findsOneWidget);
  });

  testWidgets('meditation duration can be changed before starting', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MeditationPage()));

    await tester.tap(find.text('10 मिनट'));
    await tester.pump();

    expect(find.text('10:00'), findsOneWidget);
  });
}
