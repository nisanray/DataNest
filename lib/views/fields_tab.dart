import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/section_model.dart';
import '../models/field_model.dart';
import '../controllers/field_controller.dart';

class FieldsTab extends StatelessWidget {
  final Section section;
  const FieldsTab({Key? key, required this.section}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FieldController fieldController =
        Get.put(FieldController(sectionId: section.id), tag: section.id);
    return Stack(
      children: [
        Obx(() {
          final fields = fieldController.fields;
          if (fields.isEmpty) {
            return const Center(
                child: Text('No fields yet. Tap + to add one.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: fields.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final field = fields[index];
              return Card(
                child: ListTile(
                  title: Text(field.name),
                  subtitle: Text('Type: ${field.type}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (field.requiredField)
                        const Icon(Icons.star, color: Colors.red),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteField(
                            context, fieldController, field),
                      ),
                    ],
                  ),
                  onTap: () => _showAddFieldDialog(context, fieldController,
                      editField: field),
                ),
              );
            },
          );
        }),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showAddFieldDialog(context, fieldController),
            child: const Icon(Icons.add),
            tooltip: 'Add Field',
          ),
        ),
      ],
    );
  }

  void _showAddFieldDialog(BuildContext context, FieldController controller,
      {Field? editField}) {
    final TextEditingController nameController =
        TextEditingController(text: editField?.name ?? '');
    String selectedType =
        editField?.type ?? FieldController.fieldTypes.first['value']!;
    bool requiredField = editField?.requiredField ?? false;
    bool unique = editField?.unique ?? false;
    final TextEditingController defaultValueController =
        TextEditingController(text: editField?.defaultValue?.toString() ?? '');
    final TextEditingController hintController =
        TextEditingController(text: editField?.hint ?? '');
    final TextEditingController allowedOptionsController =
        TextEditingController(
            text: (editField?.allowedOptions?.join(', ') ?? ''));
    final TextEditingController validationController =
        TextEditingController(text: editField?.validation?['regex'] ?? '');
    final TextEditingController attachmentTypesController =
        TextEditingController(
            text: (editField?.attachmentRules?['allowedTypes']?.join(', ') ??
                ''));
    final TextEditingController attachmentMaxSizeController =
        TextEditingController(
            text:
                editField?.attachmentRules?['maxFileSizeMB']?.toString() ?? '');
    final TextEditingController relationSectionController =
        TextEditingController(text: editField?.relations?['section'] ?? '');
    final TextEditingController formulaController =
        TextEditingController(text: editField?.formula ?? '');
    final TextEditingController conditionalVisibilityController =
        TextEditingController(text: editField?.conditionalVisibility ?? '');
    int order = editField?.order ?? controller.fields.length;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(editField == null ? 'Add Field' : 'Edit Field'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Field Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Field Type'),
                  items: FieldController.fieldTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Text(type['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: requiredField,
                  onChanged: (val) =>
                      setState(() => requiredField = val ?? false),
                  title: const Text('Required'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: unique,
                  onChanged: (val) => setState(() => unique = val ?? false),
                  title: const Text('Unique'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (selectedType == 'dropdown' ||
                    selectedType == 'multi_select' ||
                    selectedType == 'radio') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: allowedOptionsController,
                    decoration: const InputDecoration(
                      labelText: 'Allowed Options (comma separated)',
                    ),
                  ),
                ],
                if (selectedType == 'file' ||
                    selectedType == 'image' ||
                    selectedType == 'attachment') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: attachmentTypesController,
                    decoration: const InputDecoration(
                      labelText: 'Allowed File Types (comma separated)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: attachmentMaxSizeController,
                    decoration: const InputDecoration(
                      labelText: 'Max File Size (MB)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                if (selectedType == 'relation') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: relationSectionController,
                    decoration: const InputDecoration(
                      labelText: 'Target Section/Record',
                    ),
                  ),
                ],
                if (selectedType == 'computed') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: formulaController,
                    decoration: const InputDecoration(
                      labelText: 'Formula (Dart expression)',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: defaultValueController,
                  decoration: const InputDecoration(labelText: 'Default Value'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hintController,
                  decoration:
                      const InputDecoration(labelText: 'Hint/Help Text'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: validationController,
                  decoration:
                      const InputDecoration(labelText: 'Validation (Regex)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: conditionalVisibilityController,
                  decoration: const InputDecoration(
                      labelText: 'Conditional Visibility (logic)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Order:'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: order.toDouble(),
                        min: 0,
                        max: (controller.fields.length).toDouble(),
                        divisions: controller.fields.length > 0
                            ? controller.fields.length
                            : 1,
                        label: order.toString(),
                        onChanged: (val) => setState(() => order = val.toInt()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  Get.snackbar('Error', 'Field name is required',
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                final field = Field(
                  id: editField?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  sectionId: controller.sectionId,
                  name: nameController.text.trim(),
                  type: selectedType,
                  requiredField: requiredField,
                  unique: unique,
                  defaultValue: defaultValueController.text.isNotEmpty
                      ? defaultValueController.text
                      : null,
                  hint: hintController.text.isNotEmpty
                      ? hintController.text
                      : null,
                  allowedOptions: (selectedType == 'dropdown' ||
                              selectedType == 'multi_select' ||
                              selectedType == 'radio') &&
                          allowedOptionsController.text.isNotEmpty
                      ? allowedOptionsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .toList()
                      : null,
                  validation: validationController.text.isNotEmpty
                      ? {'regex': validationController.text}
                      : null,
                  attachmentRules: (selectedType == 'file' ||
                              selectedType == 'image' ||
                              selectedType == 'attachment') &&
                          (attachmentTypesController.text.isNotEmpty ||
                              attachmentMaxSizeController.text.isNotEmpty)
                      ? {
                          'allowedTypes':
                              attachmentTypesController.text.isNotEmpty
                                  ? attachmentTypesController.text
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList()
                                  : null,
                          'maxFileSizeMB': attachmentMaxSizeController
                                  .text.isNotEmpty
                              ? int.tryParse(attachmentMaxSizeController.text)
                              : null,
                        }
                      : null,
                  relations: selectedType == 'relation' &&
                          relationSectionController.text.isNotEmpty
                      ? {'section': relationSectionController.text}
                      : null,
                  formula: selectedType == 'computed' &&
                          formulaController.text.isNotEmpty
                      ? formulaController.text
                      : null,
                  conditionalVisibility:
                      conditionalVisibilityController.text.isNotEmpty
                          ? conditionalVisibilityController.text
                          : null,
                  order: order,
                );
                if (editField == null) {
                  controller.addField(field);
                  Get.snackbar('Success', 'Field added',
                      snackPosition: SnackPosition.BOTTOM);
                } else {
                  // Edit logic: update Hive and observable list
                  controller.fieldBox.put(field.id, field);
                  final idx =
                      controller.fields.indexWhere((f) => f.id == field.id);
                  if (idx != -1) controller.fields[idx] = field;
                  Get.snackbar('Success', 'Field updated',
                      snackPosition: SnackPosition.BOTTOM);
                }
                Navigator.of(context).pop();
              },
              child: Text(editField == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteField(
      BuildContext context, FieldController controller, Field field) {
    Get.defaultDialog(
      title: 'Delete Field',
      middleText: 'Are you sure you want to delete this field?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.fieldBox.delete(field.id);
        controller.fields.removeWhere((f) => f.id == field.id);
        Get.back();
        Get.snackbar('Deleted', 'Field deleted',
            snackPosition: SnackPosition.BOTTOM);
      },
    );
  }
}
