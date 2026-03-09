import 'package:apdp_app/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App start shows either Welcome screen or Home title', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final welcomeHeadline = find.text('Baby Preparation Checklist');
    final homeTitle = find.text('My Baby Checklist');

    expect(
      welcomeHeadline.evaluate().isNotEmpty || homeTitle.evaluate().isNotEmpty,
      true,
    );
  });
}
