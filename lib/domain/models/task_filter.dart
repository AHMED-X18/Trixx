import 'task.dart';

class TaskFilter {
  const TaskFilter({this.query = '', this.priority, this.status});

  final String query;
  final TaskPriority? priority;
  final TaskStatus? status;

  bool get isEmpty => query.isEmpty && priority == null && status == null;

  TaskFilter copyWith({
    String? query,
    TaskPriority? priority,
    bool clearPriority = false,
    TaskStatus? status,
    bool clearStatus = false,
  }) {
    return TaskFilter(
      query: query ?? this.query,
      priority: clearPriority ? null : (priority ?? this.priority),
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskFilter && query == other.query && priority == other.priority && status == other.status;

  @override
  int get hashCode => Object.hash(query, priority, status);
}
