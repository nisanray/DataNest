import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/section_model.dart';
import '../models/field_model.dart';
import '../models/record_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class SyncService {
  /// Background sync: upload all unsynced items from Hive to Firebase
  Future<void> backgroundSync() async {
    debugPrint('[SYNC] backgroundSync started for user: $userId');
    await syncToFirebase();
    debugPrint('[SYNC] backgroundSync completed for user: $userId');
  }

  final String userId;
  SyncService({required this.userId});

  Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Download all user data from Firebase and update Hive (no duplicates)
  Future<void> syncFromFirebase() async {
    debugPrint('[SYNC] syncFromFirebase called for user: $userId');
    await _syncSectionsFromFirebase();
    await _syncFieldsFromFirebase();
    await _syncRecordsFromFirebase();
    await _syncTasksFromFirebase();
    debugPrint('[SYNC] syncFromFirebase completed for user: $userId');
  }

  /// Upload all unsynced data from Hive to Firebase
  Future<void> syncToFirebase() async {
    await _syncUnsyncedSectionsToFirebase();
    await _syncUnsyncedFieldsToFirebase();
    await _syncUnsyncedRecordsToFirebase();
    await _syncUnsyncedTasksToFirebase();
  }

  Future<void> onUserSignUp() async {
    debugPrint('[SYNC] onUserSignUp called for user: $userId');
    await clearAllHiveBoxes();
    debugPrint('[SYNC] onUserSignUp completed for user: $userId');
  }

  Future<void> onAppLaunchLoggedIn() async {
    debugPrint('[SYNC] onAppLaunchLoggedIn called for user: $userId');
    debugPrint('[SYNC] onAppLaunchLoggedIn completed for user: $userId');
  }

  Future<void> clearAllHiveBoxes() async {
    await (await Hive.openBox<Section>('sections')).clear();
    await (await Hive.openBox<Field>('fields')).clear();
    await (await Hive.openBox<Record>('records')).clear();
    await (await Hive.openBox<Task>('tasks')).clear();
  }

  // --- Task Sync ---
  Future<void> _syncTasksFromFirebase() async {
    final box = await Hive.openBox<Task>('tasks');
    debugPrint('[SYNC] Fetching tasks from Firebase for user: $userId');
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();
    debugPrint('[SYNC] Fetched \\${snapshot.docs.length} tasks from Firebase.');
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final subtasks = (data['subtasks'] as List?)
              ?.map((s) => SubTask(
                    id: s['id'],
                    title: s['title'],
                    completed: s['completed'] ?? false,
                    reminder: s['reminder'] != null
                        ? DateTime.tryParse(s['reminder'])
                        : null,
                    dueDate: s['dueDate'] != null
                        ? DateTime.tryParse(s['dueDate'])
                        : null,
                    synced: true,
                  ))
              .toList() ??
          [];
      final remote = Task(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'],
        reminder: data['reminder'] != null
            ? DateTime.tryParse(data['reminder'])
            : null,
        dueDate:
            data['dueDate'] != null ? DateTime.tryParse(data['dueDate']) : null,
        subtasks: subtasks,
        synced: true,
      );
      await box.put(remote.id, remote);
      debugPrint('[SYNC] Overwrote/added task in Hive: \\${remote.id}');
    }
  }

  Future<void> _syncUnsyncedTasksToFirebase() async {
    final box = await Hive.openBox<Task>('tasks');
    final unsynced = box.values.where((t) => t.synced == false).toList();
    for (final task in unsynced) {
      String docId = task.id;
      bool needsDocId = docId.startsWith('local_');
      DocumentReference ref = needsDocId
          ? FirebaseFirestore.instance.collection('tasks').doc()
          : FirebaseFirestore.instance.collection('tasks').doc(docId);
      await ref.set({
        'userId': userId,
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
      String newDocId = ref.id;
      // Mark all subtasks as synced
      final updatedSubtasks = task.subtasks
          .map((s) => SubTask(
                id: s.id,
                title: s.title,
                completed: s.completed,
                reminder: s.reminder,
                dueDate: s.dueDate,
                synced: true,
              ))
          .toList();
      final updated = Task(
        id: newDocId,
        title: task.title,
        description: task.description,
        reminder: task.reminder,
        dueDate: task.dueDate,
        subtasks: updatedSubtasks,
        synced: true,
      );
      if (needsDocId) await box.delete(task.id);
      await box.put(newDocId, updated);
      debugPrint('[SYNC] Synced task to Firebase: $newDocId');
    }
  }

  /// Call this after login
  Future<void> onUserLogin() async {
    debugPrint('[SYNC] onUserLogin called for user: $userId');
    await syncFromFirebase();
    await syncToFirebase();
    debugPrint('[SYNC] onUserLogin completed for user: $userId');
  }

  /// Call this after add/edit/delete
  Future<void> onDataChanged() async {
    if (await isOnline) {
      await syncToFirebase();
    }
    // else: will sync when online
  }

  /// Call this on connectivity change
  Future<void> onConnectivityRestored() async {
    await syncToFirebase();
  }

  // --- Section Sync ---
  Future<void> _syncSectionsFromFirebase() async {
    final box = await Hive.openBox<Section>('sections');
    debugPrint('[SYNC] Fetching sections from Firebase for user: $userId');
    final snapshot = await FirebaseFirestore.instance
        .collection('sections')
        .where('userId', isEqualTo: userId)
        .get();
    debugPrint(
        '[SYNC] Fetched ${snapshot.docs.length} sections from Firebase.');
    for (final doc in snapshot.docs) {
      final remote = Section.fromJson(doc.data());
      await box.put(remote.id, remote);
      debugPrint('[SYNC] Overwrote/added section in Hive: ${remote.id}');
    }
  }

  Future<void> _syncUnsyncedSectionsToFirebase() async {
    final box = await Hive.openBox<Section>('sections');
    final unsynced = box.values
        .where((s) => s.userId == userId && s.synced == false)
        .toList();
    for (final section in unsynced) {
      String docId = section.id;
      bool needsDocId = docId.startsWith('local_');
      DocumentReference ref = needsDocId
          ? FirebaseFirestore.instance.collection('sections').doc()
          : FirebaseFirestore.instance.collection('sections').doc(docId);
      await ref.set(section.toJson());
      String newDocId = ref.id;
      final updated = Section(
        id: newDocId,
        name: section.name,
        icon: section.icon,
        color: section.color,
        description: section.description,
        order: section.order,
        synced: true,
        settings: section.settings,
        userId: section.userId,
      );
      if (needsDocId) await box.delete(section.id);
      await box.put(newDocId, updated);
    }
  }

  // --- Field Sync ---
  Future<void> _syncFieldsFromFirebase() async {
    final box = await Hive.openBox<Field>('fields');
    debugPrint('[SYNC] Fetching fields from Firebase for user: $userId');
    final snapshot = await FirebaseFirestore.instance
        .collection('fields')
        .where('userId', isEqualTo: userId)
        .get();
    debugPrint('[SYNC] Fetched ${snapshot.docs.length} fields from Firebase.');
    for (final doc in snapshot.docs) {
      final remote = Field.fromJson(doc.data());
      await box.put(remote.id, remote);
      debugPrint('[SYNC] Overwrote/added field in Hive: ${remote.id}');
    }
  }

  Future<void> _syncUnsyncedFieldsToFirebase() async {
    final box = await Hive.openBox<Field>('fields');
    final unsynced = box.values
        .where((f) => f.userId == userId && f.synced == false)
        .toList();
    for (final field in unsynced) {
      String docId = field.id;
      bool needsDocId = docId.startsWith('local_');
      DocumentReference ref = needsDocId
          ? FirebaseFirestore.instance.collection('fields').doc()
          : FirebaseFirestore.instance.collection('fields').doc(docId);
      await ref.set(field.toJson());
      String newDocId = ref.id;
      final updated = Field(
        id: newDocId,
        sectionId: field.sectionId,
        name: field.name,
        type: field.type,
        requiredField: field.requiredField,
        defaultValue: field.defaultValue,
        hint: field.hint,
        unique: field.unique,
        allowedOptions: field.allowedOptions,
        validation: field.validation,
        attachmentRules: field.attachmentRules,
        relations: field.relations,
        formula: field.formula,
        conditionalVisibility: field.conditionalVisibility,
        order: field.order,
        synced: true,
        userId: field.userId,
      );
      if (needsDocId) await box.delete(field.id);
      await box.put(newDocId, updated);
    }
  }

  // --- Record Sync ---
  Future<void> _syncRecordsFromFirebase() async {
    final box = await Hive.openBox<Record>('records');
    debugPrint('[SYNC] Fetching records from Firebase for user: $userId');
    final snapshot = await FirebaseFirestore.instance
        .collection('records')
        .where('userId', isEqualTo: userId)
        .get();
    debugPrint('[SYNC] Fetched ${snapshot.docs.length} records from Firebase.');
    for (final doc in snapshot.docs) {
      final remote = Record.fromJson(doc.data());
      await box.put(remote.id, remote);
      debugPrint('[SYNC] Overwrote/added record in Hive: ${remote.id}');
    }
  }

  Future<void> _syncUnsyncedRecordsToFirebase() async {
    final box = await Hive.openBox<Record>('records');
    final unsynced = box.values
        .where((r) => r.userId == userId && r.synced == false)
        .toList();
    for (final record in unsynced) {
      String docId = record.id;
      bool needsDocId = docId.startsWith('local_');
      DocumentReference ref = needsDocId
          ? FirebaseFirestore.instance.collection('records').doc()
          : FirebaseFirestore.instance.collection('records').doc(docId);
      await ref.set(record.toJson());
      String newDocId = ref.id;
      final updated = Record(
        id: newDocId,
        sectionId: record.sectionId,
        data: record.data,
        attachments: record.attachments,
        relations: record.relations,
        synced: true,
        userId: record.userId,
      );
      if (needsDocId) await box.delete(record.id);
      await box.put(newDocId, updated);
    }
  }
}
