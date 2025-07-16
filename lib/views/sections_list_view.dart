import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/section_controller.dart';
import '../models/section_model.dart';
import 'section_detail_view.dart';
import 'section_create_view.dart';
import 'section_create_view.dart' show sectionIcons;

class SectionsListView extends StatelessWidget {
  SectionsListView({Key? key}) : super(key: key);

  final SectionController sectionController = Get.put(SectionController());
  final RxString searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sections',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => sectionController.refreshSections(),
          ),
        ],
      ),
      body: Obx(() {
        final sections = sectionController.sections.where((section) {
          final query = searchQuery.value.toLowerCase();
          return section.name.toLowerCase().contains(query);
        }).toList();
        return RefreshIndicator(
          onRefresh: () async {
            sectionController.refreshSections();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search sections...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => searchQuery.value = val,
                ),
              ),
              Expanded(
                child: sections.isEmpty
                    ? const Center(child: Text('No sections found.'))
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: sections.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final section = sections[index];
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: section.description != null &&
                                      section.description!.isNotEmpty
                                  ? Text(section.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)
                                  : null,
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Colors.deepPurple.shade200, size: 18),
                              onTap: () => Get.to(
                                  () => SectionDetailView(section: section)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSectionModal(context),
        icon: const Icon(Icons.add),
        label: const Text('New Section'),
        tooltip: 'Add Section',
      ),
    );
  }

  void _showCreateSectionModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SectionCreateView(),
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
