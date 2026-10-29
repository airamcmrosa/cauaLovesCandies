import 'package:caua_loves_candies/game/managers/mouth_controller.dart';
import 'package:caua_loves_candies/game/managers/mouth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MouthController controller;
  late int notifications;

  setUp(() {
    controller = MouthController();
    notifications = 0;
    controller.state.addListener(() => notifications++);
  });

  group('MouthController', () {
    test('defaults to closed', () {
      expect(controller.state.value, MouthState.closed);
      expect(controller.isOpen, isFalse);
    });

    test('toggle alternates closed and open', () {
      final seen = <MouthState>[];
      for (var i = 0; i < 4; i++) {
        controller.toggle();
        seen.add(controller.state.value);
      }
      expect(seen, [
        MouthState.open,
        MouthState.closed,
        MouthState.open,
        MouthState.closed,
      ]);
    });

    test('isOpen tracks state', () {
      controller.toggle();
      expect(controller.isOpen, isTrue);
      controller.toggle();
      expect(controller.isOpen, isFalse);
    });

    test('each toggle notifies listeners exactly once', () {
      for (var i = 1; i <= 5; i++) {
        controller.toggle();
        expect(notifications, i);
      }
    });

    test('reset returns to closed and notifies once when changed', () {
      controller.toggle();
      notifications = 0;
      controller.reset();
      expect(controller.state.value, MouthState.closed);
      expect(notifications, 1);
    });

    test('reset when already closed does not notify', () {
      controller.reset();
      expect(controller.state.value, MouthState.closed);
      expect(notifications, 0);
    });

    test('dispose does not throw', () {
      expect(() => controller.dispose(), returnsNormally);
    });
  });
}
