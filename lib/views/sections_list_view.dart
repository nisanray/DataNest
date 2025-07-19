import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/section_controller.dart';
import '../models/section_model.dart';
import 'section_detail_view.dart';
import 'section_create_view.dart';
import 'section_create_view.dart' show sectionIcons;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SectionsListView extends StatefulWidget {
  final String userId;
  SectionsListView(this.userId, {Key? key}) : super(key: key);

  @override
  State<SectionsListView> createState() => _SectionsListViewState();
}

class _SectionsListViewState extends State<SectionsListView> {
  late SectionController sectionController;
  final RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    debugPrint('[UI] SectionsListView initialized for user: ${widget.userId}');
    if (Get.isRegistered<SectionController>(tag: widget.userId)) {
      sectionController = Get.find<SectionController>(tag: widget.userId);
    } else {
      sectionController =
          Get.put(SectionController(userId: widget.userId), tag: widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[UI] SectionsListView build for user: ${widget.userId}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sections',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search sections...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => searchQuery.value = val,
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: sectionController.listenable,
              builder: (context, Box<Section> box, _) {
                debugPrint('[UI] ValueListenableBuilder triggered');
                final allSections = sectionController.filteredSections;
                final sections = allSections.where((section) {
                  final query = searchQuery.value.toLowerCase();
                  return section.name.toLowerCase().contains(query);
                }).toList();
                debugPrint('[UI] Filtered sections count: ${sections.length}');
                if (sections.isEmpty) {
                  debugPrint('[UI] No sections found, showing empty state');
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No sections yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first section to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                debugPrint('[UI] Displaying ${sections.length} sections');
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: sections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    debugPrint('[UI] Building section item: ${section.name}');
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: section.color != null
                              ? _parseColor(section.color!)
                              : Colors.deepPurple,
                          child: Icon(_getSectionIcon(section.icon),
                              color: Colors.white, size: 22),
                        ),
                        title: Text(section.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: section.description != null &&
                                section.description!.isNotEmpty
                            ? Text(section.description!,
                                maxLines: 1, overflow: TextOverflow.ellipsis)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Section',
                              onPressed: () async {
                                debugPrint(
                                    '[UI] Delete Section button pressed for: ${section.name}');
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Section'),
                                    content: Text(
                                        'Are you sure you want to delete this section? This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text('Delete'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  debugPrint(
                                      '[UI] Deleting section: ${section.name}');
                                  sectionController.deleteSection(section.id);
                                  Get.snackbar('Deleted', 'Section deleted',
                                      snackPosition: SnackPosition.BOTTOM);
                                }
                              },
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: Colors.deepPurple.shade200, size: 18),
                          ],
                        ),
                        onTap: () {
                          debugPrint(
                              '[UI] Navigating to SectionDetailView for section: ${section.name}');
                          Future.microtask(() {
                            Get.to(() => SectionDetailView(
                                section: section, userId: widget.userId));
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSectionModal(context),
        icon: const Icon(Icons.add),
        label: const Text('New Section'),
        tooltip: 'Add Section',
      ),
    );
  }

  void _showCreateSectionModal(BuildContext context) {
    debugPrint('[UI] New Section button pressed');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SectionCreateView(widget.userId),
    );
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.deepPurple;
    }
  }

  IconData _getSectionIcon(String? iconName) {
    final icon = sectionIcons.firstWhere(
      (iconData) => iconData['value'] == iconName,
      orElse: () => sectionIcons.first,
    );
    return icon['icon'] as IconData;
  }
}
