import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool?>? onToggleComplete;
  final Function(SubTask, bool?)? onToggleSubtask;

  const TaskCard({
    Key? key,
    required this.task,
    this.onEdit,
    this.onDelete,
    this.onToggleComplete,
    this.onToggleSubtask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedCount = task.subtasks.where((s) => s.completed).length;
    final hasDue = task.dueDate != null;
    final hasReminder = task.reminder != null;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 8, right: 16, top: 12, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.subtasks.isNotEmpty &&
                        completedCount == task.subtasks.length,
                    tristate: false,
                    onChanged: task.subtasks.isEmpty ? null : onToggleComplete,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration:
                                completedCount == task.subtasks.length &&
                                        task.subtasks.isNotEmpty
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Text(
                    task.description!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (task.subtasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 33),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 6),
                            Text(
                              'Subtasks',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: completedCount == task.subtasks.length &&
                                        task.subtasks.isNotEmpty
                                    ? Colors.green[50]
                                    : (completedCount > 0
                                        ? Colors.grey[100]
                                        : null),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check,
                                      color: completedCount ==
                                                  task.subtasks.length &&
                                              task.subtasks.isNotEmpty
                                          ? Colors.green
                                          : Colors.orange),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$completedCount/${task.subtasks.length}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 38, top: 8, bottom: 8, right: 8),
                        child: LinearProgressIndicator(
                          value: task.subtasks.isEmpty
                              ? 0
                              : completedCount / task.subtasks.length,
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completedCount == task.subtasks.length
                                ? Colors.green
                                : (completedCount > 0
                                    ? Colors.orange
                                    : Colors.blue),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      ...task.subtasks.map((sub) => Padding(
                            padding: const EdgeInsets.only(
                                left: 24, top: 2, bottom: 2),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: sub.completed,
                                  onChanged: (val) =>
                                      onToggleSubtask?.call(sub, val),
                                ),
                                Expanded(
                                  child: Text(
                                    sub.title,
                                    style: TextStyle(
                                      decoration: sub.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: sub.completed ? Colors.grey : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (sub.dueDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: Colors.blue),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${sub.dueDate!.toLocal().toString().split(' ')[0]}',
                                          style: const TextStyle(
                                              color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (sub.reminder != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.alarm,
                                            size: 16, color: Colors.orange),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${sub.reminder!.toLocal().toString().split(' ')[0]}',
                                          style: const TextStyle(
                                              color: Colors.orange),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              Row(
                children: [
                  if (hasDue)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  if (hasDue && hasReminder) const SizedBox(width: 12),
                  if (hasReminder)
                    Row(
                      children: [
                        const Icon(Icons.alarm, size: 18, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'Remind: ${task.reminder!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
