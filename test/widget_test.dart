import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker/data/sample_entries.dart';
import 'package:mood_tracker/main.dart';
import 'package:mood_tracker/models/mood_entry.dart';
import 'package:mood_tracker/widgets/mood_card.dart';

// Self-check for Lab 4, Exercises 1 and 2. Run it with: flutter test
//
// Both tests fail on the starter code and pass once Exercise 2 is done.
// Exercise 3 changes what the Save button should do. Part of that task is
// to update these tests so they check the new requirement.

/// Renders the app in a window tall enough for every card to be built.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MoodTrackerApp());
}

Finder get saveButton => find.widgetWithText(FilledButton, 'Save entry');

void main() {
  testWidgets('saving without a score shows an error and adds nothing', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Choose a score from 1 to 10'), findsOneWidget);
    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length));
  });

  testWidgets('saving an entry puts it at the top of the history', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Rainy walk home');
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(
      find.descendant(
        of: find.byType(MoodCard).first,
        matching: find.text('Rainy walk home'),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('a 2001-character note shows an error and adds nothing', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'x' * (maxNoteLength + 1));
    await tester.tap(saveButton);
    await tester.pump();

    expect(
      find.text('Note is too long (maximum $maxNoteLength characters)'),
      findsOneWidget,
    );
    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length));
  });

  testWidgets('a 2000-character note is added and clears the form', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '7'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'x' * maxNoteLength);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    expect(find.text('x' * maxNoteLength), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('an empty note is added as null and clears the form', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '5'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.byType(MoodCard), findsNWidgets(sampleEntries.length + 1));
    final newestCard = tester.widget<MoodCard>(find.byType(MoodCard).first);
    expect(newestCard.entry.note, isNull);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '5')).selected,
      isFalse,
    );
  });

  testWidgets('a valid submission clears a previous error', (tester) async {
    await pumpApp(tester);

    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text('Choose a score from 1 to 10'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '4'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Valid entry');
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Choose a score from 1 to 10'), findsNothing);
  });
}
