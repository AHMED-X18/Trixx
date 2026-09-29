import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trixx/data/providers/task_providers.dart';
import 'package:trixx/domain/models/task.dart';
import 'package:trixx/domain/services/task_service.dart';
import 'package:trixx/ui/planning/planning_screen.dart';

import '../fakes/fake_task_repository.dart';

void main() {
  late FakeTaskRepository repository;

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        taskServiceProvider.overrideWithValue(TaskService(repository)),
      ],
      child: const MaterialApp(home: PlanningScreen()),
    );
  }

  setUp(() => repository = FakeTaskRepository());
  tearDown(() => repository.dispose());

  testWidgets('shows an empty state when there are no tasks', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Aucune tâche pour le moment.'), findsOneWidget);
  });

  testWidgets('creating a task from the form makes it appear in the list', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Ex. Appeler le dentiste'), 'Appeler le dentiste');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Appeler le dentiste'), findsOneWidget);
  });

  testWidgets('search filters the visible tasks', (tester) async {
    await repository.create(const Task(title: 'Préparer la revue produit'));
    await repository.create(const Task(title: 'Appeler le dentiste'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Préparer la revue produit'), findsOneWidget);
    expect(find.text('Appeler le dentiste'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Rechercher une tâche…'), 'dentiste');
    await tester.pumpAndSettle();

    expect(find.text('Préparer la revue produit'), findsNothing);
    expect(find.text('Appeler le dentiste'), findsOneWidget);
  });

  testWidgets('tapping the checkbox marks a task as done', (tester) async {
    await repository.create(const Task(title: 'Séance running'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text('Séance running'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });
}
