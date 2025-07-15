import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/field_model.dart';
import 'package:uuid/uuid.dart';

class FieldController extends GetxController {
  final String sectionId;
  late Box<Field> fieldBox;
  var fields = <Field>[].obs;

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

  FieldController({required this.sectionId});

  @override
  void onInit() {
    super.onInit();
    fieldBox = Hive.box<Field>('fields');
    loadFields();
  }

  void loadFields() {
    fields.value =
        fieldBox.values.where((f) => f.sectionId == sectionId).toList();
  }

  void addField(Field field) async {
    await fieldBox.put(field.id, field);
    fields.add(field);
  }

  // TODO: Implement edit, delete, and reorder logic
}
