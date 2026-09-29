enum TaskPriority { faible, moyen, eleve, critique }

enum TaskStatus { aFaire, enCours, termine }

class Task {
  const Task({
    this.id,
    required this.title,
    this.description,
    this.dueAt,
    this.priority = TaskPriority.moyen,
    this.status = TaskStatus.aFaire,
  });

  final int? id;
  final String title;
  final String? description;
  final DateTime? dueAt;
  final TaskPriority priority;
  final TaskStatus status;

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueAt,
    bool clearDueAt = false,
    TaskPriority? priority,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          dueAt == other.dueAt &&
          priority == other.priority &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, title, description, dueAt, priority, status);
}
