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
                  // TODO: Add onTap for field edit
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

  void _showAddFieldDialog(BuildContext context, FieldController controller) {
    final TextEditingController nameController = TextEditingController();
    String selectedType = FieldController.fieldTypes.first['value']!;
    bool requiredField = false;
    bool unique = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Field'),
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
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  sectionId: controller.sectionId,
                  name: nameController.text.trim(),
                  type: selectedType,
                  requiredField: requiredField,
                  unique: unique,
                  order: controller.fields.length,
                );
                controller.addField(field);
                Navigator.of(context).pop();
                Get.snackbar('Success', 'Field added',
                    snackPosition: SnackPosition.BOTTOM);
              },
              child: const Text('Add'),
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
