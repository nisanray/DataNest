import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/section_controller.dart';
import '../models/section_model.dart';
import 'section_create_view.dart';
import 'section_detail_view.dart';
// Import sectionIcons from section_create_view.dart
import 'section_create_view.dart' show sectionIcons;

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

  final SectionController sectionController = Get.put(SectionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DataNest')),
      body: Obx(() {
        final sections = sectionController.sections;
        if (sections.isEmpty) {
          return const Center(
              child: Text('No sections yet. Tap + to add one.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final section = sections[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: section.color != null
                      ? _parseColor(section.color!)
                      : Colors.blue,
                  child: Icon(
                    _getSectionIcon(section.icon),
                    color: Colors.white,
                  ),
                ),
                title: Text(section.name),
                subtitle: section.description != null &&
                        section.description!.isNotEmpty
                    ? Text(section.description!)
                    : null,
                onTap: () => Get.to(() => SectionDetailView(section: section)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteSection(context, section),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => SectionCreateView()),
        child: const Icon(Icons.add),
        tooltip: 'Add Section',
      ),
    );
  }

  // Helper to parse hex color string
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

  // Helper to get icon from icon name
  IconData _getSectionIcon(String? iconName) {
    final icon = sectionIcons.firstWhere(
      (iconData) => iconData['value'] == iconName,
      orElse: () => sectionIcons.first,
    );
    return icon['icon'] as IconData;
  }

  void _confirmDeleteSection(BuildContext context, Section section) {
    Get.defaultDialog(
      title: 'Delete Section',
      middleText:
          'Are you sure you want to delete this section? This will also delete all its records and fields.',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        sectionController.deleteSection(section.id);
        Get.back();
        Get.snackbar('Deleted', 'Section deleted',
            snackPosition: SnackPosition.BOTTOM);
      },
    );
  }
}
