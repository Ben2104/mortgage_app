import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mortgage_app/main.dart';
import 'package:mortgage_app/mortgage.dart';

void main() {
  test('default mortgage matches lab sample', () {
    final m = Mortgage();
    expect(m.getFormattedAmount(), '\$100,000.00');
    expect(m.formattedMonthlyPayment(), '\$449.04');
    // PDF screenshot shows $161,654.66: Float (32-bit) rounding artifact.
    // Double math gives the exact value 449.0452... * 360.
    expect(m.formattedTotalPayment(), '\$161,656.09');
    expect(m.getFormattedRate(), '3.5%');
  });

  testWidgets('modify flow updates summary; terms dialog shows', (tester) async {
    await tester.pumpWidget(const MortgageApp());
    expect(find.text('\$449.04'), findsOneWidget);

    // Terms checkbox -> AlertDialog
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, true);

    // Modify screen
    await tester.tap(find.text('MODIFY DATA'));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((w) => w is Radio<int> && w.value == 15));
    await tester.enterText(find.byType(TextField), '200000');
    await tester.scrollUntilVisible(find.text('5%'), 100,
        scrollable: find.byType(Scrollable).last);
    await tester.ensureVisible(find.text('5%'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5%'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    expect(find.text('\$200,000.00'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('5%'), findsOneWidget);
  });
}
