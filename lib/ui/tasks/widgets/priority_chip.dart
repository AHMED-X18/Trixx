import 'package:flutter/material.dart';
import 'package:trixx/domain/models/task.dart';
import 'package:trixx/ui/theme/app_colors.dart';

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.priorityBackground(priority),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        AppColors.priorityLabel(priority),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class PriorityChoiceRow extends StatelessWidget {
  const PriorityChoiceRow({super.key, required this.selected, required this.onChanged});

  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = priority == selected;
        final color = AppColors.priorityColor(priority);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(priority),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.priorityBackground(priority) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: isSelected ? color : AppColors.borderLight),
                ),
                child: Text(
                  AppColors.priorityLabel(priority),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
