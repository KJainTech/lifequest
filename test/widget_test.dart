import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifequest/features/splash/splash_screen.dart';

void main() {
  testWidgets('Splash screen renders LifeQuest brand', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('LifeQuest'), findsOneWidget);
    expect(find.text('Start Your Quest'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
  });
}
