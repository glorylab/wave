import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wave/wave.dart';

void main() {
  testWidgets('issue 53 frame pump benchmark', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 1440,
            height: 300,
            child: WaveWidget(
              config: CustomConfig(
                gradients: [
                  [Colors.white, Colors.white, Colors.white],
                  const [
                    Color(0xFF3EA894),
                    Color(0xFF00BAB9),
                    Color(0xFF42B58D),
                  ],
                  const [
                    Color(0xFFBEFED2),
                    Color(0xFF39DBB1),
                    Color(0xFF00CDA3),
                  ],
                  const [
                    Color(0xFF3EA894),
                    Color(0xFF00BAB9),
                    Color(0xFF42B58D),
                  ],
                ],
                durations: [43000, 43000, 45000, 45000],
                heightPercentages: [0.55, 0.552, 0.90, 0.91],
                gradientBegin: Alignment.centerRight,
                gradientEnd: Alignment.centerLeft,
              ),
              size: const Size(double.infinity, 300),
              waveFrequency: 1,
              waveAmplitude: 180,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    const frames = 1800;
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    stopwatch.stop();

    final averageFrameMs = stopwatch.elapsedMicroseconds / frames / 1000;
    // This file is a manual benchmark. Do not assert on timing because CI
    // runners and local machines vary substantially.
    // ignore: avoid_print
    print(
      'issue_53_benchmark frames=$frames '
      'elapsed_ms=${stopwatch.elapsedMilliseconds} '
      'average_frame_ms=${averageFrameMs.toStringAsFixed(3)}',
    );

    expect(tester.takeException(), isNull);
  });
}
