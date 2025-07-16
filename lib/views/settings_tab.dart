import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/section_model.dart';
import '../controllers/field_controller.dart';
import '../controllers/section_controller.dart';
import 'section_create_view.dart' show sectionIcons;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../controllers/record_controller.dart';
import 'package:collection/collection.dart';

class SettingsTab extends StatefulWidget {
  final Section section;
  const SettingsTab({Key? key, required this.section}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late final FieldController fieldController;
  late final SectionController sectionController;
  late String name;
  late String? icon;
  late String? color;
  late String? description;
  late Map<String, dynamic> settings;
  late String? sortBy;
  late String sortOrder;
  late Map<String, dynamic> fieldDisplay;
  late List<String> fieldOrder;
  late Map<String, dynamic> fieldAlignment;
  late Map<String, dynamic> fieldColor;

  @override
  void initState() {
    super.initState();
    fieldController = Get.find<FieldController>(tag: widget.section.id);
    sectionController = SectionController();
    name = widget.section.name;
    icon = widget.section.icon;
    color = widget.section.color;
    description = widget.section.description;
    settings = Map<String, dynamic>.from(widget.section.settings ?? {});
    if (settings['visibleFields'] == null) {
      settings['visibleFields'] =
          fieldController.fields.map((f) => f.name).toList();
    }
    sortBy = settings['sortBy'] ??
        (fieldController.fields.isNotEmpty
            ? fieldController.fields.first.name
            : null);
    sortOrder = settings['sortOrder'] ?? 'asc';
    fieldDisplay = Map<String, dynamic>.from(settings['fieldDisplay'] ?? {});
    for (final field in fieldController.fields) {
      fieldDisplay.putIfAbsent(field.name, () => 'Normal');
    }
    fieldOrder = List<String>.from(
        settings['fieldOrder'] ?? fieldController.fields.map((f) => f.name));
    fieldAlignment =
        Map<String, dynamic>.from(settings['fieldAlignment'] ?? {});
    for (final field in fieldController.fields) {
      fieldAlignment.putIfAbsent(field.name, () => 'Left');
    }
    fieldColor = Map<String, dynamic>.from(settings['fieldColor'] ?? {});
    for (final field in fieldController.fields) {
      fieldColor.putIfAbsent(field.name, () => '#00000000');
    }
  }

  void _showEditSectionDialog() {
    String editName = name;
    String? editIcon = icon;
    String? editColor = color;
    String? editDescription = description;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Section Info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: editName,
                decoration: const InputDecoration(labelText: 'Section Name'),
                onChanged: (val) => editName = val,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: editIcon,
                decoration: const InputDecoration(labelText: 'Icon'),
                items: sectionIcons.map((iconData) {
                  return DropdownMenuItem<String>(
                    value: iconData['value'],
                    child: Row(
                      children: [
                        Icon(iconData['icon']),
                        const SizedBox(width: 8),
                        Text(iconData['label']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => editIcon = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: editColor,
                decoration: const InputDecoration(
                    labelText: 'Color (hex, e.g. #4285F4)'),
                onChanged: (val) => editColor = val,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: editDescription,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (val) => editDescription = val,
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
              setState(() {
                name = editName;
                icon = editIcon;
                color = editColor;
                description = editDescription;
              });
              final updatedSection = widget.section
                ..name = name
                ..icon = icon
                ..color = color
                ..description = description;
              sectionController.editSection(widget.section.id, updatedSection);
              Navigator.of(context).pop();
              Get.snackbar('Success', 'Section info updated',
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      const Text('Section Info',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Icon: '),
                            Icon(
                              sectionIcons.firstWhere(
                                  (iconData) => iconData['value'] == icon,
                                  orElse: () => sectionIcons.first)['icon'],
                            ),
                          ],
                        ),
                        if (color != null && color!.isNotEmpty)
                          Row(
                            children: [
                              const Text('Color: '),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _parseColor(color!),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(color!),
                            ],
                          ),
                        if (description != null && description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(description!),
                          ),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      onPressed: _showEditSectionDialog,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 36)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      const Text('Record List Display',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final fields = fieldController.fields;
                    if (fields.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                            'No fields defined. Add fields in the Fields tab.'),
                      );
                    }
                    return Column(
                      children: [
                        // Sorting controls
                        Row(
                          children: [
                            Tooltip(
                              message: 'Choose which field to sort records by',
                              child: const Text('Sort by:'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: sortBy,
                                    isExpanded: true,
                                    items: fields
                                        .map((f) => DropdownMenuItem(
                                              value: f.name,
                                              child: Text(f.name),
                                            ))
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => sortBy = val),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: sortOrder,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'asc', child: Text('Ascending')),
                                    DropdownMenuItem(
                                        value: 'desc',
                                        child: Text('Descending')),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => sortOrder = val ?? 'asc'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Dynamic field display customization
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex--;
                              final item = fieldOrder.removeAt(oldIndex);
                              fieldOrder.insert(newIndex, item);
                              settings['fieldOrder'] = fieldOrder;
                            });
                          },
                          children: [
                            for (final fieldName in fieldOrder)
                              if (fields.any((f) => f.name == fieldName))
                                Card(
                                  key: ValueKey(fieldName),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.drag_handle,
                                            color: Colors.grey[400]),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(fieldName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500))),
                                        const SizedBox(width: 8),
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: fieldDisplay[fieldName] ??
                                                  'Normal',
                                              items: const [
                                                DropdownMenuItem(
                                                    value: 'Bold',
                                                    child: Text('Bold')),
                                                DropdownMenuItem(
                                                    value: 'Normal',
                                                    child: Text('Normal')),
                                                DropdownMenuItem(
                                                    value: 'Hidden',
                                                    child: Text('Hidden')),
                                              ],
                                              onChanged: (val) {
                                                setState(() {
                                                  fieldDisplay[fieldName] =
                                                      val ?? 'Normal';
                                                  settings['fieldDisplay'] =
                                                      fieldDisplay;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value:
                                                  fieldAlignment[fieldName] ??
                                                      'Left',
                                              items: const [
                                                DropdownMenuItem(
                                                    value: 'Left',
                                                    child: Text('Left')),
                                                DropdownMenuItem(
                                                    value: 'Center',
                                                    child: Text('Center')),
                                                DropdownMenuItem(
                                                    value: 'Right',
                                                    child: Text('Right')),
                                              ],
                                              onChanged: (val) {
                                                setState(() {
                                                  fieldAlignment[fieldName] =
                                                      val ?? 'Left';
                                                  settings['fieldAlignment'] =
                                                      fieldAlignment;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Tooltip(
                                          message: 'Pick highlight color',
                                          child: GestureDetector(
                                            onTap: () async {
                                              final picked =
                                                  await showDialog<Color>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Pick highlight color'),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: BlockPicker(
                                                      pickerColor: _parseColor(
                                                          fieldColor[
                                                                  fieldName] ??
                                                              '#00000000'),
                                                      onColorChanged: (c) =>
                                                          Navigator.of(context)
                                                              .pop(c),
                                                    ),
                                                  ),
                                                ),
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  fieldColor[fieldName] =
                                                      '#${picked.value.toRadixString(16).padLeft(8, '0')}';
                                                  settings['fieldColor'] =
                                                      fieldColor;
                                                });
                                              }
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: _parseColor(
                                                  fieldColor[fieldName] ??
                                                      '#00000000'),
                                              radius: 12,
                                              child: (fieldColor[fieldName] ==
                                                          null ||
                                                      _parseColor(fieldColor[
                                                                  fieldName])
                                                              .value ==
                                                          0)
                                                  ? const Icon(Icons.color_lens,
                                                      size: 16,
                                                      color: Colors.grey)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Tooltip(
                                          message:
                                              'Show/hide field in record list',
                                          child: Switch(
                                            value: List<String>.from(
                                                    settings['visibleFields'] ??
                                                        [])
                                                .contains(fieldName),
                                            onChanged: (val) {
                                              setState(() {
                                                final visibleFields =
                                                    List<String>.from(settings[
                                                            'visibleFields'] ??
                                                        []);
                                                if (val) {
                                                  visibleFields.add(fieldName);
                                                } else {
                                                  visibleFields
                                                      .remove(fieldName);
                                                }
                                                settings['visibleFields'] =
                                                    visibleFields;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Settings',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        elevation: 2,
                      ),
                      onPressed: _saveSettings,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Record List Preview
                  Text('Record List Preview',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple)),
                  const SizedBox(height: 12),
                  _RecordListPreview(
                    sectionId: widget.section.id,
                    fieldOrder: fieldOrder,
                    visibleFields:
                        List<String>.from(settings['visibleFields'] ?? []),
                    fieldDisplay: fieldDisplay,
                    fieldAlignment: fieldAlignment,
                    fieldColor: fieldColor,
                  ),
                ],
              ),
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
      return const Color(0x00000000);
    }
  }

  void _saveSettings() {
    settings['sortBy'] = sortBy;
    settings['sortOrder'] = sortOrder;
    settings['fieldDisplay'] = fieldDisplay;
    settings['fieldOrder'] = fieldOrder;
    settings['fieldAlignment'] = fieldAlignment;
    settings['fieldColor'] = fieldColor;
    final updatedSection = widget.section
      ..name = name
      ..icon = icon
      ..color = color
      ..description = description
      ..settings = settings;
    sectionController.editSection(widget.section.id, updatedSection);
    Get.snackbar('Success', 'Section settings updated',
        snackPosition: SnackPosition.BOTTOM);
  }
}

class _RecordListPreview extends StatelessWidget {
  final String sectionId;
  final List<String> fieldOrder;
  final List<String> visibleFields;
  final Map<String, dynamic> fieldDisplay;
  final Map<String, dynamic> fieldAlignment;
  final Map<String, dynamic> fieldColor;

  const _RecordListPreview({
    required this.sectionId,
    required this.fieldOrder,
    required this.visibleFields,
    required this.fieldDisplay,
    required this.fieldAlignment,
    required this.fieldColor,
  });

  @override
  Widget build(BuildContext context) {
    final recordController = Get.put(
      // ignore: unnecessary_cast
      Get.find<dynamic>(tag: sectionId) ??
          Get.put(RecordController(sectionId: sectionId), tag: sectionId),
      tag: sectionId,
    ) as RecordController;
    final fieldController = Get.find<FieldController>(tag: sectionId);
    final fields = fieldController.fields;
    final records = recordController.records.take(3).toList();
    final visibleFieldNames = fieldOrder
        .where((fieldName) =>
            visibleFields.contains(fieldName) &&
            (fieldDisplay[fieldName] ?? 'Normal') != 'Hidden')
        .toList();
    if (records.isEmpty) {
      return const Text('No records yet. Add some records to see a preview.');
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: visibleFieldNames
            .map((fieldName) => DataColumn(
                  label: Text(
                    fieldName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
        rows: records.map((record) {
          return DataRow(
            cells: visibleFieldNames.map((fieldName) {
              final field = fields.firstWhereOrNull((f) => f.name == fieldName);
              final value = field != null ? record.data[field.name] : null;
              final display = fieldDisplay[fieldName] ?? 'Normal';
              final colorHex = fieldColor[fieldName] ?? '#00000000';
              final color = _parseColor(colorHex);
              FontWeight fontWeight = FontWeight.normal;
              if (display == 'Bold') fontWeight = FontWeight.bold;
              return DataCell(
                Text(
                  value?.toString() ?? '-',
                  style: TextStyle(
                    color: color.value == 0 ? Colors.black87 : color,
                    fontWeight: fontWeight,
                    fontSize: 15,
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
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
      return Colors.black87;
    }
  }
}
