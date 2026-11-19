import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_list/main.dart';

/// Aggiunge un'attività passando dalla schermata di creazione.
Future<void> addTask(
  WidgetTester tester,
  String title, {
  bool important = false,
}) async {
  await tester.tap(find.text('Nuova attività'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), title);
  if (important) await tester.tap(find.byType(Switch));
  await tester.tap(find.text('Aggiungi'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('S2 variante: elenco vuoto mostra come aggiungere', (
    tester,
  ) async {
    await tester.pumpWidget(const TodoApp());
    expect(find.text('Nessuna attività'), findsOneWidget);
    expect(find.textContaining('per aggiungerne una'), findsOneWidget);
  });

  testWidgets('S1: aggiunge attività con messaggio di conferma', (
    tester,
  ) async {
    await tester.pumpWidget(const TodoApp());
    await addTask(tester, 'Studiare Flutter', important: true);

    expect(find.text('Studiare Flutter'), findsOneWidget);
    expect(find.text('Da fare'), findsOneWidget);
    expect(find.text('Importante'), findsOneWidget);
    expect(find.text('Attività "Studiare Flutter" aggiunta'), findsOneWidget);
    expect(find.text('Completate: 0 su 1'), findsOneWidget);
  });

  testWidgets('S1 variante: titolo mancante, errore che poi scompare', (
    tester,
  ) async {
    await tester.pumpWidget(const TodoApp());
    await tester.tap(find.text('Nuova attività'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();
    expect(find.text('Inserisci un titolo per l\'attività'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget); // ancora sulla schermata

    await tester.enterText(find.byType(TextField), 'Fare la spesa');
    await tester.pump();
    expect(find.text('Inserisci un titolo per l\'attività'), findsNothing);
  });

  testWidgets('S1 variante: rinuncia con il tasto indietro', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.tap(find.text('Nuova attività'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Non salvare');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Nessuna attività'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('S3: cambia stato e aggiorna il conteggio', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await addTask(tester, 'A');
    await addTask(tester, 'B');
    expect(find.text('Completate: 0 su 2'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('Completate: 1 su 2'), findsOneWidget);
    expect(find.text('Completata'), findsOneWidget);

    await tester.tap(find.text('A')); // tocco sulla riga: torna "da fare"
    await tester.pump();
    expect(find.text('Completate: 0 su 2'), findsOneWidget);
  });

  testWidgets('S4: elimina con conferma, rinuncia non elimina', (
    tester,
  ) async {
    await tester.pumpWidget(const TodoApp());
    await addTask(tester, 'A');
    await addTask(tester, 'B');

    await tester.tap(find.byTooltip('Elimina').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Completate: 0 su 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Elimina').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Elimina'));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsNothing);
    expect(find.text('Completate: 0 su 1'), findsOneWidget);
  });
}
