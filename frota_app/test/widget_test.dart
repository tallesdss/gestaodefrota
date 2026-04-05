// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:frota_app/app.dart';

void main() {
  testWidgets('App root smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FleetApp());

    // Given the app starts at the login screen, we check for login text
    expect(find.text('ACESSO À PLATAFORMA'), findsOneWidget);
  });
}
