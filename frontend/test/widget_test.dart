import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_project/main.dart';

void main() {
  testWidgets('shows placement portal landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const PlacementPortalApp());

    expect(
      find.text('Build your career pathway with clarity and confidence.'),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Placement outcomes at a glance'), findsOneWidget);
  });
}

