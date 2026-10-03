import 'package:flutter_test/flutter_test.dart';

import 'package:weatherly_mobile/main.dart';

void main() {
  testWidgets('Weatherly app shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherlyApp());
    await tester.pump();

    expect(find.text('Weatherly'), findsOneWidget);
  });
}
