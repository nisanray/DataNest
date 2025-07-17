import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/record_model.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sync_service.dart';

class RecordController extends GetxController {
  final String sectionId;
  final String userId;
  late Box<Record> recordBox;
  var records = <Record>[].obs;

  RecordController({required this.sectionId, required this.userId});

  @override
  void onInit() {
    super.onInit();
    recordBox = Hive.box<Record>('records');
    loadRecords();
  }

  void loadRecords() {
    records.value = recordBox.values
        .where((r) => r.sectionId == sectionId && r.userId == userId)
        .toList();
  }

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
    loadRecords();
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
    records.add(record);
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
    int idx = records.indexWhere((r) => r.id == updated.id);
    if (idx != -1) records[idx] = userRecord;
    await uploadRecord(userRecord);
    await SyncService(userId: userId).onDataChanged();
  }

  void deleteRecord(String id) async {
    await recordBox.delete(id);
    records.removeWhere((r) => r.id == id);
    await deleteRecordFromCloud(id);
    await SyncService(userId: userId).onDataChanged();
  }

  Future<void> syncRecords() async {
    await fetchRecordsFromCloud();
  }

  String exportRecordsAsJson() {
    final recordList = records.map((r) => r.toJson()).toList();
    return recordList.toString();
  }

  String exportRecordsAsCsv() {
    if (records.isEmpty) return '';
    final headers = records.first.toJson().keys.toList();
    final rows = records.map((r) => headers.map((h) => r.toJson()[h]).toList());
    final csv = StringBuffer();
    csv.writeln(headers.join(','));
    for (final row in rows) {
      csv.writeln(row.map((v) => '"${v ?? ''}"').join(','));
    }
    return csv.toString();
  }

  // TODO: Implement edit, delete, and sync logic
}
