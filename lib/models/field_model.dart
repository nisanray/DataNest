import 'package:hive/hive.dart';

part 'field_model.g.dart';

@HiveType(typeId: 1)
class Field extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String sectionId;
  @HiveField(2)
  String name;
  @HiveField(3)
  String type;
  @HiveField(4)
  bool requiredField;
  @HiveField(5)
  dynamic defaultValue;
  @HiveField(6)
  String? hint;
  @HiveField(7)
  bool unique;
  @HiveField(8)
  List<dynamic>? allowedOptions;
  @HiveField(9)
  Map<String, dynamic>? validation;
  @HiveField(10)
  Map<String, dynamic>? attachmentRules;
  @HiveField(11)
  Map<String, dynamic>? relations;
  @HiveField(12)
  String? formula;
  @HiveField(13)
  String? conditionalVisibility;
  @HiveField(14)
  int? order;
  @HiveField(15)
  bool synced;
  @HiveField(16)
  String? userId;

  Field({
    required this.id,
    required this.sectionId,
    required this.name,
    required this.type,
    this.requiredField = false,
    this.defaultValue,
    this.hint,
    this.unique = false,
    this.allowedOptions,
    this.validation,
    this.attachmentRules,
    this.relations,
    this.formula,
    this.conditionalVisibility,
    this.order,
    this.synced = false,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sectionId': sectionId,
        'name': name,
        'type': type,
        'requiredField': requiredField,
        'defaultValue': defaultValue,
        'hint': hint,
        'unique': unique,
        'allowedOptions': allowedOptions,
        'validation': validation,
        'attachmentRules': attachmentRules,
        'relations': relations,
        'formula': formula,
        'conditionalVisibility': conditionalVisibility,
        'order': order,
        'synced': synced,
        'userId': userId,
      };

  static Field fromJson(Map<String, dynamic> json) => Field(
        id: json['id'],
        sectionId: json['sectionId'],
        name: json['name'],
        type: json['type'],
        requiredField: json['requiredField'] ?? false,
        defaultValue: json['defaultValue'],
        hint: json['hint'],
        unique: json['unique'] ?? false,
        allowedOptions: json['allowedOptions'] != null
            ? List<dynamic>.from(json['allowedOptions'])
            : null,
        validation: json['validation'] != null
            ? Map<String, dynamic>.from(json['validation'])
            : null,
        attachmentRules: json['attachmentRules'] != null
            ? Map<String, dynamic>.from(json['attachmentRules'])
            : null,
        relations: json['relations'] != null
            ? Map<String, dynamic>.from(json['relations'])
            : null,
        formula: json['formula'],
        conditionalVisibility: json['conditionalVisibility'],
        order: json['order'],
        synced: json['synced'] ?? false,
        userId: json['userId'],
      );
}
