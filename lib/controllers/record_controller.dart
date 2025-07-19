import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/record_model.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sync_service.dart';
import 'package:flutter/foundation.dart';

class RecordController extends GetxController {
  final String sectionId;
  final String userId;
  late Box<Record> recordBox;

  RecordController({required this.sectionId, required this.userId});

  @override
  void onInit() {
    super.onInit();
    recordBox = Hive.box<Record>('records');
  }

  // Getter to filter records for this section and user
  List<Record> get filteredRecords => recordBox.values
      .where((r) => r.sectionId == sectionId && r.userId == userId)
      .toList();

  // Expose listenable for UI
  ValueListenable<Box<Record>> get listenable => recordBox.listenable();

  Future<void> uploadRecord(Record record) async {
    await FirebaseFirestore.instance
        .collection('records')
        .doc(record.id)
        .set(record.toJson());
  }

  Future<void> deleteRecordFromCloud(String id) async {
    await FirebaseFirestore.instance.collection('records').doc(id).delete();
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
