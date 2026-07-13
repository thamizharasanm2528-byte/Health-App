import 'package:flutter_test/flutter_test.dart';
import 'package:health_companion/main.dart';
import 'package:health_companion/features/splash/presentation/interactive_initialization_screen.dart';

void main() {
  testWidgets('App renders initialization screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthCompanionApp());

    // Build the first frame.
    await tester.pump();

    expect(find.byType(InteractiveInitializationScreen), findsOneWidget);
  });
}
