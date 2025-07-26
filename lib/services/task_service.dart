import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final String userId;
  late final Box<Task> _taskBox;
  final _firestore = FirebaseFirestore.instance;

  TaskService({required this.userId}) {
    _taskBox = Hive.box<Task>('tasks');
  }

  // CRUD for local tasks
  List<Task> getAllTasks() => _taskBox.values.toList();

  Future<void> addTask(Task task) async {
    // Mark as unsynced for offline-first
    task.synced = false;
    await _taskBox.put(task.id, task);
    await trySyncTaskToCloud(task);
  }

  Future<void> updateTask(Task task) async {
    // Mark as unsynced for offline-first
    task.synced = false;
    await _taskBox.put(task.id, task);
    await trySyncTaskToCloud(task);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  // Firestore sync
  Future<void> syncTaskToCloud(Task task) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .set({
      'title': task.title,
      'description': task.description,
      'reminder': task.reminder?.toIso8601String(),
      'dueDate': task.dueDate?.toIso8601String(),
      'subtasks': task.subtasks
          .map((s) => {
                'id': s.id,
                'title': s.title,
                'completed': s.completed,
                'reminder': s.reminder?.toIso8601String(),
                'dueDate': s.dueDate?.toIso8601String(),
              })
          .toList(),
    });
    // Mark as synced after successful upload
    task.synced = true;
    await _taskBox.put(task.id, task);
  }

  // Try to sync, but don't throw if offline
  Future<void> trySyncTaskToCloud(Task task) async {
    try {
      await syncTaskToCloud(task);
    } catch (e) {
      // Remain unsynced, will retry later
    }
  }

  // Sync all unsynced tasks (call on app start or connectivity change)
  Future<void> syncAllUnsyncedTasks() async {
    final unsynced = _taskBox.values.where((t) => t.synced == false).toList();
    for (final task in unsynced) {
      await trySyncTaskToCloud(task);
    }
  }

  Future<void> syncFromCloud() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final task = Task(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'],
        reminder:
            data['reminder'] != null ? DateTime.parse(data['reminder']) : null,
        dueDate:
            data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
        subtasks: (data['subtasks'] as List?)
                ?.map((s) => SubTask(
                      id: s['id'],
                      title: s['title'],
                      completed: s['completed'] ?? false,
                      reminder: s['reminder'] != null
                          ? DateTime.parse(s['reminder'])
                          : null,
                      dueDate: s['dueDate'] != null
                          ? DateTime.parse(s['dueDate'])
                          : null,
                      synced: true,
                    ))
                .toList() ??
            [],
        synced: true,
      );
      await _taskBox.put(task.id, task);
    }
  }
}
