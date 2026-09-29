import 'package:flutter_test/flutter_test.dart';
import 'package:trixx/domain/models/task.dart';
import 'package:trixx/domain/models/task_filter.dart';
import 'package:trixx/domain/services/task_service.dart';

import '../fakes/fake_task_repository.dart';

void main() {
  late FakeTaskRepository repository;
  late TaskService service;

  setUp(() {
    repository = FakeTaskRepository();
    service = TaskService(repository);
  });

  tearDown(() => repository.dispose());

  group('createTask', () {
    test('creates a task with the given fields and status À faire', () async {
      final task = await service.createTask(
        title: 'Appeler le dentiste',
        priority: TaskPriority.eleve,
      );

      expect(task.id, isNotNull);
      expect(task.title, 'Appeler le dentiste');
      expect(task.priority, TaskPriority.eleve);
      expect(task.status, TaskStatus.aFaire);
    });

    test('trims the title and treats a blank description as null', () async {
      final task = await service.createTask(title: '  Réviser  ', description: '   ');

      expect(task.title, 'Réviser');
      expect(task.description, isNull);
    });

    test('rejects an empty title', () async {
      expect(
        () => service.createTask(title: '   '),
        throwsA(isA<TaskValidationException>()),
      );
    });
  });

  group('updateTask', () {
    test('persists changes to an existing task', () async {
      final created = await service.createTask(title: 'Préparer la revue produit');

      final updated = await service.updateTask(created.copyWith(priority: TaskPriority.critique));

      expect(updated.priority, TaskPriority.critique);
    });

    test('rejects a task without an id', () {
      const draft = Task(title: 'Sans id');
      expect(() => service.updateTask(draft), throwsA(isA<TaskValidationException>()));
    });

    test('rejects an empty title on update', () async {
      final created = await service.createTask(title: 'Titre valide');
      expect(
        () => service.updateTask(created.copyWith(title: '')),
        throwsA(isA<TaskValidationException>()),
      );
    });
  });

  group('toggleStatus', () {
    test('flips À faire to Terminé and back', () async {
      final created = await service.createTask(title: 'Séance running');

      final done = await service.toggleStatus(created);
      expect(done.status, TaskStatus.termine);

      final undone = await service.toggleStatus(done);
      expect(undone.status, TaskStatus.aFaire);
    });
  });

  group('deleteTask / deleteTasks', () {
    test('removes a single task', () async {
      final created = await service.createTask(title: 'À supprimer');
      await service.deleteTask(created.id!);

      final remaining = await service.watchTasks().first;
      expect(remaining, isEmpty);
    });

    test('removes several tasks at once', () async {
      final a = await service.createTask(title: 'A');
      final b = await service.createTask(title: 'B');
      final c = await service.createTask(title: 'C');

      await service.deleteTasks([a.id!, b.id!]);

      final remaining = await service.watchTasks().first;
      expect(remaining, [c]);
    });
  });

  group('filterTasks', () {
    final tasks = [
      const Task(id: 1, title: 'Préparer la revue produit', priority: TaskPriority.eleve),
      const Task(id: 2, title: 'Déjeuner avec Marc', priority: TaskPriority.moyen, status: TaskStatus.termine),
      const Task(id: 3, title: 'Appeler le dentiste', priority: TaskPriority.critique),
    ];

    test('matches title case-insensitively', () {
      final result = service.filterTasks(tasks, const TaskFilter(query: 'DENTISTE'));
      expect(result, [tasks[2]]);
    });

    test('filters by priority', () {
      final result = service.filterTasks(tasks, const TaskFilter(priority: TaskPriority.eleve));
      expect(result, [tasks[0]]);
    });

    test('filters by status', () {
      final result = service.filterTasks(tasks, const TaskFilter(status: TaskStatus.termine));
      expect(result, [tasks[1]]);
    });

    test('combines query, priority and status', () {
      final result = service.filterTasks(
        tasks,
        const TaskFilter(query: 'marc', status: TaskStatus.termine, priority: TaskPriority.moyen),
      );
      expect(result, [tasks[1]]);
    });

    test('returns everything when the filter is empty', () {
      final result = service.filterTasks(tasks, const TaskFilter());
      expect(result, tasks);
    });
  });

  group('tasksDueToday', () {
    test('keeps only tasks due on the given day, sorted by time', () {
      final now = DateTime(2026, 9, 14, 12);
      final tasks = [
        Task(id: 1, title: 'Plus tard aujourd\'hui', dueAt: DateTime(2026, 9, 14, 18)),
        Task(id: 2, title: 'Demain', dueAt: DateTime(2026, 9, 15, 9)),
        Task(id: 3, title: 'Tôt aujourd\'hui', dueAt: DateTime(2026, 9, 14, 9)),
        const Task(id: 4, title: 'Sans échéance'),
      ];

      final result = service.tasksDueToday(tasks, now: now);

      expect(result.map((t) => t.id), [3, 1]);
    });
  });
}
