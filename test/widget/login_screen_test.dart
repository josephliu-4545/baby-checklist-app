import 'package:apdp_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLoginAuthController extends ChangeNotifier
    implements LoginAuthController {
  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<bool> login(String email, String password) async {
    return false;
  }
}

void main() {
  testWidgets('Tapping Login with empty fields shows validation message',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(authController: _FakeLoginAuthController()),
      ),
    );

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(
      find.text('Please enter your email and password.'),
      findsOneWidget,
    );
  });
}
