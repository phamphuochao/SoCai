import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retail_revenue_manager/components/buttons/app_buttons.dart';

void main() {
  testWidgets('PrimaryButton disables submission while loading', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Lưu',
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FilledButton));
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
