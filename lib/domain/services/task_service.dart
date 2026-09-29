import '../models/task.dart';
import '../models/task_filter.dart';
import '../repositories/task_repository.dart';

class TaskValidationException implements Exception {
  TaskValidationException(this.message);
  final String message;

  @override
  String toString() => 'TaskValidationException: $message';
}

class TaskService {
  TaskService(this._repository);

  final TaskRepository _repository;

  Stream<List<Task>> watchTasks() => _repository.watchAll();

  Future<Task> createTask({
    required String title,
    String? description,
    DateTime? dueAt,
    TaskPriority priority = TaskPriority.moyen,
  }) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw TaskValidationException('Le titre est obligatoire.');
    }
    final task = Task(
      title: trimmedTitle,
      description: (description?.trim().isEmpty ?? true) ? null : description!.trim(),
      dueAt: dueAt,
      priority: priority,
      status: TaskStatus.aFaire,
    );
    return _repository.create(task);
  }

  Future<Task> updateTask(Task task) {
    if (task.id == null) {
      throw TaskValidationException('Impossible de modifier une tâche non enregistrée.');
    }
    if (task.title.trim().isEmpty) {
      throw TaskValidationException('Le titre est obligatoire.');
    }
    return _repository.update(task);
  }

  Future<Task> toggleStatus(Task task) {
    final nextStatus = task.status == TaskStatus.termine ? TaskStatus.aFaire : TaskStatus.termine;
    return updateTask(task.copyWith(status: nextStatus));
  }

  Future<void> deleteTask(int id) => _repository.delete(id);

  Future<void> deleteTasks(List<int> ids) => _repository.deleteMany(ids);

  /// Pure filtering logic (recherche/filtres — UC09), kept separate from
  /// persistence so it can be tested without a repository.
  List<Task> filterTasks(List<Task> tasks, TaskFilter filter) {
    final query = filter.query.trim().toLowerCase();
    return tasks.where((task) {
      final matchesQuery = query.isEmpty || task.title.toLowerCase().contains(query);
      final matchesPriority = filter.priority == null || task.priority == filter.priority;
      final matchesStatus = filter.status == null || task.status == filter.status;
      return matchesQuery && matchesPriority && matchesStatus;
    }).toList();
  }

  /// Tasks due today, used by the "Aujourd'hui" dashboard.
  List<Task> tasksDueToday(List<Task> tasks, {DateTime? now}) {
    final today = now ?? DateTime.now();
    return tasks.where((task) {
      final due = task.dueAt;
      if (due == null) return false;
      return due.year == today.year && due.month == today.month && due.day == today.day;
    }).toList()
      ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
  }
}
