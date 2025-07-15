import 'package:hive/hive.dart';

part 'record_model.g.dart';

@HiveType(typeId: 2)
class Record extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String sectionId;
  @HiveField(2)
  Map<String, dynamic> data;
  @HiveField(3)
  List<String>? attachments;
  @HiveField(4)
  Map<String, dynamic>? relations;
  @HiveField(5)
  bool synced;

  Record({
    required this.id,
    required this.sectionId,
    required this.data,
    this.attachments,
    this.relations,
    this.synced = false,
  });
}
