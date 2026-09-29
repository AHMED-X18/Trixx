import 'dart:async';

import 'package:trixx/domain/models/task.dart';
import 'package:trixx/domain/repositories/task_repository.dart';

/// In-memory repository used to unit test [TaskService] without touching
/// Isar, matching the cahier des charges' split between domain unit tests
/// (fakes) and on-device integration tests (real Isar).
class FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];
  final StreamController<List<Task>> _controller = StreamController<List<Task>>.broadcast();
  int _nextId = 1;

  void _emit() => _controller.add(List.unmodifiable(_tasks));

  @override
  Stream<List<Task>> watchAll() async* {
    yield List.unmodifiable(_tasks);
    yield* _controller.stream;
  }

  @override
  Future<Task> create(Task task) async {
    final created = task.copyWith(id: _nextId++);
    _tasks.add(created);
    _emit();
    return created;
  }

  @override
  Future<Task> update(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      throw StateError('Task ${task.id} not found');
    }
    _tasks[index] = task;
    _emit();
    return task;
  }

  @override
  Future<void> delete(int id) async {
    _tasks.removeWhere((t) => t.id == id);
    _emit();
  }

  @override
  Future<void> deleteMany(List<int> ids) async {
    _tasks.removeWhere((t) => ids.contains(t.id));
    _emit();
  }

  void dispose() => _controller.close();
}
