import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifequest/features/onboarding/age_screen.dart';
import 'package:lifequest/features/onboarding/onboarding_state.dart';

void main() {
  testWidgets('Age screen shows stepper and continue', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: AgeScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('How old are you?'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('Onboarding draft updates age', (WidgetTester tester) async {
    late OnboardingDraft draft;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              draft = ref.watch(onboardingDraftProvider);
              return AgeScreen();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(draft.age, 8);
  });
}
