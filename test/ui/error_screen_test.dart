import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caua_loves_candies/ui/error_screen.dart';
import 'package:caua_loves_candies/ui/reload/reload_stub.dart' as stub;

Future<void> _pump(WidgetTester tester, VoidCallback onReload) {
  return tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(400, 800)),
      child: ErrorScreen(onReload: onReload),
    ),
  );
}

void main() {
  group('ErrorScreen', () {
    testWidgets('shows friendly message and reload button', (tester) async {
      await _pump(tester, () {});
      expect(find.text('Ops! Algo deu errado.'), findsOneWidget);
      expect(find.text('Recarregar'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('tapping the button calls onReload exactly once', (
      tester,
    ) async {
      var calls = 0;
      await _pump(tester, () => calls++);
      expect(calls, 0);
      await tester.tap(find.text('Recarregar'));
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('does not show exception or stack trace text', (tester) async {
      await _pump(tester, () {});
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');
      expect(texts, isNot(contains('Exception')));
      expect(texts, isNot(contains('Error:')));
      expect(texts, isNot(contains('#0')));
      expect(texts, isNot(contains('.dart')));
    });

    testWidgets('button is large with a wide tap target', (tester) async {
      await _pump(tester, () {});
      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, greaterThanOrEqualTo(64));
      expect(size.width, greaterThanOrEqualTo(200));
    });
  });

  test('stub reloadPage does not throw', () {
    expect(stub.reloadPage, returnsNormally);
  });
}
