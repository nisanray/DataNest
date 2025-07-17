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
  final String userId;
  const RecordsTab({Key? key, required this.section, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RecordController recordController = Get.put(
        RecordController(sectionId: section.id, userId: userId),
        tag: '${section.id}_$userId');
    final FieldController fieldController = Get.put(
        FieldController(sectionId: section.id, userId: userId),
        tag: '${section.id}_$userId');
    final TextEditingController searchController = TextEditingController();
    final RxString searchQuery = ''.obs;
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
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search records',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => searchQuery.value = val,
              ),
            ),
            Expanded(
              child: Obx(() {
                var records = List<Record>.from(recordController.records);
                final fields = fieldController.fields;
                // Filter by search query
                final query = searchQuery.value.trim().toLowerCase();
                if (query.isNotEmpty) {
                  records = records.where((record) {
                    return record.data.values.any((v) =>
                        v != null &&
                        v.toString().toLowerCase().contains(query));
                  }).toList();
                }
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Add record number
                                Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Get.dialog(RecordFormDialog(
                                      sectionId: section.id,
                                      userId: userId,
                                      editRecord: record,
                                    )),
                                    child: Text(
                                      titleValue ?? 'Record',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      recordController.deleteRecord(record.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...fieldOrder
                                .where((fieldName) =>
                                    visibleFields.contains(fieldName) &&
                                    (fieldDisplay[fieldName] ?? 'Normal') !=
                                        'Hidden')
                                .map((fieldName) {
                              final field = fields
                                  .firstWhereOrNull((f) => f.name == fieldName);
                              if (field == null) return const SizedBox.shrink();
                              final value = record.data[field.name];
                              final display =
                                  fieldDisplay[field.name] ?? 'Normal';
                              final align =
                                  fieldAlignment[field.name] ?? 'Left';
                              final colorHex =
                                  fieldColor[field.name] ?? '#00000000';
                              final color = _parseColor(colorHex);
                              TextAlign textAlign = TextAlign.left;
                              if (align == 'Center')
                                textAlign = TextAlign.center;
                              if (align == 'Right') textAlign = TextAlign.right;
                              FontWeight fontWeight = FontWeight.normal;
                              if (display == 'Bold')
                                fontWeight = FontWeight.bold;
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
                                        textAlign: textAlign,
                                        style: TextStyle(
                                          color: color.value == 0
                                              ? Colors.black87
                                              : color,
                                          fontWeight: fontWeight,
                                        ),
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
            ),
          ],
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () {
              // Ensure controllers are registered with the correct tag before opening dialog
              Get.put(FieldController(sectionId: section.id, userId: userId),
                  tag: '${section.id}_$userId');
              Get.put(RecordController(sectionId: section.id, userId: userId),
                  tag: '${section.id}_$userId');
              Get.dialog(
                RecordFormDialog(sectionId: section.id, userId: userId),
              );
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Record',
          ),
        ),
      ],
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
  final Record? editRecord;
  final String userId;
  const RecordFormDialog(
      {Key? key,
      required this.sectionId,
      required this.userId,
      this.editRecord})
      : super(key: key);

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
    // Use the same tag as registration
    final tag = '${widget.sectionId}_${widget.userId}';
    fieldController = Get.find<FieldController>(tag: tag);
    recordController = Get.find<RecordController>(tag: tag);
    // Do not pre-populate formData here, do it reactively in build
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editRecord == null ? 'Add Record' : 'Edit Record'),
      content: SingleChildScrollView(
        child: Obx(() {
          final fields = fieldController.fields;
          // Populate formData with default values if not already set
          for (final field in fields) {
            if (!formData.containsKey(field.name)) {
              formData[field.name] = field.defaultValue;
            }
          }
          if (fields.isEmpty) {
            return const Text('No fields defined for this section.');
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: fields
                .where((field) {
                  if (field.conditionalVisibility == null ||
                      field.conditionalVisibility!.isEmpty) {
                    return true;
                  }
                  try {
                    // Very basic evaluator: supports 'formData["FieldName"] == "value"' and similar
                    final condition = field.conditionalVisibility!;
                    final regex = RegExp(
                        r'formData\["([^\"]+)"\]\s*([!=]=)\s*"([^\"]*)"');
                    final match = regex.firstMatch(condition);
                    if (match != null) {
                      final key = match.group(1)!;
                      final op = match.group(2)!;
                      final val = match.group(3)!;
                      final current = formData[key]?.toString() ?? '';
                      if (op == '==') return current == val;
                      if (op == '!=') return current != val;
                    }
                    // If cannot parse, default to visible
                    return true;
                  } catch (_) {
                    return true;
                  }
                })
                .map((field) => _buildField(field))
                .toList(),
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
          child: Text(widget.editRecord == null ? 'Add' : 'Save'),
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
        final String userId = widget.userId;
        if (targetSectionId != null) {
          try {
            final relatedController = Get.put(
                RecordController(sectionId: targetSectionId, userId: userId),
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
        String? error;
        if (field.formula != null && field.formula!.isNotEmpty) {
          try {
            computedValue = field.formula!;
            final regex = RegExp(r'\{([^}]+)\}');
            computedValue = computedValue.replaceAllMapped(regex, (match) {
              final key = match.group(1)!;
              return formData[key]?.toString() ?? '0';
            });
            // Optionally, try to evaluate simple math
            computedValue = _tryEval(computedValue).toString();
          } catch (e) {
            error = 'Error: ${e.toString()}';
          }
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: error != null ? error : computedValue,
            decoration: InputDecoration(
              labelText: field.name + ' (Computed)',
              suffixIcon: const Icon(Icons.calculate),
              errorText: error,
            ),
            readOnly: true,
          ),
        );
      // Advanced/unsupported types
      case 'signature':
      case 'barcode':
      case 'location':
      case 'custom_code':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
              '${field.type[0].toUpperCase()}${field.type.substring(1)} field is not yet supported for input. Planned for a future update.'),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('Unsupported field type: ${field.type}'),
        );
    }
  }

  num _tryEval(String expr) {
    // Improved math evaluator: supports +, -, *, /, parentheses
    try {
      expr = expr.replaceAll(' ', '');
      if (expr.contains('(')) {
        // Handle parentheses recursively
        final paren = RegExp(r'\(([^()]+)\)');
        while (paren.hasMatch(expr)) {
          expr = expr.replaceAllMapped(
              paren, (m) => _tryEval(m.group(1)!).toString());
        }
      }
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
    } catch (e) {
      throw Exception('Invalid formula');
    }
  }

  void _submit() {
    final fields = fieldController.fields;
    // Validation enforcement
    for (final field in fields) {
      final value = formData[field.name];
      // Required
      if (field.requiredField && (value == null || value.toString().isEmpty)) {
        Get.snackbar('Error', 'Field "${field.name}" is required',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      // Unique
      if (field.unique && value != null && value.toString().isNotEmpty) {
        final isDuplicate = recordController.records.any((r) =>
            r.id != (widget.editRecord?.id ?? '') &&
            r.data[field.name] == value);
        if (isDuplicate) {
          Get.snackbar('Error', 'Field "${field.name}" must be unique',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }
      // Regex validation
      if (field.validation != null &&
          field.validation!['regex'] != null &&
          value != null &&
          value.toString().isNotEmpty) {
        final regex = RegExp(field.validation!['regex']);
        if (!regex.hasMatch(value.toString())) {
          Get.snackbar('Error',
              'Field "${field.name}" does not match the required format',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }
      // Min/Max (for numbers)
      if ((field.type == 'number' || field.type == 'currency') &&
          value != null &&
          value.toString().isNotEmpty) {
        final numValue = num.tryParse(value.toString());
        if (field.validation != null) {
          if (field.validation!['min'] != null &&
              numValue != null &&
              numValue < field.validation!['min']) {
            Get.snackbar('Error',
                'Field "${field.name}" must be at least ${field.validation!['min']}',
                snackPosition: SnackPosition.BOTTOM);
            return;
          }
          if (field.validation!['max'] != null &&
              numValue != null &&
              numValue > field.validation!['max']) {
            Get.snackbar('Error',
                'Field "${field.name}" must be at most ${field.validation!['max']}',
                snackPosition: SnackPosition.BOTTOM);
            return;
          }
        }
      }
    }
    final data = Map<String, dynamic>.from(formData);
    if (widget.editRecord == null) {
      recordController.addRecord(data);
      Get.back();
      Get.snackbar('Success', 'Record added',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      final updated = Record(
        id: widget.editRecord!.id,
        sectionId: widget.editRecord!.sectionId,
        data: data,
        attachments: widget.editRecord!.attachments,
        relations: widget.editRecord!.relations,
        synced: widget.editRecord!.synced,
      );
      recordController.editRecord(updated);
      Get.back();
      Get.snackbar('Success', 'Record updated',
          snackPosition: SnackPosition.BOTTOM);
    }
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
                      pickerColor: selectedColor,
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
