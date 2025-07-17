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
  @HiveField(6)
  String? userId;

  Record({
    required this.id,
    required this.sectionId,
    required this.data,
    this.attachments,
    this.relations,
    this.synced = false,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sectionId': sectionId,
        'data': data,
        'attachments': attachments,
        'relations': relations,
        'synced': synced,
        'userId': userId,
      };

  static Record fromJson(Map<String, dynamic> json) => Record(
        id: json['id'],
        sectionId: json['sectionId'],
        data:
            json['data'] != null ? Map<String, dynamic>.from(json['data']) : {},
        attachments: json['attachments'] != null
            ? List<String>.from(json['attachments'])
            : null,
        relations: json['relations'] != null
            ? Map<String, dynamic>.from(json['relations'])
            : null,
        synced: json['synced'] ?? false,
        userId: json['userId'],
      );
}
