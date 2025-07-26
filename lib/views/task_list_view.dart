import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskListView extends StatefulWidget {
  final String userId;
  const TaskListView({Key? key, required this.userId}) : super(key: key);

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  late TaskService _taskService;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _taskService = TaskService(userId: widget.userId);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    debugPrint('[TASKS] Loading tasks...');
    setState(() {
      _tasks = _taskService.getAllTasks();
      _tasks.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    });
    debugPrint('[TASKS] Loaded ${_tasks.length} tasks');
  }

  void _addTask() async {
    debugPrint('[TASKS] Add Task button pressed');
    final newTask = Task(
      id: UniqueKey().toString(),
      title: '',
      subtasks: [],
    );
    await _editTask(newTask, isNew: true);
  }

  Future<void> _editTask(Task task, {bool isNew = false}) async {
    debugPrint('[TASKS] ${isNew ? 'Creating' : 'Editing'} task: ${task.id}');
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description ?? '');
    DateTime? dueDate = task.dueDate;
    DateTime? reminder = task.reminder;
    List<SubTask> subtasks = List.from(task.subtasks);
    List<FocusNode> subtaskFocusNodes =
        List.generate(subtasks.length, (_) => FocusNode());
    bool expanded = true;
    String? errorText;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Ensure focus nodes match subtasks
            while (subtaskFocusNodes.length < subtasks.length) {
              subtaskFocusNodes.add(FocusNode());
            }
            while (subtaskFocusNodes.length > subtasks.length) {
              subtaskFocusNodes.removeLast();
            }
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isNew ? 'Add Task' : 'Edit Task',
                            style: Theme.of(context).textTheme.titleLarge),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: const OutlineInputBorder(),
                        errorText: errorText,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                      onChanged: (val) =>
                          debugPrint('[TASKS] Title changed: $val'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 3,
                      onChanged: (val) =>
                          debugPrint('[TASKS] Description changed: $val'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(dueDate != null
                                ? 'Due: ${dueDate!.toLocal().toString().split(' ')[0]}'
                                : 'Set Due Date'),
                            onPressed: () async {
                              debugPrint('[TASKS] Due date picker opened');
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dueDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                debugPrint('[TASKS] Due date set: $picked');
                                setState(() => dueDate = picked);
                              }
                            },
                          ),
                        ),
                        if (dueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              debugPrint('[TASKS] Due date cleared');
                              setState(() => dueDate = null);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.alarm),
                            label: Text(reminder != null
                                ? 'Reminder: ${reminder!.toLocal().toString().split(' ')[0]}'
                                : 'Set Reminder'),
                            onPressed: () async {
                              debugPrint('[TASKS] Reminder picker opened');
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: reminder ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                debugPrint('[TASKS] Reminder set: $picked');
                                setState(() => reminder = picked);
                              }
                            },
                          ),
                        ),
                        if (reminder != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              debugPrint('[TASKS] Reminder cleared');
                              setState(() => reminder = null);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Subtasks',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                              expanded ? Icons.expand_less : Icons.expand_more),
                          onPressed: () => setState(() => expanded = !expanded),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Add Subtask',
                          onPressed: () {
                            debugPrint('[TASKS] Add subtask pressed');
                            setState(() {
                              subtasks.add(SubTask(
                                id: UniqueKey().toString(),
                                title: '',
                              ));
                            });
                          },
                        ),
                      ],
                    ),
                    if (expanded)
                      ...subtasks.asMap().entries.map((entry) {
                        final i = entry.key;
                        final sub = entry.value;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color:
                              sub.completed ? Colors.green[50] : Colors.white,
                          elevation: sub.completed ? 0 : 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: sub.completed,
                                  onChanged: (val) {
                                    debugPrint(
                                        '[TASKS] Subtask completed toggled: ${sub.id} -> $val');
                                    setState(() => subtasks[i] = SubTask(
                                          id: sub.id,
                                          title: sub.title,
                                          completed: val ?? false,
                                          reminder: sub.reminder,
                                          dueDate: sub.dueDate,
                                        ));
                                  },
                                ),
                                Expanded(
                                  child: TextFormField(
                                    focusNode: subtaskFocusNodes[i],
                                    initialValue: sub.title,
                                    decoration: InputDecoration(
                                      labelText: 'Subtask',
                                      border: InputBorder.none,
                                      labelStyle: TextStyle(
                                        color:
                                            sub.completed ? Colors.green : null,
                                        fontWeight: sub.completed
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    style: TextStyle(
                                      decoration: sub.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: sub.completed
                                          ? Colors.green[700]
                                          : null,
                                    ),
                                    onChanged: (val) {
                                      debugPrint(
                                          '[TASKS] Subtask title changed: ${sub.id} -> $val');
                                      setState(() => subtasks[i] = SubTask(
                                            id: sub.id,
                                            title: val,
                                            completed: sub.completed,
                                            reminder: sub.reminder,
                                            dueDate: sub.dueDate,
                                          ));
                                    },
                                    onFieldSubmitted: (val) {
                                      // Only add if last or empty
                                      if (i == subtasks.length - 1 &&
                                          val.trim().isNotEmpty) {
                                        setState(() {
                                          subtasks.add(SubTask(
                                            id: UniqueKey().toString(),
                                            title: '',
                                          ));
                                          subtaskFocusNodes.add(FocusNode());
                                        });
                                        // Focus the new subtask
                                        Future.delayed(
                                            Duration(milliseconds: 100), () {
                                          subtaskFocusNodes.last.requestFocus();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.alarm),
                                  tooltip: 'Set Reminder',
                                  onPressed: () async {
                                    debugPrint(
                                        '[TASKS] Subtask reminder picker opened: ${sub.id}');
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          sub.reminder ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      debugPrint(
                                          '[TASKS] Subtask reminder set: ${sub.id} -> $picked');
                                      setState(() => subtasks[i] = SubTask(
                                            id: sub.id,
                                            title: sub.title,
                                            completed: sub.completed,
                                            reminder: picked,
                                            dueDate: sub.dueDate,
                                          ));
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  tooltip: 'Set Due Date',
                                  onPressed: () async {
                                    debugPrint(
                                        '[TASKS] Subtask due date picker opened: ${sub.id}');
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          sub.dueDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      debugPrint(
                                          '[TASKS] Subtask due date set: ${sub.id} -> $picked');
                                      setState(() => subtasks[i] = SubTask(
                                            id: sub.id,
                                            title: sub.title,
                                            completed: sub.completed,
                                            reminder: sub.reminder,
                                            dueDate: picked,
                                          ));
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    debugPrint(
                                        '[TASKS] Subtask deleted: ${sub.id}');
                                    setState(() {
                                      subtasks.removeAt(i);
                                      subtaskFocusNodes.removeAt(i);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.trim().isEmpty) {
                                setState(() => errorText = 'Title required');
                                debugPrint(
                                    '[TASKS] Validation failed: Title required');
                                return;
                              }
                              final updated = Task(
                                id: task.id,
                                title: titleController.text.trim(),
                                description: descController.text.trim(),
                                dueDate: dueDate,
                                reminder: reminder,
                                subtasks: subtasks,
                              );
                              if (isNew) {
                                debugPrint(
                                    '[TASKS] Adding new task: ${updated.title}');
                                await _taskService.addTask(updated);
                              } else {
                                debugPrint(
                                    '[TASKS] Saving edits to task: ${updated.title}');
                                await _taskService.updateTask(updated);
                              }
                              _loadTasks();
                              debugPrint('[TASKS] Task saved: ${updated.id}');
                              Navigator.pop(context);
                            },
                            child: Text(isNew ? 'Add Task' : 'Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteTask(Task task) async {
    debugPrint('[TASKS] Delete requested for task: ${task.id}');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
          ),
        ],
      ),
    );
    if (confirm == true) {
      debugPrint('[TASKS] Deleting task: ${task.id}');
      await _taskService.deleteTask(task.id);
      _loadTasks();
      debugPrint('[TASKS] Task deleted: ${task.id}');
    } else {
      debugPrint('[TASKS] Delete cancelled for task: ${task.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[TASKS] Building TaskListView UI');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(
              child: Text('No tasks yet. Tap + to add.',
                  style: Theme.of(context).textTheme.titleMedium),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: _tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final completedCount =
                    task.subtasks.where((s) => s.completed).length;
                final hasDue = task.dueDate != null;
                final hasReminder = task.reminder != null;
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _editTask(task),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 16, top: 12, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: task.subtasks.isNotEmpty &&
                                    completedCount == task.subtasks.length,
                                tristate: false,
                                onChanged: task.subtasks.isEmpty
                                    ? null
                                    : (val) async {
                                        debugPrint(
                                            '[TASKS] Task status toggled (inline): ${task.id} -> $val');
                                        final updatedTask = Task(
                                          id: task.id,
                                          title: task.title,
                                          description: task.description,
                                          dueDate: task.dueDate,
                                          reminder: task.reminder,
                                          subtasks: task.subtasks
                                              .map((s) => SubTask(
                                                    id: s.id,
                                                    title: s.title,
                                                    completed: val ?? false,
                                                    reminder: s.reminder,
                                                    dueDate: s.dueDate,
                                                  ))
                                              .toList(),
                                        );
                                        await _taskService
                                            .updateTask(updatedTask);
                                        _loadTasks();
                                      },
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        decoration: completedCount ==
                                                    task.subtasks.length &&
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
                                onPressed: () => _deleteTask(task),
                              ),
                            ],
                          ),
                          if (task.description != null &&
                              task.description!.isNotEmpty)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Icon(
                                        //   Icons.check_box,
                                        //   size: 20,
                                        //   color: completedCount == task.subtasks.length && task.subtasks.isNotEmpty
                                        //       ? Colors.green[700]
                                        //       : (completedCount > 0 ? Colors.orange[700] : Colors.grey[400]),
                                        // ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Subtasks',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: completedCount ==
                                                        task.subtasks.length &&
                                                    task.subtasks.isNotEmpty
                                                ? Colors.green[50]
                                                : (completedCount > 0
                                                    ? Colors.orange[50]
                                                    : Colors.grey[100]),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.check,
                                                  size: 14,
                                                  color: completedCount ==
                                                              task.subtasks
                                                                  .length &&
                                                          task.subtasks
                                                              .isNotEmpty
                                                      ? Colors.green
                                                      : Colors.orange),
                                              const SizedBox(width: 2),
                                              Text(
                                                '$completedCount/${task.subtasks.length}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: completedCount ==
                                                              task.subtasks
                                                                  .length &&
                                                          task.subtasks
                                                              .isNotEmpty
                                                      ? Colors.green[700]
                                                      : (completedCount > 0
                                                          ? Colors.orange[700]
                                                          : Colors.grey[700]),
                                                  fontSize: 14,
                                                ),
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
                                          : completedCount /
                                              task.subtasks.length,
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
                                              onChanged: (val) async {
                                                debugPrint(
                                                    '[TASKS] Subtask completed toggled (inline): ${sub.id} -> $val');
                                                final updatedSub = SubTask(
                                                  id: sub.id,
                                                  title: sub.title,
                                                  completed: val ?? false,
                                                  reminder: sub.reminder,
                                                  dueDate: sub.dueDate,
                                                );
                                                final updatedTask = Task(
                                                  id: task.id,
                                                  title: task.title,
                                                  description: task.description,
                                                  dueDate: task.dueDate,
                                                  reminder: task.reminder,
                                                  subtasks: task.subtasks
                                                      .map((s) => s.id == sub.id
                                                          ? updatedSub
                                                          : s)
                                                      .toList(),
                                                );
                                                await _taskService
                                                    .updateTask(updatedTask);
                                                _loadTasks();
                                              },
                                            ),
                                            Expanded(
                                              child: Text(
                                                sub.title,
                                                style: TextStyle(
                                                  decoration: sub.completed
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                                  color: sub.completed
                                                      ? Colors.grey
                                                      : null,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (sub.dueDate != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_today,
                                                        size: 16,
                                                        color: Colors.blue),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '${sub.dueDate!.toLocal().toString().split(' ')[0]}',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.blue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (sub.reminder != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.alarm,
                                                        size: 16,
                                                        color: Colors.orange),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '${sub.reminder!.toLocal().toString().split(' ')[0]}',
                                                      style: const TextStyle(
                                                          fontSize: 12,
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
                                        style: const TextStyle(
                                            color: Colors.blue)),
                                  ],
                                ),
                              if (hasDue && hasReminder)
                                const SizedBox(width: 12),
                              if (hasReminder)
                                Row(
                                  children: [
                                    const Icon(Icons.alarm,
                                        size: 18, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                        'Remind: ${task.reminder!.toLocal().toString().split(' ')[0]}',
                                        style: const TextStyle(
                                            color: Colors.orange)),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
