import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/section_model.dart';
import '../models/field_model.dart';
import '../models/record_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class SyncService {
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
    debugPrint('[SYNC] syncFromFirebase completed for user: $userId');
  }

  /// Upload all unsynced data from Hive to Firebase
  Future<void> syncToFirebase() async {
    await _syncUnsyncedSectionsToFirebase();
    await _syncUnsyncedFieldsToFirebase();
    await _syncUnsyncedRecordsToFirebase();
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
      final local = box.get(remote.id);
      if (local == null) {
        debugPrint('[SYNC] Adding new section to Hive: ${remote.id}');
        await box.put(remote.id, remote);
      } else if (local.synced == false) {
        debugPrint('[SYNC] Overwriting unsynced section in Hive: ${remote.id}');
        await box.put(remote.id, remote);
      } else {
        debugPrint(
            '[SYNC] Skipping section (already synced in Hive): ${remote.id}');
      }
    }
  }

  Future<void> _syncUnsyncedSectionsToFirebase() async {
    final box = await Hive.openBox<Section>('sections');
    final unsynced = box.values
        .where((s) => s.userId == userId && s.synced == false)
        .toList();
    for (final section in unsynced) {
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(section.id)
          .set(section.toJson());
      final updated = Section(
        id: section.id,
        name: section.name,
        icon: section.icon,
        color: section.color,
        description: section.description,
        order: section.order,
        synced: true,
        settings: section.settings,
        userId: section.userId,
      );
      await box.put(section.id, updated);
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
      final local = box.get(remote.id);
      if (local == null) {
        debugPrint('[SYNC] Adding new field to Hive: ${remote.id}');
        await box.put(remote.id, remote);
      } else if (local.synced == false) {
        debugPrint('[SYNC] Overwriting unsynced field in Hive: ${remote.id}');
        await box.put(remote.id, remote);
      } else {
        debugPrint(
            '[SYNC] Skipping field (already synced in Hive): ${remote.id}');
      }
    }
  }

  Future<void> _syncUnsyncedFieldsToFirebase() async {
    final box = await Hive.openBox<Field>('fields');
    final unsynced = box.values
        .where((f) => f.userId == userId && f.synced == false)
        .toList();
    for (final field in unsynced) {
      await FirebaseFirestore.instance
          .collection('fields')
          .doc(field.id)
          .set(field.toJson());
      final updated = Field(
        id: field.id,
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
      await box.put(field.id, updated);
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
      final local = box.get(remote.id);
      if (local == null) {
        debugPrint('[SYNC] Adding new record to Hive: ${remote.id}');
        await box.put(remote.id, remote);
      } else if (local.synced == false) {
        debugPrint('[SYNC] Overwriting unsynced record in Hive: ${remote.id}');
        await box.put(remote.id, remote);
      } else {
        debugPrint(
            '[SYNC] Skipping record (already synced in Hive): ${remote.id}');
      }
    }
  }

  Future<void> _syncUnsyncedRecordsToFirebase() async {
    final box = await Hive.openBox<Record>('records');
    final unsynced = box.values
        .where((r) => r.userId == userId && r.synced == false)
        .toList();
    for (final record in unsynced) {
      await FirebaseFirestore.instance
          .collection('records')
          .doc(record.id)
          .set(record.toJson());
      final updated = Record(
        id: record.id,
        sectionId: record.sectionId,
        data: record.data,
        attachments: record.attachments,
        relations: record.relations,
        synced: true,
        userId: record.userId,
      );
      await box.put(record.id, updated);
    }
  }
}
