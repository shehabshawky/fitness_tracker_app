import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker_app/core/di/service_locator.dart';
import 'package:fitness_tracker_app/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  testWidgets('Classic Fitness tracker app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessTrackerApp());
    await tester.pumpAndSettle();

    // Verify classic title is rendered
    expect(find.text('Fitness Tracker'), findsOneWidget);

    // Verify metric cards titles are rendered
    expect(find.text('STEPS'), findsOneWidget);
    expect(find.text('CALORIES'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);

    // Verify quick step logger button is rendered
    expect(find.text('+500'), findsOneWidget);
    expect(find.text('+1,000'), findsOneWidget);

    // Verify weekly activity chart header
    expect(find.text('WEEKLY ACTIVITY'), findsOneWidget);

    // Tap quick +500 steps
    await tester.tap(find.text('+500'));
    await tester.pumpAndSettle();

    // Tap Log button in app bar
    await tester.tap(find.text('Log').first);
    await tester.pumpAndSettle();

    // Verify bottom sheet modal opened
    expect(find.text('Log Fitness Activity'), findsOneWidget);
    expect(find.text('EXERCISE TYPE'), findsOneWidget);
  });
}
