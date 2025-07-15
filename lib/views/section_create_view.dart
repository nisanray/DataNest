import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/section_controller.dart';
import '../models/section_model.dart';
import 'package:uuid/uuid.dart';

// List of available icons for sections
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
  // Add more as needed
];

// List of available colors for sections
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
  // Add more as needed
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
    return Scaffold(
      appBar: AppBar(title: const Text('Create Section')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Section Name'),
            ),
            const SizedBox(height: 12),
            // Icon dropdown with preview
            DropdownButtonFormField<String>(
              value: selectedIcon,
              decoration: const InputDecoration(labelText: 'Icon'),
              items: sectionIcons.map((iconData) {
                return DropdownMenuItem<String>(
                  value: iconData['value'],
                  child: Container(
                    width: 140, // Set the width for the dropdown menu item
                    child: Row(
                      children: [
                        Icon(iconData['icon']),
                        const SizedBox(width: 8),
                        Text(iconData['label']),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedIcon = value;
                });
              },
            ),
            const SizedBox(height: 12),
            // Color dropdown with preview
            DropdownButtonFormField<String>(
              value: selectedColor,
              decoration: const InputDecoration(labelText: 'Color'),
              items: sectionColors.map((colorData) {
                return DropdownMenuItem<String>(
                  value: colorData['hex'],
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorData['color'],
                        radius: 10,
                      ),
                      const SizedBox(width: 8),
                      Text(colorData['label']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedColor = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Section name is required');
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
                  Get.snackbar('Success', 'Section created');
                },
                child: const Text('Create Section'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
