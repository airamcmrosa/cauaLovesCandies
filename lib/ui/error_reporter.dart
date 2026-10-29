import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'error_screen.dart';

/// Collects uncaught errors and flips [hasError] exactly once.
///
/// Everything after the first report is ignored, so a failing error screen
/// can never cause a report loop. Nothing leaves the device: the error is only
/// logged locally (runtimeType, message and stack, no user data).
class ErrorReporter {
  ErrorReporter();

  /// Shared instance used by `main.dart`. Tests should create their own.
  static final ErrorReporter instance = ErrorReporter();

  static final Logger _log = Logger('ErrorReporter');

  /// True once any error has been reported.
  final ValueNotifier<bool> hasError = ValueNotifier<bool>(false);

  /// Records the first error; later calls are no-ops.
  void report(Object error, StackTrace? stack) {
    if (hasError.value) return;
    _log.severe('Uncaught ${error.runtimeType}: $error', null, stack);
    hasError.value = true;
  }

  /// Installs global hooks (Flutter framework, platform dispatcher and
  /// `ErrorWidget.builder`). Flame game loop errors surface through these.
  ///
  /// Tests can restore `FlutterError.onError`, `PlatformDispatcher.onError`
  /// and `ErrorWidget.builder` themselves after calling this.
  void install() {
    FlutterError.onError = (details) =>
        report(details.exception, details.stack);
    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack);
      return true;
    };
    ErrorWidget.builder = (details) {
      // Defer so we never notify listeners while building.
      scheduleMicrotask(() => report(details.exception, details.stack));
      return const ErrorScreen();
    };
  }
}

/// Shows [ErrorScreen] once [reporter] has an error, otherwise [child].
class ErrorGate extends StatelessWidget {
  const ErrorGate({super.key, required this.reporter, required this.child});

  final ErrorReporter reporter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: reporter.hasError,
      builder: (context, failed, _) => failed ? const ErrorScreen() : child,
    );
  }
}
