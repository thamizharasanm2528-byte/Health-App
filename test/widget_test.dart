import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp builds successfully', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Health Companion'))),
    );

    expect(find.text('Health Companion'), findsOneWidget);
  });
}
