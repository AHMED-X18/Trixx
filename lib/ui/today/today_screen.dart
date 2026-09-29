import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trixx/data/providers/task_providers.dart';
import 'package:trixx/ui/shell/app_shell.dart';
import 'package:trixx/ui/tasks/widgets/task_card.dart';
import 'package:trixx/ui/theme/app_colors.dart';

/// "Aujourd'hui" dashboard — today's tasks at a glance (UC13/UC16 land here
/// once reminders and contextual advice are implemented; for this slice it
/// shows the tasks due today, per P1 of the roadmap).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayTasksProvider);
    final service = ref.read(taskServiceProvider);
    final dateLabel = DateFormat("EEEE d MMMM", 'fr_FR').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bonjour'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            dateLabel[0].toUpperCase() + dateLabel.substring(1),
            style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Priorités du jour',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => AppShell.of(context)?.goToTab(2),
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          todayAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Rien de prévu aujourd\'hui.',
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final task in tasks) ...[
                    TaskCard(
                      task: task,
                      onToggleDone: () => service.toggleStatus(task),
                      onTap: () => AppShell.of(context)?.goToTab(2),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Text('Erreur : $error'),
          ),
        ],
      ),
    );
  }
}
