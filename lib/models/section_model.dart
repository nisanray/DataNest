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
  @HiveField(8)
  String? userId;

  Section({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.description,
    this.order,
    this.synced = false,
    this.settings,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'description': description,
        'order': order,
        'synced': synced,
        'settings': settings,
        'userId': userId,
      };

  static Section fromJson(Map<String, dynamic> json) => Section(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        color: json['color'],
        description: json['description'],
        order: json['order'],
        synced: json['synced'] ?? false,
        settings: json['settings'] != null
            ? Map<String, dynamic>.from(json['settings'])
            : null,
        userId: json['userId'],
      );
}
