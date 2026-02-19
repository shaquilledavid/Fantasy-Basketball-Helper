import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:fantasy_bball_helper/main.dart";

void main() {
  testWidgets("App smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(const FantasyBballApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
