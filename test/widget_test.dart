import 'package:flutter_test/flutter_test.dart';
import 'package:health_care_ai/main.dart';
import 'package:provider/provider.dart';
import 'package:health_care_ai/providers/chat_provider.dart';


void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const BodyBuildApp(),
      ),
    );

    // Verify that the title is present
    expect(find.text('BodyBuild AI'), findsWidgets);
  });
}
