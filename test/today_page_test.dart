import 'package:bloom_menstrual_health_wellness_tracker/screens/today_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TodayPage renders the main interface', (
    WidgetTester tester,
  ) async {
    final tabNotifier = ValueNotifier<int>(0);
    await tester.pumpWidget(MaterialApp(home: TodayPage(tabNotifier: tabNotifier)));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Sarah'), findsOneWidget);
    expect(find.text('Symptoms Tracker'), findsOneWidget);
    expect(find.text('Daily Notifications'), findsOneWidget);
  });
}
