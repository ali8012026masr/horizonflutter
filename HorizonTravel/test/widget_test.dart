import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Horizon Travel smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Horizon Travel'),
          ),
        ),
      ),
    );

    expect(find.text('Horizon Travel'), findsOneWidget);
  });
}
