import 'package:isar/isar.dart';
import 'package:trixx/data/isar/task_entity.dart';
import 'package:trixx/domain/models/task.dart';
import 'package:trixx/domain/repositories/task_repository.dart';

class IsarTaskRepository implements TaskRepository {
  IsarTaskRepository(this._isar);

  final Isar _isar;

  @override
  Stream<List<Task>> watchAll() {
    return _isar.taskEntitys.where().watch(fireImmediately: true).map(
          (entities) => entities.map((e) => e.toDomain()).toList(),
        );
  }

  @override
  Future<Task> create(Task task) async {
    final entity = TaskEntity.fromDomain(task);
    await _isar.writeTxn(() => _isar.taskEntitys.put(entity));
    return entity.toDomain();
  }

  @override
  Future<Task> update(Task task) async {
    final entity = TaskEntity.fromDomain(task);
    await _isar.writeTxn(() => _isar.taskEntitys.put(entity));
    return entity.toDomain();
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.taskEntitys.delete(id));
  }

  @override
  Future<void> deleteMany(List<int> ids) async {
    await _isar.writeTxn(() => _isar.taskEntitys.deleteAll(ids));
  }
}
