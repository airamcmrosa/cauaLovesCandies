import 'package:caua_loves_candies/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test menus', (tester) async {
    await tester.pumpWidget(const MyGame());

    // Main menu shows the 'Play' and 'Settings' buttons.
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Go to 'Settings'.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Music'), findsOneWidget);

    // Go back to main menu.
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Play'), findsOneWidget);
  });
}
