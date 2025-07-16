import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/section_model.dart';
import '../models/record_model.dart';
import '../controllers/record_controller.dart';
import '../controllers/field_controller.dart';
import '../models/field_model.dart';
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class RecordsTab extends StatelessWidget {
  final Section section;
  const RecordsTab({Key? key, required this.section}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RecordController recordController =
        Get.put(RecordController(sectionId: section.id), tag: section.id);
    final FieldController fieldController =
        Get.put(FieldController(sectionId: section.id), tag: section.id);
    // Extract section settings
    final settings = section.settings ?? {};
    final List<String> fieldOrder = List<String>.from(
        settings['fieldOrder'] ?? fieldController.fields.map((f) => f.name));
    final List<String> visibleFields = List<String>.from(
        settings['visibleFields'] ?? fieldController.fields.map((f) => f.name));
    final Map<String, dynamic> fieldDisplay =
        Map<String, dynamic>.from(settings['fieldDisplay'] ?? {});
    final Map<String, dynamic> fieldAlignment =
        Map<String, dynamic>.from(settings['fieldAlignment'] ?? {});
    final Map<String, dynamic> fieldColor =
        Map<String, dynamic>.from(settings['fieldColor'] ?? {});
    final String? sortBy = settings['sortBy'];
    final String sortOrder = settings['sortOrder'] ?? 'asc';

    return Stack(
      children: [
        Obx(() {
          var records = List<Record>.from(recordController.records);
          final fields = fieldController.fields;
          // Sort records if sortBy is set
          if (sortBy != null && fields.any((f) => f.name == sortBy)) {
            records.sort((a, b) {
              final aValue = a.data[sortBy];
              final bValue = b.data[sortBy];
              if (aValue == null && bValue == null) return 0;
              if (aValue == null) return sortOrder == 'asc' ? -1 : 1;
              if (bValue == null) return sortOrder == 'asc' ? 1 : -1;
              if (aValue is Comparable && bValue is Comparable) {
                return sortOrder == 'asc'
                    ? aValue.compareTo(bValue)
                    : bValue.compareTo(aValue);
              }
              return 0;
            });
          }
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
              // Use the first visible field as the title
              String? titleValue;
              if (fieldOrder.isNotEmpty) {
                final firstVisible = fieldOrder.firstWhere(
                  (f) =>
                      visibleFields.contains(f) &&
                      (fieldDisplay[f] ?? 'Normal') != 'Hidden',
                  orElse: () => '',
                );
                if (firstVisible.isNotEmpty) {
                  titleValue = record.data[firstVisible]?.toString();
                }
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
                      // Title at the top
                      if (titleValue != null && titleValue.isNotEmpty) ...[
                        Text(
                          titleValue,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20, thickness: 1),
                      ],
                      // Fields below
                      ...fieldOrder
                          .where((fieldName) =>
                              visibleFields.contains(fieldName) &&
                              (fieldDisplay[fieldName] ?? 'Normal') != 'Hidden')
                          .map((fieldName) {
                        final field =
                            fields.firstWhereOrNull((f) => f.name == fieldName);
                        if (field == null) return const SizedBox.shrink();
                        final value = record.data[field.name];
                        final display = fieldDisplay[field.name] ?? 'Normal';
                        final align = fieldAlignment[field.name] ?? 'Left';
                        final colorHex = fieldColor[field.name] ?? '#00000000';
                        final color = _parseColor(colorHex);
                        TextAlign textAlign = TextAlign.left;
                        if (align == 'Center') textAlign = TextAlign.center;
                        if (align == 'Right') textAlign = TextAlign.right;
                        FontWeight fontWeight = FontWeight.normal;
                        if (display == 'Bold') fontWeight = FontWeight.bold;
                        // Skip the title field in the details
                        if (fieldName == fieldOrder.first &&
                            titleValue != null &&
                            titleValue.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      color.value == 0 ? Colors.black87 : color,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatFieldValue(field, value),
                                style: TextStyle(
                                  color:
                                      color.value == 0 ? Colors.black87 : color,
                                  fontWeight: fontWeight,
                                  fontSize: 15,
                                ),
                                textAlign: textAlign,
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

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.black87;
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
        return _FileField(
          label: field.name,
          initialValue: formData[field.name],
          onChanged: (val) => setState(() => formData[field.name] = val),
          isImage: false,
        );
      case 'image':
        return _FileField(
          label: field.name,
          initialValue: formData[field.name],
          onChanged: (val) => setState(() => formData[field.name] = val),
          isImage: true,
        );
      case 'relation':
        // For now, simulate relation by letting user pick a record from the target section
        final targetSectionId = field.relations?['section'];
        List<Record> relatedRecords = [];
        if (targetSectionId != null) {
          try {
            final relatedController = Get.put(
                RecordController(sectionId: targetSectionId),
                tag: targetSectionId);
            relatedRecords = relatedController.records;
          } catch (_) {}
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: formData[field.name],
            decoration: InputDecoration(labelText: field.name + ' (Relation)'),
            items: relatedRecords.map((rec) {
              final display = rec.data.keys.isNotEmpty
                  ? rec.data.values.first.toString()
                  : rec.id;
              return DropdownMenuItem(value: rec.id, child: Text(display));
            }).toList(),
            onChanged: (val) => setState(() => formData[field.name] = val),
          ),
        );
      case 'computed':
        // Evaluate the formula using formData (simple expressions only)
        String computedValue = '';
        if (field.formula != null && field.formula!.isNotEmpty) {
          try {
            // Very basic: replace {fieldName} with value from formData
            computedValue = field.formula!;
            final regex = RegExp(r'\{([^}]+)\}');
            computedValue = computedValue.replaceAllMapped(regex, (match) {
              final key = match.group(1)!;
              return formData[key]?.toString() ?? '';
            });
            // Optionally, try to evaluate simple math
            if (RegExp(r'^[0-9+\-*/. ]+ 0$').hasMatch(computedValue)) {
              computedValue = _tryEval(computedValue).toString();
            }
          } catch (_) {}
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: computedValue,
            decoration: InputDecoration(
              labelText: field.name + ' (Computed)',
              suffixIcon: const Icon(Icons.calculate),
            ),
            readOnly: true,
          ),
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

  num _tryEval(String expr) {
    // Very basic math evaluator (supports +, -, *, /)
    try {
      expr = expr.replaceAll(' ', '');
      if (expr.contains('+')) {
        return expr.split('+').map(_tryEval).reduce((a, b) => a + b);
      } else if (expr.contains('-')) {
        final parts = expr.split('-');
        return parts.map(_tryEval).reduce((a, b) => a - b);
      } else if (expr.contains('*')) {
        return expr.split('*').map(_tryEval).reduce((a, b) => a * b);
      } else if (expr.contains('/')) {
        return expr.split('/').map(_tryEval).reduce((a, b) => a / b);
      } else {
        return num.parse(expr);
      }
    } catch (_) {
      return 0;
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
  const _FileField({
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.isImage = false,
  });

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
              String? fileName;
              if (isImage) {
                // Use image_picker
                try {
                  final picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (picked != null) fileName = picked.name;
                } catch (_) {
                  fileName = 'image.png'; // fallback
                }
              } else {
                // Use file_picker
                try {
                  final result = await FilePicker.platform.pickFiles();
                  if (result != null && result.files.isNotEmpty)
                    fileName = result.files.first.name;
                } catch (_) {
                  fileName = 'file.pdf'; // fallback
                }
              }
              if (fileName != null) onChanged(fileName);
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
