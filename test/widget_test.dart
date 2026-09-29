import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trixx/data/providers/task_providers.dart';
import 'package:trixx/domain/services/task_service.dart';
import 'package:trixx/ui/shell/app_shell.dart';
import 'package:trixx/ui/theme/app_theme.dart';

import 'fakes/fake_task_repository.dart';

void main() {
  testWidgets('the 3-tab shell renders and switches between Aujourd\'hui, Chat and Planning', (tester) async {
    final repository = FakeTaskRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskServiceProvider.overrideWithValue(TaskService(repository))],
        child: MaterialApp(theme: AppTheme.light(), home: const AppShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bonjour'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Chat IA — bientôt disponible'), findsOneWidget);

    await tester.tap(find.text('Planning'));
    await tester.pumpAndSettle();
    expect(find.text('Planning'), findsWidgets);
  });
}
