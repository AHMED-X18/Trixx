import '../models/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> watchAll();
  Future<Task> create(Task task);
  Future<Task> update(Task task);
  Future<void> delete(int id);
  Future<void> deleteMany(List<int> ids);
}
