import 'package:hive/hive.dart';
part 'task_model.g.dart';

@HiveType(typeId: 4)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime? reminder;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  List<SubTask> subtasks;

  @HiveField(6)
  bool synced;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.reminder,
    this.dueDate,
    this.subtasks = const [],
    this.synced = false,
  });
}

@HiveType(typeId: 5)
class SubTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  DateTime? reminder;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  bool synced;

  SubTask({
    required this.id,
    required this.title,
    this.completed = false,
    this.reminder,
    this.dueDate,
    this.synced = false,
  });
}
