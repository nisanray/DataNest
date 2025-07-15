import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/section_model.dart';
import '../models/record_model.dart';
import '../controllers/record_controller.dart';
import '../controllers/field_controller.dart';
import '../models/field_model.dart';
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class RecordsTab extends StatelessWidget {
  final Section section;
  const RecordsTab({Key? key, required this.section}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RecordController recordController =
        Get.put(RecordController(sectionId: section.id), tag: section.id);
    final FieldController fieldController =
        Get.put(FieldController(sectionId: section.id), tag: section.id);
    return Stack(
      children: [
        Obx(() {
          final records = recordController.records;
          final fields = fieldController.fields;
          if (records.isEmpty) {
            return const Center(
                child: Text('No records yet. Tap + to add one.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final record = records[index];
              // Get the first field value for the title
              String? titleValue;
              if (fields.isNotEmpty) {
                final firstField = fields.first;
                titleValue = record.data[firstField.name]?.toString();
              }
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              titleValue ?? 'Record',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteRecord(
                                context, recordController, record),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...fields.map((field) {
                        final value = record.data[field.name];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldIcon(field.type),
                              const SizedBox(width: 8),
                              Text(
                                '${field.name}: ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Expanded(
                                child: Text(
                                  _formatFieldValue(field, value),
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () =>
                Get.dialog(RecordFormDialog(sectionId: section.id)),
            child: const Icon(Icons.add),
            tooltip: 'Add Record',
          ),
        ),
      ],
    );
  }

  void _confirmDeleteRecord(
      BuildContext context, RecordController controller, Record record) {
    Get.defaultDialog(
      title: 'Delete Record',
      middleText: 'Are you sure you want to delete this record?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.recordBox.delete(record.id);
        controller.records.removeWhere((r) => r.id == record.id);
        Get.back();
        Get.snackbar('Deleted', 'Record deleted',
            snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  // Helper to get an icon for a field type
  Widget _fieldIcon(String type) {
    switch (type) {
      case 'date':
      case 'datetime':
        return const Icon(Icons.event, size: 18, color: Colors.blueGrey);
      case 'number':
      case 'currency':
        return const Icon(Icons.numbers, size: 18, color: Colors.teal);
      case 'checkbox':
      case 'switch':
      case 'toggle':
        return const Icon(Icons.check_box, size: 18, color: Colors.green);
      case 'dropdown':
      case 'multi_select':
      case 'radio':
        return const Icon(Icons.list, size: 18, color: Colors.deepPurple);
      case 'file':
        return const Icon(Icons.attach_file, size: 18, color: Colors.orange);
      case 'image':
        return const Icon(Icons.image, size: 18, color: Colors.pink);
      case 'color':
        return const Icon(Icons.color_lens, size: 18, color: Colors.amber);
      case 'rating':
        return const Icon(Icons.star, size: 18, color: Colors.amber);
      case 'password':
        return const Icon(Icons.lock, size: 18, color: Colors.grey);
      default:
        return const Icon(Icons.text_fields, size: 18, color: Colors.grey);
    }
  }

  // Helper to format field value for display
  String _formatFieldValue(Field field, dynamic value) {
    if (value == null) return '-';
    switch (field.type) {
      case 'checkbox':
      case 'switch':
      case 'toggle':
        return value == true ? 'Yes' : 'No';
      case 'multi_select':
        if (value is List) return value.join(', ');
        return value.toString();
      case 'color':
        return value.toString();
      case 'rating':
        return value.toString();
      case 'date':
      case 'datetime':
        return value.toString().replaceFirst('T', ' ').split('.').first;
      default:
        return value.toString();
    }
  }
}

class RecordFormDialog extends StatefulWidget {
  final String sectionId;
  const RecordFormDialog({Key? key, required this.sectionId}) : super(key: key);

  @override
  State<RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<RecordFormDialog> {
  final Map<String, dynamic> formData = {};
  late final FieldController fieldController;
  late final RecordController recordController;

  @override
  void initState() {
    super.initState();
    fieldController = Get.find<FieldController>(tag: widget.sectionId);
    recordController = Get.find<RecordController>(tag: widget.sectionId);
    for (final field in fieldController.fields) {
      formData[field.name] = field.defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Record'),
      content: SingleChildScrollView(
        child: Obx(() {
          final fields = fieldController.fields;
          if (fields.isEmpty) {
            return const Text('No fields defined for this section.');
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: fields.map((field) => _buildField(field)).toList(),
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildField(Field field) {
    switch (field.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: formData[field.name]?.toString() ?? '',
            decoration: InputDecoration(labelText: field.name),
            onChanged: (val) => formData[field.name] = val,
            obscureText: field.type == 'password',
            validator: field.requiredField
                ? (val) => (val == null || val.isEmpty) ? 'Required' : null
                : null,
          ),
        );
      case 'password':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: formData[field.name]?.toString() ?? '',
            decoration: InputDecoration(labelText: field.name),
            obscureText: true,
            onChanged: (val) => formData[field.name] = val,
            validator: field.requiredField
                ? (val) => (val == null || val.isEmpty) ? 'Required' : null
                : null,
          ),
        );
      case 'number':
      case 'currency':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: formData[field.name]?.toString() ?? '',
            decoration: InputDecoration(
              labelText: field.name,
              prefixText: field.type == 'currency' ? ' 0 ' : null,
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => formData[field.name] = num.tryParse(val),
            validator: field.requiredField
                ? (val) => (val == null || val.isEmpty) ? 'Required' : null
                : null,
          ),
        );
      case 'date':
        return _DateField(
          label: field.name,
          initialValue: formData[field.name],
          onChanged: (val) => setState(() => formData[field.name] = val),
        );
      case 'datetime':
        return _DateTimeField(
          label: field.name,
          initialValue: formData[field.name],
          onChanged: (val) => setState(() => formData[field.name] = val),
        );
      case 'time':
        return _TimeField(
          label: field.name,
          initialValue: formData[field.name],
          onChanged: (val) => setState(() => formData[field.name] = val),
        );
      case 'checkbox':
        return CheckboxListTile(
          value: formData[field.name] ?? false,
          onChanged: (val) => setState(() => formData[field.name] = val),
          title: Text(field.name),
          controlAffinity: ListTileControlAffinity.leading,
        );
      case 'switch':
      case 'toggle':
        return SwitchListTile(
          value: formData[field.name] ?? false,
          onChanged: (val) => setState(() => formData[field.name] = val),
          title: Text(field.name),
        );
      case 'dropdown':
        final options = field.allowedOptions?.cast<String>() ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: formData[field.name],
            decoration: InputDecoration(labelText: field.name),
            items: options
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
            onChanged: (val) => setState(() => formData[field.name] = val),
          ),
        );
      case 'multi_select':
        final options = field.allowedOptions?.cast<String>() ?? [];
        final selected =
            (formData[field.name] as List?)?.cast<String>() ?? <String>[];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: options.map((opt) {
                  final isSelected = selected.contains(opt);
                  return FilterChip(
                    label: Text(opt),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          formData[field.name] = [...selected, opt];
                        } else {
                          formData[field.name] =
                              selected.where((s) => s != opt).toList();
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      case 'radio':
        final options = field.allowedOptions?.cast<String>() ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ...options.map((opt) => RadioListTile<String>(
                    value: opt,
                    groupValue: formData[field.name],
                    onChanged: (val) =>
                        setState(() => formData[field.name] = val),
                    title: Text(opt),
                  )),
            ],
          ),
        );
      case 'color':
        return _ColorField(
          label: field.name,
          initialValue: formData[field.name],
          onChanged: (val) => setState(() => formData[field.name] = val),
        );
      case 'rating':
        final rating = (formData[field.name] as int?) ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(field.name),
              const SizedBox(width: 8),
              ...List.generate(
                  5,
                  (i) => IconButton(
                        icon: Icon(i < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber),
                        onPressed: () =>
                            setState(() => formData[field.name] = i + 1),
                      )),
            ],
          ),
        );
      case 'json':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: formData[field.name]?.toString() ?? '',
            decoration: InputDecoration(labelText: field.name + ' (JSON)'),
            maxLines: 4,
            onChanged: (val) {
              try {
                formData[field.name] = jsonDecode(val);
              } catch (_) {
                formData[field.name] = val;
              }
            },
          ),
        );
      case 'file':
      case 'image':
        return _FileField(
          label: field.name,
          initialValue: formData[field.name],
          onChanged: (val) => setState(() => formData[field.name] = val),
          isImage: field.type == 'image',
        );
      // Advanced/unsupported types
      case 'computed':
      case 'relation':
      case 'attachment':
      case 'signature':
      case 'barcode':
      case 'location':
      case 'custom_code':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('${field.type} field is not yet supported for input.'),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('Unsupported field type: ${field.type}'),
        );
    }
  }

  void _submit() {
    final fields = fieldController.fields;
    for (final field in fields) {
      if (field.requiredField &&
          (formData[field.name] == null ||
              formData[field.name].toString().isEmpty)) {
        Get.snackbar('Error', 'Field "${field.name}" is required',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }
    recordController.addRecord(Map<String, dynamic>.from(formData));
    Get.back();
    Get.snackbar('Success', 'Record added',
        snackPosition: SnackPosition.BOTTOM);
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  const _DateField(
      {required this.label, this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        readOnly: true,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text = picked.toIso8601String().split('T').first;
            onChanged(controller.text);
          }
        },
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  const _DateTimeField(
      {required this.label, this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) {
              final dt = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
              controller.text = dt.toIso8601String();
              onChanged(controller.text);
            }
          }
        },
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  const _TimeField(
      {required this.label, this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        readOnly: true,
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            controller.text = time.format(context);
            onChanged(controller.text);
          }
        },
      ),
    );
  }
}

class _ColorField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  const _ColorField(
      {required this.label, this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Color? selectedColor =
        initialValue != null ? _parseColor(initialValue!) : Colors.blue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final color = await showDialog<Color>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Pick a color'),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: selectedColor!,
                      onColorChanged: (c) => Navigator.of(context).pop(c),
                    ),
                  ),
                ),
              );
              if (color != null) {
                onChanged('#${color.value.toRadixString(16).padLeft(8, '0')}');
              }
            },
            child: CircleAvatar(
              backgroundColor: selectedColor,
              radius: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }
}

class _FileField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final bool isImage;
  const _FileField(
      {required this.label,
      this.initialValue,
      required this.onChanged,
      this.isImage = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              // You can use file_picker or image_picker here
              // For now, just simulate file selection
              final fileName = isImage ? 'image.png' : 'file.pdf';
              onChanged(fileName);
            },
            child: Text('Pick ${isImage ? 'Image' : 'File'}'),
          ),
          if (initialValue != null) ...[
            const SizedBox(width: 8),
            Text(initialValue!),
          ],
        ],
      ),
    );
  }
}
