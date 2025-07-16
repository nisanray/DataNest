import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/section_controller.dart';
import '../models/section_model.dart';
import 'package:uuid/uuid.dart';

final List<Map<String, dynamic>> sectionIcons = [
  {'label': 'Folder', 'icon': Icons.folder, 'value': 'folder'},
  {'label': 'Book', 'icon': Icons.book, 'value': 'book'},
  {'label': 'Movie', 'icon': Icons.movie, 'value': 'movie'},
  {'label': 'Work', 'icon': Icons.work, 'value': 'work'},
  {'label': 'Star', 'icon': Icons.star, 'value': 'star'},
  {'label': 'Home', 'icon': Icons.home, 'value': 'home'},
  {'label': 'Person', 'icon': Icons.person, 'value': 'person'},
  {'label': 'Shopping', 'icon': Icons.shopping_cart, 'value': 'shopping_cart'},
  {'label': 'Event', 'icon': Icons.event, 'value': 'event'},
  {'label': 'Health', 'icon': Icons.favorite, 'value': 'favorite'},
  {'label': 'Travel', 'icon': Icons.flight, 'value': 'flight'},
  {'label': 'Money', 'icon': Icons.attach_money, 'value': 'attach_money'},
  {'label': 'School', 'icon': Icons.school, 'value': 'school'},
  {'label': 'Music', 'icon': Icons.music_note, 'value': 'music_note'},
  {'label': 'Photo', 'icon': Icons.photo, 'value': 'photo'},
  {'label': 'Settings', 'icon': Icons.settings, 'value': 'settings'},
  {'label': 'List', 'icon': Icons.list, 'value': 'list'},
  {'label': 'Map', 'icon': Icons.map, 'value': 'map'},
  {'label': 'Phone', 'icon': Icons.phone, 'value': 'phone'},
  {'label': 'Lock', 'icon': Icons.lock, 'value': 'lock'},
  {'label': 'Alarm', 'icon': Icons.alarm, 'value': 'alarm'},
];

final List<Map<String, dynamic>> sectionColors = [
  {'label': 'Blue', 'color': Colors.blue, 'hex': '#4285F4'},
  {'label': 'Green', 'color': Colors.green, 'hex': '#34A853'},
  {'label': 'Yellow', 'color': Colors.amber, 'hex': '#F9AB00'},
  {'label': 'Red', 'color': Colors.red, 'hex': '#EA4335'},
  {'label': 'Purple', 'color': Colors.purple, 'hex': '#A142F4'},
  {'label': 'Teal', 'color': Colors.teal, 'hex': '#00BFAE'},
  {'label': 'Orange', 'color': Colors.orange, 'hex': '#FF6D00'},
  {'label': 'Pink', 'color': Colors.pink, 'hex': '#D81B60'},
  {'label': 'Gray', 'color': Colors.grey, 'hex': '#9E9E9E'},
];

class SectionCreateView extends StatefulWidget {
  SectionCreateView({Key? key}) : super(key: key);

  @override
  State<SectionCreateView> createState() => _SectionCreateViewState();
}

class _SectionCreateViewState extends State<SectionCreateView> {
  final SectionController sectionController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedIcon = sectionIcons.first['value'];
  String? selectedColor = sectionColors.first['hex'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 360,
          minWidth: 220,
          maxHeight: 380,
        ),
        child: Material(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Create Section',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Icon',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedIcon,
                                items: sectionIcons.map((iconData) {
                                  return DropdownMenuItem<String>(
                                    value: iconData['value'],
                                    child: Row(
                                      children: [
                                        Icon(iconData['icon'], size: 22),
                                        const SizedBox(width: 4),
                                        Text(iconData['label']),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => selectedIcon = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Color',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedColor,
                                items: sectionColors.map((colorData) {
                                  return DropdownMenuItem<String>(
                                    value: colorData['hex'],
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: colorData['color'],
                                          radius: 9,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(colorData['label']),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => selectedColor = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Section Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Create Section',
                        style: TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) {
                        Get.snackbar('Error', 'Section name is required',
                            snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      final section = Section(
                        id: const Uuid().v4(),
                        name: nameController.text.trim(),
                        icon: selectedIcon,
                        color: selectedColor,
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                      );
                      sectionController.addSection(section);
                      Get.back();
                      Get.snackbar('Success', 'Section created',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
