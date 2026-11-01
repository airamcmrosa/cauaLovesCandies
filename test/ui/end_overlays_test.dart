import 'package:caua_loves_candies/ui/game_over_overlay.dart';
import 'package:caua_loves_candies/ui/play_again_button.dart';
import 'package:caua_loves_candies/ui/victory_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  const sizes = [Size(360, 640), Size(320, 568), Size(430, 932)];

  for (final size in sizes) {
    testWidgets('victory renders exact strings, no overflow at $size', (
      t,
    ) async {
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(VictoryOverlay(onPlayAgain: () {})));
      expect(
        find.text(
          'Parabéns, você ajudou o Cauã a comer todos os doces! '
          'Feliz Aniversário, Cauã!',
        ),
        findsOneWidget,
      );
      expect(find.text('JOGAR NOVAMENTE'), findsOneWidget);
      expect(t.takeException(), isNull);
      final h = t.getSize(find.byKey(const Key('play again button'))).height;
      expect(h, greaterThanOrEqualTo(72));
    });

    testWidgets('game over renders exact strings, no overflow at $size', (
      t,
    ) async {
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(GameOverOverlay(onPlayAgain: () {})));
      expect(find.text('Tente de Novo!'), findsOneWidget);
      expect(
        find.text('Quase lá! O Cauã ainda quer mais doces.'),
        findsOneWidget,
      );
      expect(find.text('JOGAR NOVAMENTE'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('victory button is full width and fires onPlayAgain once', (
    t,
  ) async {
    var taps = 0;
    await t.pumpWidget(host(VictoryOverlay(onPlayAgain: () => taps++)));
    final card = t.getSize(find.byType(DecoratedBox).first);
    final button = t.getSize(find.byType(PlayAgainButton));
    expect(button.width, greaterThan(card.width - 48));
    await t.tap(find.text('JOGAR NOVAMENTE'));
    await t.pump();
    expect(taps, 1);
  });

  testWidgets('game over button fires onPlayAgain once', (t) async {
    var taps = 0;
    await t.pumpWidget(host(GameOverOverlay(onPlayAgain: () => taps++)));
    await t.tap(find.byKey(const Key('play again button')));
    await t.pump();
    expect(taps, 1);
  });

  testWidgets('game over copy has no blame wording', (t) async {
    await t.pumpWidget(host(GameOverOverlay(onPlayAgain: () {})));
    final texts = t
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data!.toLowerCase())
        .join(' ');
    for (final bad in ['perdeu', 'fracass', 'errou', 'game over']) {
      expect(texts.contains(bad), isFalse, reason: bad);
    }
  });
}
