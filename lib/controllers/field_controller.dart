import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/field_model.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sync_service.dart';
import 'package:flutter/foundation.dart';

class FieldController extends GetxController {
  final String sectionId;
  final String userId;
  late Box<Field> fieldBox;

  // Supported field types
  static const List<Map<String, String>> fieldTypes = [
    {'label': 'Text', 'value': 'text'},
    {'label': 'Number', 'value': 'number'},
    {'label': 'Date', 'value': 'date'},
    {'label': 'Time', 'value': 'time'},
    {'label': 'DateTime', 'value': 'datetime'},
    {'label': 'Checkbox', 'value': 'checkbox'},
    {'label': 'Dropdown', 'value': 'dropdown'},
    {'label': 'Multi-Select', 'value': 'multi_select'},
    {'label': 'Radio', 'value': 'radio'},
    {'label': 'File', 'value': 'file'},
    {'label': 'Image', 'value': 'image'},
    {'label': 'Relation', 'value': 'relation'},
    {'label': 'Computed', 'value': 'computed'},
    {'label': 'Switch', 'value': 'switch'},
    {'label': 'Toggle', 'value': 'toggle'},
    {'label': 'Attachment', 'value': 'attachment'},
    {'label': 'Signature', 'value': 'signature'},
    {'label': 'Barcode', 'value': 'barcode'},
    {'label': 'Location', 'value': 'location'},
    {'label': 'Color', 'value': 'color'},
    {'label': 'Currency', 'value': 'currency'},
    {'label': 'Rating', 'value': 'rating'},
    {'label': 'Password', 'value': 'password'},
    {'label': 'JSON', 'value': 'json'},
    {'label': 'Custom Code', 'value': 'custom_code'},
  ];

  FieldController({required this.sectionId, required this.userId});

  @override
  void onInit() {
    super.onInit();
    fieldBox = Hive.box<Field>('fields');
  }

  // Getter to filter fields for this section and user
  List<Field> get filteredFields => fieldBox.values
      .where((f) => f.sectionId == sectionId && f.userId == userId)
      .toList();

  // Expose listenable for UI
  ValueListenable<Box<Field>> get listenable => fieldBox.listenable();

  Future<void> uploadField(Field field) async {
    await FirebaseFirestore.instance
        .collection('fields')
        .doc(field.id)
        .set(field.toJson());
  }

  Future<void> deleteFieldFromCloud(String id) async {
    await FirebaseFirestore.instance.collection('fields').doc(id).delete();
  }

  Future<void> fetchFieldsFromCloud() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('fields')
        .where('userId', isEqualTo: userId)
        .get();
    final remoteFields =
        snapshot.docs.map((doc) => Field.fromJson(doc.data())).toList();
    for (final field in remoteFields) {
      await fieldBox.put(field.id, field);
    }
  }

  void addField(Field field) async {
    final userField = Field(
      id: field.id,
      sectionId: field.sectionId,
      name: field.name,
      type: field.type,
      requiredField: field.requiredField,
      defaultValue: field.defaultValue,
      hint: field.hint,
      unique: field.unique,
      allowedOptions: field.allowedOptions,
      validation: field.validation,
      attachmentRules: field.attachmentRules,
      relations: field.relations,
      formula: field.formula,
      conditionalVisibility: field.conditionalVisibility,
      order: field.order,
      synced: field.synced,
      userId: userId,
    );
    await fieldBox.put(userField.id, userField);
    await uploadField(userField);
    await SyncService(userId: userId).onDataChanged();
  }

  void editField(Field updated) async {
    final userField = Field(
      id: updated.id,
      sectionId: updated.sectionId,
      name: updated.name,
      type: updated.type,
      requiredField: updated.requiredField,
      defaultValue: updated.defaultValue,
      hint: updated.hint,
      unique: updated.unique,
      allowedOptions: updated.allowedOptions,
      validation: updated.validation,
      attachmentRules: updated.attachmentRules,
      relations: updated.relations,
      formula: updated.formula,
      conditionalVisibility: updated.conditionalVisibility,
      order: updated.order,
      synced: updated.synced,
      userId: userId,
    );
    await fieldBox.put(updated.id, userField);
    await uploadField(userField);
    await SyncService(userId: userId).onDataChanged();
  }

  void deleteField(String id) async {
    await fieldBox.delete(id);
    await deleteFieldFromCloud(id);
    await SyncService(userId: userId).onDataChanged();
  }

  Future<void> syncFields() async {
    await fetchFieldsFromCloud();
  }

  // TODO: Implement reorder logic
}
