import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/record_model.dart';
import 'package:uuid/uuid.dart';

class RecordController extends GetxController {
  final String sectionId;
  late Box<Record> recordBox;
  var records = <Record>[].obs;

  RecordController({required this.sectionId});

  @override
  void onInit() {
    super.onInit();
    recordBox = Hive.box<Record>('records');
    loadRecords();
  }

  void loadRecords() {
    records.value =
        recordBox.values.where((r) => r.sectionId == sectionId).toList();
  }

  void addRecord(Map data) async {
    final record = Record(
      id: const Uuid().v4(),
      sectionId: sectionId,
      data: data.cast<String, dynamic>(),
      synced: false,
    );
    await recordBox.put(record.id, record);
    records.add(record);
  }

  // TODO: Implement edit, delete, and sync logic
}
