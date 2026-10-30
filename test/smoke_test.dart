import 'package:caua_loves_candies/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test boots into the title entry', (tester) async {
    await tester.pumpWidget(const MyGame());
    // Bounded pump: the title route runs an infinite spinner/animation.
    await tester.pump(const Duration(milliseconds: 100));

    // App boots into the title route, which owns the preload spinner.
    expect(find.byKey(const Key('title')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // The removed main menu and settings screen are gone.
    expect(find.text('Settings'), findsNothing);
    expect(find.text('Music'), findsNothing);
  });
}
