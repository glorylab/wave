import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave/wave.dart';

void main() {
  group('Wave widget', () {
    testWidgets('isLoop true (default)', (WidgetTester tester) async {
      await tester.pumpWidget(getWaveWidget());
      try {
        /*
          If isLoop is true,
          animations will not stopped and therefore the pumpAndSettle() will throw error.
        */
        await tester.pumpAndSettle();
      } catch (e) {
        expect(e, isFlutterError);
      }
    });

    testWidgets('isLoop false', (WidgetTester tester) async {
      int duration = 5000;
      await tester.pumpWidget(getWaveWidget(duration: duration, isLoop: false));
      int count = await tester.pumpAndSettle(const Duration(milliseconds: 1));
      // Animations should be stopped after the specified duration.
      expect(count, duration);
    });
  });
}

Widget getWaveWidget({int? duration, bool isLoop = true}) {
  return MaterialApp(
    home: Container(
      child: WaveWidget(
        backgroundColor: Colors.white,
        config: CustomConfig(
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
