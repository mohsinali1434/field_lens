import 'package:field_lens/app/app.dart';
import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUp(() async {
    await configureTestDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('FieldLens app renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const FieldLensApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Good '), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Inspections'), findsOneWidget);
  });

  testWidgets('navigation switches to inspections tab with demo data',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FieldLensApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inspections'));
    await tester.pumpAndSettle();

    expect(find.text('Residential Property Inspection'), findsOneWidget);
    expect(find.text('New Inspection'), findsWidgets);
  });

  testWidgets('navigation switches to search tab', (WidgetTester tester) async {
    await tester.pumpWidget(const FieldLensApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.text('Search'), findsWidgets);
  });

  testWidgets('navigation switches to settings tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FieldLensApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Data'), findsOneWidget);
  });
}
