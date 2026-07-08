import 'package:flutter_test/flutter_test.dart';
import 'package:wave_example/main.dart';

void main() {
  testWidgets('renders the generator shell', (WidgetTester tester) async {
    await tester.pumpWidget(const WaveGeneratorApp());
    await tester.pump();

    expect(find.text('Wave Generator'), findsOneWidget);
    expect(find.text('Live preview'), findsOneWidget);
    expect(find.text('Controls'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
