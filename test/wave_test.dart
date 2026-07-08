import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave/wave.dart';

void main() {
  group('Config', () {
    test('rejects mismatched custom gradient lengths', () {
      expect(
        () => CustomConfig(
          gradients: [
            [Colors.red, Colors.blue],
          ],
          durations: [1000, 2000],
          heightPercentages: [0.2, 0.3],
        ),
        throwsA(isA<FlutterError>()),
      );
    });

    test('rejects gradients with fewer than two colors', () {
      expect(
        () => CustomConfig(
          gradients: [
            [Colors.red],
          ],
          durations: [1000],
          heightPercentages: [0.2],
        ),
        throwsA(isA<FlutterError>()),
      );
    });
  });

  group('Wave widget', () {
    testWidgets('isLoop true (default)', (WidgetTester tester) async {
      await tester.pumpWidget(getWaveWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('isLoop false', (WidgetTester tester) async {
      int duration = 5000;
      await tester.pumpWidget(getWaveWidget(duration: duration, isLoop: false));
      await tester.pump(Duration(milliseconds: duration + 1));
      int count = await tester.pumpAndSettle(const Duration(milliseconds: 1));

      // Animations should be stopped after the specified duration.
      expect(count, lessThan(10));
    });

    testWidgets('SingleConfig renders', (WidgetTester tester) async {
      await tester.pumpWidget(getWaveWidget(
        config: SingleConfig(),
        duration: 10,
        isLoop: false,
      ));
      await tester.pump(const Duration(milliseconds: 11));

      expect(tester.takeException(), isNull);
    });

    testWidgets('RandomConfig renders', (WidgetTester tester) async {
      await tester.pumpWidget(getWaveWidget(
        config: RandomConfig(seed: 7),
        duration: 10,
        isLoop: false,
      ));
      await tester.pump(const Duration(milliseconds: 11));

      expect(tester.takeException(), isNull);
    });
  });
}

Widget getWaveWidget({
  Config? config,
  int? duration,
  bool isLoop = true,
}) {
  return MaterialApp(
    home: Container(
      child: WaveWidget(
        backgroundColor: Colors.white,
        config: config ??
            CustomConfig(
              blur: MaskFilter.blur(
                BlurStyle.solid,
                0.0,
              ),
              colors: [
                Colors.white54,
                Colors.white30,
                Colors.white,
              ],
              durations: [21000, 18000, 5000],
              heightPercentages: [0.26, 0.28, 0.31],
            ),
        duration: duration,
        isLoop: isLoop,
        size: Size(
          double.infinity,
          double.infinity,
        ),
        waveAmplitude: 5.0,
      ),
    ),
  );
}
