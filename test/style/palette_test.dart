import 'dart:io';

import 'package:caua_loves_candies/style/palette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final palette = Palette();

  int argb(dynamic entry) => (entry.color as dynamic).toARGB32() as int;

  group('Palette hex values', () {
    final expected = <String, List<Object>>{
      'beltBase': [0xFFBFA6EC, 0],
      'beltStripe': [0xFF8F72D6, 0],
      'tutorialCheck': [0xFF2E9E6B, 0],
      'tutorialCheckCircle': [0xFFA8F0D1, 0],
      'tutorialCross': [0xFFFFF5E6, 0],
      'tutorialCrossCircle': [0xFFFF7A7A, 0],
      'accentGrape': [0xFFB79CFF, 0],
    };
    final actual = <String, int>{
      'beltBase': argb(palette.beltBase),
      'beltStripe': argb(palette.beltStripe),
      'tutorialCheck': argb(palette.tutorialCheck),
      'tutorialCheckCircle': argb(palette.tutorialCheckCircle),
      'tutorialCross': argb(palette.tutorialCross),
      'tutorialCrossCircle': argb(palette.tutorialCrossCircle),
      'accentGrape': argb(palette.accentGrape),
    };
    expected.forEach((name, v) {
      test('$name has the documented value', () {
        expect(actual[name], v.first as int);
      });
    });

    test('tutorial circles alias the documented tokens', () {
      expect(argb(palette.tutorialCheckCircle), argb(palette.accentMint));
      expect(argb(palette.tutorialCross), argb(palette.bgCream));
      expect(argb(palette.tutorialCrossCircle), argb(palette.dangerSoft));
    });

    test('old belt hex values are no longer used for the belt', () {
      expect(argb(palette.beltBase), isNot(0xFFCDB8F0));
      expect(argb(palette.beltStripe), isNot(0xFFCDB8F0));
      expect(argb(palette.beltStripe), isNot(0xFFB79CFF));
      expect(argb(palette.beltStripe), isNot(argb(palette.accentGrape)));
    });
  });

  group('color-palette.md doc equality', () {
    late List<String> lines;

    setUpAll(() {
      lines = File('docs/product/design/color-palette.md').readAsLinesSync();
    });

    String rowFor(String token) => lines.firstWhere(
      (l) => l.contains('`$token`'),
      orElse: () => fail('No doc row for $token'),
    );

    const rows = {
      'belt-base': '#BFA6EC',
      'belt-stripe': '#8F72D6',
      'tutorial-check': '#2E9E6B',
      'tutorial-cross': '#FFF5E6',
      'accent-grape': '#B79CFF',
    };
    rows.forEach((token, hex) {
      test('$token row documents $hex', () {
        expect(rowFor(token), contains(hex));
      });
    });

    test('check and cross rows document their circle colors', () {
      expect(rowFor('tutorial-check'), contains('#A8F0D1'));
      expect(rowFor('tutorial-cross'), contains('#FF7A7A'));
    });

    test('belt rows do not use the old belt hex', () {
      expect(rowFor('belt-base'), isNot(contains('#CDB8F0')));
      expect(rowFor('belt-stripe'), isNot(contains('#CDB8F0')));
      expect(rowFor('belt-stripe'), isNot(contains('#B79CFF')));
    });
  });
}
