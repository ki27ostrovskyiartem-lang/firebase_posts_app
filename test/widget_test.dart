import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_posts_app/auth/auth_service.dart';

void main() {
  test('AuthException зберігає повідомлення', () {
    expect(AuthException('помилка').toString(), 'помилка');
  });

  testWidgets('Material app builds', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('ok')));
    expect(find.text('ok'), findsOneWidget);
  });
}
