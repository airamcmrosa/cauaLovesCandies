import 'package:flutter/material.dart';

import '../style/palette.dart';
import 'reload/reload.dart';

/// Full-screen friendly error view with a single big reload button.
///
/// Standalone: needs no Provider, Router or app theme, so it can be rendered
/// from `ErrorWidget.builder`. Never shows error details.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.onReload = reloadPage});

  /// Called when the reload button is tapped.
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final palette = Palette();
    final ink = palette.ink.color;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: palette.bgCream.color,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ops! Algo deu errado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ink,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Toque para tentar de novo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ink, fontSize: 20),
                  ),
                  const SizedBox(height: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 260,
                      minHeight: 72,
                    ),
                    child: FilledButton(
                      onPressed: onReload,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.brandBubblegum.color,
                        foregroundColor: ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                        ),
                      ),
                      child: const Text(
                        'Recarregar',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
