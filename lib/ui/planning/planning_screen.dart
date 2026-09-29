import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trixx/data/providers/task_providers.dart';
import 'package:trixx/domain/models/task.dart';
import 'package:trixx/ui/tasks/task_form_screen.dart';
import 'package:trixx/ui/tasks/widgets/task_card.dart';
import 'package:trixx/ui/theme/app_colors.dart';

/// UC06/UC07/UC08/UC09 — full task management: create, edit, delete,
/// search and filter.
class PlanningScreen extends ConsumerWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final filterNotifier = ref.read(taskFilterProvider.notifier);
    final service = ref.read(taskServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TaskFormScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              onChanged: filterNotifier.setQuery,
              decoration: const InputDecoration(
                hintText: 'Rechercher une tâche…',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: 'Toutes',
                  selected: filter.priority == null && filter.status == null,
                  onTap: filterNotifier.clear,
                ),
                const SizedBox(width: 8),
                for (final priority in TaskPriority.values) ...[
                  _FilterChip(
                    label: AppColors.priorityLabel(priority),
                    selected: filter.priority == priority,
                    onTap: () => filterNotifier.setPriority(filter.priority == priority ? null : priority),
                  ),
                  const SizedBox(width: 8),
                ],
                _FilterChip(
                  label: 'Terminées',
                  selected: filter.status == TaskStatus.termine,
                  onTap: () => filterNotifier
                      .setStatus(filter.status == TaskStatus.termine ? null : TaskStatus.termine),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Text(
                      filter.isEmpty ? 'Aucune tâche pour le moment.' : 'Aucune tâche ne correspond.',
                      style: const TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _confirmDelete(context),
                      onDismissed: (_) => service.deleteTask(task.id!),
                      child: TaskCard(
                        task: task,
                        onToggleDone: () => service.toggleStatus(task),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TaskFormScreen(existing: task)),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur : $error')),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimaryLight : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.textPrimaryLight : AppColors.borderLight),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}
