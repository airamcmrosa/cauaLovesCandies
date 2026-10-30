import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:caua_loves_candies/ui/phase_banner_overlay.dart';

void main() {
  late ValueNotifier<int?> notifier;

  setUp(() => notifier = ValueNotifier<int?>(null));
  tearDown(() => notifier.dispose());

  Widget host(ValueListenable<int?> l, {List<PhaseConfig> phases = kPhases}) {
    return MaterialApp(
      home: Scaffold(
        body: PhaseBannerOverlay(phaseChanged: l, phases: phases),
      ),
    );
  }

  double opacity(WidgetTester t) =>
      t.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

  const t2 = 'Fase 2 - Mais Rápido!';
  const t3 = 'Fase 3 - Super Rápido!';

  testWidgets('nothing visible at start', (t) async {
    await t.pumpWidget(host(notifier));
    expect(opacity(t), 0);
    expect(find.text(t2), findsNothing);
    expect(find.text(t3), findsNothing);
  });

  testWidgets('phase 2 and 3 show exact banner text', (t) async {
    await t.pumpWidget(host(notifier));
    notifier.value = 2;
    await t.pump();
    expect(find.text(t2), findsOneWidget);
    expect(opacity(t), 1);
    notifier.value = 3;
    await t.pump();
    expect(find.text(t3), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
  });

  testWidgets('fades out on its own after showDuration', (t) async {
    await t.pumpWidget(host(notifier));
    notifier.value = 2;
    await t.pump();
    await t.pump(const Duration(milliseconds: 1400));
    expect(opacity(t), 1);
    await t.pump(const Duration(milliseconds: 200));
    expect(opacity(t), 0);
    await t.pump(const Duration(milliseconds: 300));
    expect(opacity(t), 0);
  });

  testWidgets('null hides immediately and shows nothing', (t) async {
    await t.pumpWidget(host(notifier));
    notifier.value = 2;
    await t.pump();
    expect(opacity(t), 1);
    notifier.value = null;
    await t.pump();
    expect(opacity(t), 0);
    await t.pump(const Duration(seconds: 2));
  });

  testWidgets('null from initial state shows nothing', (t) async {
    await t.pumpWidget(host(notifier));
    notifier.value = 2;
    notifier.value = null;
    await t.pump();
    expect(opacity(t), 0);
  });

  for (final p in [1, 0, -1, 4, 99]) {
    testWidgets('phase $p (null text or out of range) shows nothing', (
      t,
    ) async {
      await t.pumpWidget(host(notifier));
      notifier.value = p;
      await t.pump();
      expect(opacity(t), 0);
      expect(find.text(t2), findsNothing);
      expect(find.text(t3), findsNothing);
    });
  }

  testWidgets('rapid 2 then 3 restarts timer with new text', (t) async {
    await t.pumpWidget(host(notifier));
    notifier.value = 2;
    await t.pump();
    await t.pump(const Duration(milliseconds: 1000));
    notifier.value = 3;
    await t.pump();
    expect(find.text(t3), findsOneWidget);
    // 1000ms after restart: old timer would have fired at 1500 total.
    await t.pump(const Duration(milliseconds: 1000));
    expect(opacity(t), 1);
    await t.pump(const Duration(milliseconds: 600));
    expect(opacity(t), 0);
    await t.pump(const Duration(milliseconds: 300));
  });

  testWidgets('is non-blocking: IgnorePointer and tap passes through', (
    t,
  ) async {
    var taps = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () => taps++,
                  child: const Text('tap'),
                ),
              ),
              PhaseBannerOverlay(phaseChanged: notifier),
            ],
          ),
        ),
      ),
    );
    notifier.value = 2;
    await t.pump();
    expect(
      find.descendant(
        of: find.byType(PhaseBannerOverlay),
        matching: find.byType(IgnorePointer),
      ),
      findsWidgets,
    );
    await t.tap(find.text('tap'));
    expect(taps, 1);
    await t.pump(const Duration(seconds: 2));
  });

  testWidgets('dispose cancels timer and listener', (t) async {
    await t.pumpWidget(host(notifier));
    notifier.value = 2;
    await t.pump();
    await t.pumpWidget(const SizedBox());
    // Pending timer would fail the test at teardown; notify must not throw.
    notifier.value = 3;
    await t.pump(const Duration(seconds: 3));
    expect(t.takeException(), isNull);
  });

  testWidgets('didUpdateWidget rewires to the new listenable', (t) async {
    final other = ValueNotifier<int?>(null);
    addTearDown(other.dispose);
    await t.pumpWidget(host(notifier));
    await t.pumpWidget(host(other));

    notifier.value = 2;
    await t.pump();
    expect(opacity(t), 0);
    expect(find.text(t2), findsNothing);

    other.value = 3;
    await t.pump();
    expect(find.text(t3), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
  });

  testWidgets('custom phases supply banner text', (t) async {
    final phases = [
      kPhases[0],
      PhaseConfig(
        speedMultiplier: 1,
        targetScore: 1,
        weights: kPhases[0].weights,
        bannerText: 'Custom',
      ),
    ];
    await t.pumpWidget(host(notifier, phases: phases));
    notifier.value = 2;
    await t.pump();
    expect(find.text('Custom'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
  });
}
