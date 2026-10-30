import 'package:caua_loves_candies/ui/title_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(VoidCallback? onRetry) => MaterialApp(
    home: Scaffold(body: TitleLoadingIndicator(onRetry: onRetry)),
  );

  testWidgets('shows retry label and calls onRetry on tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(() => taps++));
    expect(find.text('Tentar de novo'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('renders an empty slot without onRetry', (tester) async {
    await tester.pumpWidget(host(null));
    expect(find.text('Tentar de novo'), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });
}
