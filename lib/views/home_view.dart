import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/section_controller.dart';
import '../models/section_model.dart';
import 'section_detail_view.dart';
import 'section_create_view.dart';
import 'section_create_view.dart' show sectionIcons;
import 'sections_list_view.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

  final SectionController sectionController = Get.put(SectionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataNest',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
      ),
      drawer: Drawer(
        child: Obx(() {
          final sections = sectionController.sections;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: const Text('Welcome!',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                accountEmail: const Text('Your DataNest Workspace'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.deepPurple, size: 36),
                ),
                otherAccountsPictures: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.pop(context);
                      // Add settings navigation if needed
                    },
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.folder_special),
                title: const Text('Sections'),
                trailing: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text('${sections.length}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.deepPurple)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => SectionsListView());
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Section'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateSectionModal(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Quick Actions',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade400)),
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Sections'),
                onTap: () {
                  sectionController.refreshSections();
                  Navigator.pop(context);
                  Get.snackbar('Refreshed', 'Sections refreshed',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  // Add logout logic if needed
                  Navigator.pop(context);
                  Get.snackbar('Logout', 'Logout action (not implemented)',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
            ],
          );
        }),
      ),
      body: _buildDashboard(context),
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'DataNest',
      applicationVersion: 'v1.0.0',
      applicationIcon: const FlutterLogo(size: 40),
      children: [
        const SizedBox(height: 12),
        const Text(
          'DataNest is a modern, no-code data platform for managing custom sections, fields, and records. Built with Flutter, GetX, Hive, and Firebase.\n\nDeveloped by Nisan Roy.\n© 2025 DataNest Team.',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final sections = sectionController.sections;
    final int totalRecords = 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('Welcome to DataNest!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your no-code data platform dashboard.',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Get.to(() => SectionsListView());
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Column(
                        children: [
                          const Icon(Icons.folder,
                              color: Colors.deepPurple, size: 32),
                          const SizedBox(height: 8),
                          Text('${sections.length}',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const Text('Sections',
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Get.snackbar('Records', 'Record analytics coming soon!',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Column(
                        children: [
                          const Icon(Icons.table_rows,
                              color: Colors.teal, size: 32),
                          const SizedBox(height: 8),
                          Text('$totalRecords',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const Text('Records', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
