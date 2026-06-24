import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/core/tokens/lq_tokens.dart';
import 'package:lifequest/design/lq_mastery_card.dart';

void main() {
  testWidgets('LQCardQuickActions fire callbacks', (tester) async {
    var earn = false;
    var save = false;
    var city = false;
    var progress = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LQCardQuickActions(
            colors: LQColors.penny,
            onEarn: () => earn = true,
            onSave: () => save = true,
            onCity: () => city = true,
            onProgress: () => progress = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Earn'));
    await tester.tap(find.text('Save'));
    await tester.tap(find.text('City'));
    await tester.tap(find.text('Progress'));
    await tester.pump();

    expect(earn, isTrue);
    expect(save, isTrue);
    expect(city, isTrue);
    expect(progress, isTrue);
  });
}
