import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/record_model.dart';
import '../models/field_model.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sync_service.dart';
import 'package:flutter/foundation.dart';

class RecordController extends GetxController {
  /// Returns the ordered, visible fields for a section based on settings and allFields.
  List<Field> getVisibleFields({
    required Map<String, dynamic> settings,
    required List<Field> allFields,
  }) {
    final List<String> fieldOrder = List<String>.from(
        settings['fieldOrder'] ?? allFields.map((f) => f.name));
    final List<String> visibleFields = List<String>.from(
        settings['visibleFields'] ?? allFields.map((f) => f.name));
    final Map<String, dynamic> fieldDisplay =
        Map<String, dynamic>.from(settings['fieldDisplay'] ?? {});
    // Only include fields that are in visibleFields and not hidden by display
    final filtered = fieldOrder
        .where((name) =>
            visibleFields.contains(name) &&
            (fieldDisplay[name] ?? 'Normal') != 'Hidden')
        .map((name) => allFields.firstWhereOrNull((f) => f.name == name))
        .whereType<Field>()
        .toList();
    return filtered;
  }

  // Business/UI helpers moved from RecordsTab
  List<Record> filterAndSortRecords(
      List<Record> records,
      String? sortBy,
      String sortOrder,
      String searchQuery,
      List<String> visibleFields,
      Map<String, dynamic> fieldDisplay) {
    // Filter by search query
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      records = records.where((record) {
        return record.data.values
            .any((value) => value.toString().toLowerCase().contains(query));
      }).toList();
    }
    // Sort records
    if (sortBy != null) {
      records.sort((a, b) {
        final aVal = a.data[sortBy];
        final bVal = b.data[sortBy];
        if (aVal == null && bVal == null) return 0;
        if (aVal == null) return sortOrder == 'asc' ? -1 : 1;
        if (bVal == null) return sortOrder == 'asc' ? 1 : -1;
        final comparison = aVal.toString().compareTo(bVal.toString());
        return sortOrder == 'asc' ? comparison : -comparison;
      });
    }
    return records;
  }

  String? getTitleValue(Record record, List<String> visibleFields,
      Map<String, dynamic> fieldDisplay) {
    if (visibleFields.isNotEmpty) {
      final firstVisible = visibleFields.firstWhere(
        (f) =>
            visibleFields.contains(f) &&
            (fieldDisplay[f] ?? 'Normal') != 'Hidden',
        orElse: () => '',
      );
      if (firstVisible.isNotEmpty) {
        return record.data[firstVisible]?.toString();
      }
    }
    return null;
  }

  Widget fieldIcon(String type) {
    switch (type) {
      case 'date':
      case 'datetime':
        return const Icon(Icons.event, size: 18, color: Colors.blueGrey);
      case 'number':
      case 'currency':
        return const Icon(Icons.numbers, size: 18, color: Colors.teal);
      case 'checkbox':
      case 'switch':
      case 'toggle':
        return const Icon(Icons.check_box, size: 18, color: Colors.green);
      case 'dropdown':
      case 'multi_select':
      case 'radio':
        return const Icon(Icons.list, size: 18, color: Colors.deepPurple);
      case 'file':
        return const Icon(Icons.attach_file, size: 18, color: Colors.orange);
      case 'image':
        return const Icon(Icons.image, size: 18, color: Colors.pink);
      case 'color':
        return const Icon(Icons.color_lens, size: 18, color: Colors.amber);
      case 'rating':
        return const Icon(Icons.star, size: 18, color: Colors.amber);
      case 'password':
        return const Icon(Icons.lock, size: 18, color: Colors.grey);
      default:
        return const Icon(Icons.text_fields, size: 18, color: Colors.grey);
    }
  }

  String formatFieldValue(String type, dynamic value) {
    if (value == null) return '-';
    switch (type) {
      case 'checkbox':
      case 'switch':
      case 'toggle':
        return value == true ? 'Yes' : 'No';
      case 'multi_select':
        if (value is List) return value.join(', ');
        return value.toString();
      case 'color':
        return value.toString();
      case 'rating':
        return value.toString();
      case 'date':
      case 'datetime':
        return value.toString().replaceFirst('T', ' ').split('.').first;
      default:
        return value.toString();
    }
  }

  num tryEval(String expr) {
    try {
      expr = expr.replaceAll(' ', '');
      if (expr.contains('(')) {
        final paren = RegExp(r'\(([^()]+)\)');
        while (paren.hasMatch(expr)) {
          expr = expr.replaceAllMapped(
              paren, (m) => tryEval(m.group(1)!).toString());
        }
      }
      if (expr.contains('+')) {
        return expr.split('+').map(tryEval).reduce((a, b) => a + b);
      } else if (expr.contains('-')) {
        final parts = expr.split('-');
        return parts.map(tryEval).reduce((a, b) => a - b);
      } else if (expr.contains('*')) {
        return expr.split('*').map(tryEval).reduce((a, b) => a * b);
      } else if (expr.contains('/')) {
        return expr.split('/').map(tryEval).reduce((a, b) => a / b);
      } else {
        return num.parse(expr);
      }
    } catch (e) {
      throw Exception('Invalid formula');
    }
  }

  final String sectionId;
  final String userId;
  late Box<Record> recordBox;

  RecordController({required this.sectionId, required this.userId});

  @override
  void onInit() {
    super.onInit();
    recordBox = Hive.box<Record>('records');
    debugPrint(
        '[RECORD] RecordController initialized for section: $sectionId, user: $userId');
  }

  // Getter to filter records for this section and user
  List<Record> get filteredRecords {
    final records = recordBox.values
        .where((r) => r.sectionId == sectionId && r.userId == userId)
        .toList();
    debugPrint(
        '[RECORD] Loaded ${records.length} records from Hive for section: $sectionId, user: $userId');
    return records;
  }

  // Expose listenable for UI
  ValueListenable<Box<Record>> get listenable => recordBox.listenable();

  Future<void> uploadRecord(Record record) async {
    debugPrint('[RECORD] Uploading record to Firestore: ${record.id}');
    await FirebaseFirestore.instance
        .collection('records')
        .doc(record.id)
        .set(record.toJson());
    debugPrint('[RECORD] Uploaded record to Firestore: ${record.id}');
  }

  Future<void> deleteRecordFromCloud(String id) async {
    debugPrint('[RECORD] Deleting record from Firestore: $id');
    await FirebaseFirestore.instance.collection('records').doc(id).delete();
    debugPrint('[RECORD] Deleted record from Firestore: $id');
  }

  Future<void> fetchRecordsFromCloud() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('records')
        .where('userId', isEqualTo: userId)
        .get();
    final remoteRecords =
        snapshot.docs.map((doc) => Record.fromJson(doc.data())).toList();
    for (final record in remoteRecords) {
      await recordBox.put(record.id, record);
    }
  }

  void addRecord(Map data) async {
    final record = Record(
      id: const Uuid().v4(),
      sectionId: sectionId,
      data: data.cast<String, dynamic>(),
      synced: false,
      userId: userId,
    );
    await recordBox.put(record.id, record);
    await uploadRecord(record);
    await SyncService(userId: userId).onDataChanged();
  }

  void editRecord(Record updated) async {
    final userRecord = Record(
      id: updated.id,
      sectionId: updated.sectionId,
      data: updated.data,
      attachments: updated.attachments,
      relations: updated.relations,
      synced: updated.synced,
      userId: userId,
    );
    await recordBox.put(updated.id, userRecord);
    int idx = filteredRecords.indexWhere((r) => r.id == updated.id);
    if (idx != -1) filteredRecords[idx] = userRecord;
    await uploadRecord(userRecord);
    await SyncService(userId: userId).onDataChanged();
  }

  void deleteRecord(String id) async {
    await recordBox.delete(id);
    await deleteRecordFromCloud(id);
    await SyncService(userId: userId).onDataChanged();
  }

  Future<void> syncRecords() async {
    await fetchRecordsFromCloud();
  }

  Future<void> syncUnsyncedRecords() async {
    final unsynced = recordBox.values
        .where((r) =>
            r.sectionId == sectionId && r.userId == userId && r.synced == false)
        .toList();
    debugPrint(
        '[RECORD] Syncing ${unsynced.length} unsynced records to Firestore for section: $sectionId, user: $userId');
    for (final record in unsynced) {
      await FirebaseFirestore.instance
          .collection('records')
          .doc(record.id)
          .set(record.toJson());
      // Mark as synced in Hive
      final updated = Record(
        id: record.id,
        sectionId: record.sectionId,
        data: record.data,
        attachments: record.attachments,
        relations: record.relations,
        synced: true,
        userId: record.userId,
      );
      await recordBox.put(record.id, updated);
      debugPrint(
          '[RECORD] Synced record to Firestore and updated in Hive: ${record.id}');
    }
  }

  String exportRecordsAsJson() {
    final recordList = filteredRecords.map((r) => r.toJson()).toList();
    return recordList.toString();
  }

  String exportRecordsAsCsv() {
    if (filteredRecords.isEmpty) return '';
    final headers = filteredRecords.first.toJson().keys.toList();
    final rows =
        filteredRecords.map((r) => headers.map((h) => r.toJson()[h]).toList());
    final csv = StringBuffer();
    csv.writeln(headers.join(','));
    for (final row in rows) {
      csv.writeln(row.map((v) => '"${v ?? ''}"').join(','));
    }
    return csv.toString();
  }

  // TODO: Implement edit, delete, and sync logic
}
