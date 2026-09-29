import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trixx/data/providers/task_providers.dart';
import 'package:trixx/domain/models/task.dart';
import 'package:trixx/domain/services/task_service.dart';
import 'package:trixx/ui/tasks/widgets/priority_chip.dart';
import 'package:trixx/ui/theme/app_colors.dart';

/// Creation or edition form (UC04 / UC06 / UC07), matching the "Nouvelle
/// tâche" / "Détail de la tâche" mockups.
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.existing});

  final Task? existing;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  DateTime? _dueAt;
  String? _error;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _priority = existing?.priority ?? TaskPriority.moyen;
    _dueAt = existing?.dueAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _dueAt != null ? TimeOfDay.fromDateTime(_dueAt!) : const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _dueAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    final service = ref.read(taskServiceProvider);
    try {
      if (_isEditing) {
        await service.updateTask(
          widget.existing!.copyWith(
            title: _titleController.text,
            description: _descriptionController.text,
            dueAt: _dueAt,
            clearDueAt: _dueAt == null,
            priority: _priority,
          ),
        );
      } else {
        await service.createTask(
          title: _titleController.text,
          description: _descriptionController.text,
          dueAt: _dueAt,
          priority: _priority,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on TaskValidationException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              'Enregistrer',
              style: TextStyle(
                color: _saving ? AppColors.textSecondaryLight : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEAEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ),
            const SizedBox(height: 16),
          ],
          const Text('Titre', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Ex. Appeler le dentiste'),
          ),
          const SizedBox(height: 18),
          const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Ajouter des détails…'),
          ),
          const SizedBox(height: 18),
          const Text('Date et heure', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    _dueAt == null ? 'Aucune échéance' : DateFormat('dd/MM/yyyy · HH:mm').format(_dueAt!),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (_dueAt != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _dueAt = null),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Priorité', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          PriorityChoiceRow(
            selected: _priority,
            onChanged: (p) => setState(() => _priority = p),
          ),
        ],
      ),
    );
  }
}
