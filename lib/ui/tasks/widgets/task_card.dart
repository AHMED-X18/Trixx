import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trixx/domain/models/task.dart';
import 'package:trixx/ui/theme/app_colors.dart';

import 'priority_chip.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleDone,
    required this.onTap,
  });

  final Task task;
  final VoidCallback onToggleDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.termine;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Opacity(
          opacity: isDone ? 0.6 : 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onToggleDone,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? AppColors.success : Colors.transparent,
                      border: Border.all(
                        color: isDone ? AppColors.success : AppColors.borderLight,
                        width: 2,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      if (task.dueAt != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          DateFormat('dd/MM · HH:mm').format(task.dueAt!),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PriorityChip(priority: task.priority),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
