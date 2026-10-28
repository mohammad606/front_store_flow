// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:storeflow/main.dart';

void main() {
  testWidgets('StoreFlow app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const StoreFlowApp());

    expect(find.text('StoreFlow Login Demo'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}
