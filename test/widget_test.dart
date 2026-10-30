// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:storeflow/main.dart';

void main() {
  test('user role is detected correctly', () {
    expect(isUserRole('user'), isTrue);
    expect(isUserRole('User'), isTrue);
    expect(isUserRole('admin'), isFalse);
  });

  test('stored token is enough to consider a user signed in', () {
    expect(hasStoredToken('abc123'), isTrue);
    expect(hasStoredToken(''), isFalse);
    expect(hasStoredToken(null), isFalse);
  });
}
