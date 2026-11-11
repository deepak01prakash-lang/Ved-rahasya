import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ved_rahasya/main.dart';

void main() {
  testWidgets('Ved Rahasya app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const VedRahasyaApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
