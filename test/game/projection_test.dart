import 'package:caua_loves_candies/game/projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('projection at the plane extremes', () {
    test('z=0 gives scale 1.00 and the bottom y', () {
      expect(scaleAt(0), closeTo(1.0, 1e-9));
      expect(yAt(0), closeTo(Projection.yBottom, 1e-9));
      expect(xAt(0), closeTo(Projection.xSpawn, 1e-9));
    });

    test('z=1 gives scale 0.25 and the horizon y', () {
      expect(scaleAt(1), closeTo(0.25, 1e-9));
      expect(yAt(1), closeTo(Projection.yHorizon, 1e-9));
      expect(xAt(1), closeTo(Projection.xMouth, 1e-9));
    });
  });

  group('linear interpolation', () {
    test('z=0.5 is the midpoint for scale, y and x', () {
      expect(scaleAt(0.5), closeTo(0.625, 1e-9));
      expect(
        yAt(0.5),
        closeTo((Projection.yBottom + Projection.yHorizon) / 2, 1e-9),
      );
      expect(
        xAt(0.5),
        closeTo((Projection.xSpawn + Projection.xMouth) / 2, 1e-9),
      );
    });

    test('x interpolates linearly from spawn to mouth', () {
      for (final z in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final expected =
            Projection.xSpawn + (Projection.xMouth - Projection.xSpawn) * z;
        expect(xAt(z), closeTo(expected, 1e-9));
      }
    });

    test('scale and y decrease monotonically with z', () {
      var prevScale = scaleAt(0);
      var prevY = yAt(0);
      for (var i = 1; i <= 10; i++) {
        final z = i / 10;
        expect(scaleAt(z), lessThan(prevScale));
        expect(yAt(z), lessThan(prevY));
        prevScale = scaleAt(z);
        prevY = yAt(z);
      }
    });
  });

  group('decideOutcome boundary', () {
    test('decision depth constant is 0.95', () {
      expect(Projection.decisionZ, 0.95);
    });

    for (final open in [true, false]) {
      test('z=0.94 is undecided (mouthOpen=$open)', () {
        expect(decideOutcome(0.94, mouthOpen: open), ItemOutcome.undecided);
      });
    }

    test('z=0 is undecided', () {
      expect(decideOutcome(0, mouthOpen: true), ItemOutcome.undecided);
      expect(decideOutcome(0, mouthOpen: false), ItemOutcome.undecided);
    });

    test('z=0.95 ingests when open and deflects when closed', () {
      expect(decideOutcome(0.95, mouthOpen: true), ItemOutcome.ingest);
      expect(decideOutcome(0.95, mouthOpen: false), ItemOutcome.deflect);
    });

    test('just above the boundary still decides', () {
      expect(decideOutcome(0.951, mouthOpen: true), ItemOutcome.ingest);
      expect(decideOutcome(0.951, mouthOpen: false), ItemOutcome.deflect);
    });

    test('z=1.0 and beyond decide', () {
      expect(decideOutcome(1.0, mouthOpen: true), ItemOutcome.ingest);
      expect(decideOutcome(1.0, mouthOpen: false), ItemOutcome.deflect);
      expect(decideOutcome(1.2, mouthOpen: true), ItemOutcome.ingest);
      expect(decideOutcome(1.2, mouthOpen: false), ItemOutcome.deflect);
    });
  });
}
