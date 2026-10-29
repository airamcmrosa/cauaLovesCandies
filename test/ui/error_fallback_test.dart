import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caua_loves_candies/ui/error_reporter.dart';
import 'package:caua_loves_candies/ui/error_screen.dart';

void main() {
  late FlutterExceptionHandler? originalOnError;
  late ErrorCallback? originalPlatformOnError;
  late ErrorWidgetBuilder originalBuilder;
  late ErrorReporter reporter;

  final details = FlutterErrorDetails(exception: StateError('boom'));

  setUp(() {
    originalOnError = FlutterError.onError;
    originalPlatformOnError = PlatformDispatcher.instance.onError;
    originalBuilder = ErrorWidget.builder;
    reporter = ErrorReporter();
  });

  tearDown(() {
    FlutterError.onError = originalOnError;
    PlatformDispatcher.instance.onError = originalPlatformOnError;
    ErrorWidget.builder = originalBuilder;
  });

  group('ErrorReporter.buildErrorWidget', () {
    test('returns ErrorScreen before any report', () async {
      final widget = reporter.buildErrorWidget(details);
      expect(widget, isA<ErrorScreen>());
      await Future<void>.delayed(Duration.zero);
    });

    test('still returns ErrorScreen after a report', () {
      reporter.report(StateError('first'), null);
      expect(reporter.buildErrorWidget(details), isA<ErrorScreen>());
    });

    test('build marks reported after a microtask', () async {
      expect(reporter.hasError.value, isFalse);
      expect(reporter.buildErrorWidget(details), isA<ErrorScreen>());
      expect(reporter.hasError.value, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(reporter.hasError.value, isTrue);
    });
  });

  group('ErrorFallback', () {
    testWidgets('renders its message with no MaterialApp or theme', (
      tester,
    ) async {
      await tester.pumpWidget(const ErrorFallback());
      expect(find.text(ErrorFallback.message), findsOneWidget);
      expect(find.byType(MaterialApp), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('install', () {
    test('assigns ErrorWidget.builder to buildErrorWidget', () async {
      reporter.install();
      expect(ErrorWidget.builder(details), isA<ErrorScreen>());
      await Future<void>.delayed(Duration.zero);
      expect(reporter.hasError.value, isTrue);
    });
  });
}
