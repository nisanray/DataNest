import 'package:hive/hive.dart';

part 'section_model.g.dart';

@HiveType(typeId: 0)
class Section extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String? icon;
  @HiveField(3)
  String? color;
  @HiveField(4)
  String? description;
  @HiveField(5)
  int? order;
  @HiveField(6)
  bool synced;
  @HiveField(7)
  Map<String, dynamic>? settings;

  Section({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.description,
    this.order,
    this.synced = false,
    this.settings,
  });
}
