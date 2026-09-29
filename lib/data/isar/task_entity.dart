import 'package:isar/isar.dart';
import 'package:trixx/domain/models/task.dart';

part 'task_entity.g.dart';

@collection
class TaskEntity {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;
  DateTime? dueAt;

  @enumerated
  late TaskPriority priority;

  @enumerated
  late TaskStatus status;

  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      dueAt: dueAt,
      priority: priority,
      status: status,
    );
  }

  static TaskEntity fromDomain(Task task) {
    final entity = TaskEntity()
      ..title = task.title
      ..description = task.description
      ..dueAt = task.dueAt
      ..priority = task.priority
      ..status = task.status;
    if (task.id != null) {
      entity.id = task.id!;
    }
    return entity;
  }
}
