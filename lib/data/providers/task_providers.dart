import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixx/data/providers/isar_provider.dart';
import 'package:trixx/data/repositories/isar_task_repository.dart';
import 'package:trixx/domain/models/task.dart';
import 'package:trixx/domain/models/task_filter.dart';
import 'package:trixx/domain/repositories/task_repository.dart';
import 'package:trixx/domain/services/task_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return IsarTaskRepository(ref.watch(isarProvider));
});

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.watch(taskRepositoryProvider));
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskServiceProvider).watchTasks();
});

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => const TaskFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setPriority(TaskPriority? priority) =>
      state = priority == null ? state.copyWith(clearPriority: true) : state.copyWith(priority: priority);

  void setStatus(TaskStatus? status) =>
      state = status == null ? state.copyWith(clearStatus: true) : state.copyWith(status: status);

  void clear() => state = const TaskFilter();
}

final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

/// Tasks matching the active [taskFilterProvider], derived from the live
/// Isar stream.
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final filter = ref.watch(taskFilterProvider);
  final service = ref.watch(taskServiceProvider);
  return tasksAsync.whenData((tasks) => service.filterTasks(tasks, filter));
});

/// Tasks due today, for the "Aujourd'hui" dashboard.
final todayTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final service = ref.watch(taskServiceProvider);
  return tasksAsync.whenData((tasks) => service.tasksDueToday(tasks));
});
