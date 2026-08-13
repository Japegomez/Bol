import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/app.dart';
import 'package:meal_planner/core/config/app_branding.dart';

void main() {
  testWidgets('shows login screen when unauthenticated', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MealPlannerApp()));
    await tester.pumpAndSettle();

    expect(find.text(AppBranding.displayName), findsOneWidget);
  });
}
