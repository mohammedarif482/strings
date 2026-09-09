import 'package:flutter_test/flutter_test.dart';
import 'package:aivo_mobile/main.dart';

void main() {
  testWidgets('Aivo smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AivoApp());
    expect(find.text('Aivo'), findsOneWidget);
  });
}
