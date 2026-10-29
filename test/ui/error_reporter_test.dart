import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import 'package:caua_loves_candies/ui/error_reporter.dart';
import 'package:caua_loves_candies/ui/error_screen.dart';

class _ThrowingBuild extends StatelessWidget {
  const _ThrowingBuild();

  @override
  Widget build(BuildContext context) => throw StateError('build boom');
}

class _ThrowingComponent extends Component {
  @override
  void update(double dt) => throw StateError('component boom');
}

void main() {
  late FlutterExceptionHandler? originalOnError;
  late ErrorCallback? originalPlatformOnError;
  late ErrorWidgetBuilder originalBuilder;
  late List<LogRecord> records;
  late StreamSubscription<LogRecord> sub;
  late ErrorReporter reporter;

  setUp(() {
    originalOnError = FlutterError.onError;
    originalPlatformOnError = PlatformDispatcher.instance.onError;
    originalBuilder = ErrorWidget.builder;
    records = [];
    Logger.root.level = Level.ALL;
    sub = Logger.root.onRecord
        .where((r) => r.loggerName == 'ErrorReporter')
        .listen(records.add);
    reporter = ErrorReporter();
  });

  tearDown(() async {
    FlutterError.onError = originalOnError;
    PlatformDispatcher.instance.onError = originalPlatformOnError;
    ErrorWidget.builder = originalBuilder;
    await sub.cancel();
  });

  group('ErrorReporter.report', () {
    test('starts without error', () {
      expect(reporter.hasError.value, isFalse);
    });

    test('first report flips hasError and logs once', () async {
      reporter.report(StateError('x'), StackTrace.current);
      await Future<void>.delayed(Duration.zero);
      expect(reporter.hasError.value, isTrue);
      expect(records, hasLength(1));
      expect(records.single.level, Level.SEVERE);
    });

    test('second report is ignored: no log, no notification', () async {
      reporter.report(StateError('a'), null);
      var notifications = 0;
      reporter.hasError.addListener(() => notifications++);
      reporter.report(StateError('b'), null);
      await Future<void>.delayed(Duration.zero);
      expect(records, hasLength(1));
      expect(notifications, 0);
      expect(reporter.hasError.value, isTrue);
    });
  });

  group('ErrorGate', () {
    testWidgets('shows child, then ErrorScreen, and stays after a second', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorGate(reporter: reporter, child: const Text('game')),
        ),
      );
      expect(find.text('game'), findsOneWidget);
      expect(find.byType(ErrorScreen), findsNothing);

      reporter.report(StateError('a'), null);
      await tester.pump();
      expect(find.byType(ErrorScreen), findsOneWidget);
      expect(find.text('game'), findsNothing);

      reporter.report(StateError('b'), null);
      await tester.pump();
      expect(find.byType(ErrorScreen), findsOneWidget);
      expect(records, hasLength(1));
    });

    testWidgets('ErrorScreen shows no stack trace or error text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorGate(reporter: reporter, child: const Text('game')),
        ),
      );
      reporter.report(StateError('secret detail'), StackTrace.current);
      await tester.pump();
      expect(find.textContaining('secret detail'), findsNothing);
      expect(find.textContaining('StateError'), findsNothing);
      expect(find.textContaining('#0'), findsNothing);
      expect(find.textContaining('.dart'), findsNothing);
    });
  });

  group('global hooks', () {
    testWidgets('widget build error leads to ErrorScreen without looping', (
      tester,
    ) async {
      reporter.install();
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorGate(reporter: reporter, child: const _ThrowingBuild()),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(reporter.hasError.value, isTrue);
      expect(find.byType(ErrorScreen), findsOneWidget);
      expect(records, hasLength(1));
      await tester.pump(const Duration(seconds: 1));
      expect(records, hasLength(1));
      expect(find.byType(ErrorScreen), findsOneWidget);
      // The build error was routed through the installed hook.
      tester.takeException();
    });

    test('PlatformDispatcher.onError reports and returns true', () {
      reporter.install();
      final handled = PlatformDispatcher.instance.onError!(
        StateError('async boom'),
        StackTrace.current,
      );
      expect(handled, isTrue);
      expect(reporter.hasError.value, isTrue);
      expect(records, hasLength(1));
      expect(records.single.message, contains('async boom'));
    });

    test('FlutterError.onError routes to the reporter', () {
      reporter.install();
      FlutterError.onError!(
        FlutterErrorDetails(
          exception: StateError('framework boom'),
          stack: StackTrace.current,
        ),
      );
      expect(reporter.hasError.value, isTrue);
      expect(records, hasLength(1));
      expect(records.single.message, contains('framework boom'));
    });

    testWidgets('Flame component update error is reported once', (
      tester,
    ) async {
      reporter.install();
      final game = FlameGame();
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorGate(
            reporter: reporter,
            child: GameWidget<FlameGame>(game: game),
          ),
        ),
      );
      await game.add(_ThrowingComponent());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));

      expect(reporter.hasError.value, isTrue);
      expect(find.byType(ErrorScreen), findsOneWidget);
      expect(records, hasLength(1));
      expect(records.single.message, contains('component boom'));
      tester.takeException();
    });
  });
}
