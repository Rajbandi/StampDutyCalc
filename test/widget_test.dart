import 'package:flutter_test/flutter_test.dart';
import 'package:stamp_duty_calc/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const StampDutyApp());
    await tester.pumpAndSettle();
    expect(find.text('Stamp Duty Calculator'), findsOneWidget);
  });
}
