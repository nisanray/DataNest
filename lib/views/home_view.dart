import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/section_controller.dart';
import '../models/section_model.dart';
import 'section_detail_view.dart';
import 'section_create_view.dart';
import 'section_create_view.dart' show sectionIcons;
import 'sections_list_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/record_controller.dart';
import '../models/record_model.dart';
import '../controllers/field_controller.dart';
import '../models/field_model.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'hive_data_viewer.dart';
import '../services/sync_service.dart';
import '../main.dart'; // For SyncStatusController

class HomeView extends StatefulWidget {
  final String userId;
  const HomeView({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final SectionController sectionController =
      Get.put(SectionController(userId: widget.userId), tag: widget.userId);

  @override
  void initState() {
    super.initState();
    // Sync user data from Firebase to Hive after login
    SyncService(userId: widget.userId).onUserLogin();
  }

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
        actions: [
          Obx(() {
            final sync = Get.find<SyncStatusController>();
            if (sync.isSyncing.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.cloud_sync, color: Colors.blue),
                  ],
                ),
              );
            } else {
              return Icon(
                Icons.cloud_sync,
                color: Colors.green,
                semanticLabel: 'Synced',
              );
            }
          }),
          IconButton(
            icon: const Icon(Icons.storage),
            tooltip: 'View Hive Data',
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const HiveDataViewer(),
            ),
          ),
        ],
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
                accountEmail: Text(widget.userId),
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
                  Get.to(() => SectionsListView(widget.userId));
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
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }),
      ),
      body: _buildSectionwiseRecords(context),
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

  Widget _buildSectionwiseRecords(BuildContext context) {
    final sections = sectionController.sections;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final recordController = Get.put(
            RecordController(sectionId: section.id, userId: widget.userId),
            tag: '${section.id}_${widget.userId}');
        final fieldController = Get.put(
            FieldController(sectionId: section.id, userId: widget.userId),
            tag: '${section.id}_${widget.userId}');
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(_getSectionIcon(section.icon),
                    color: _parseColor(section.color ?? '#673ab7')),
                const SizedBox(width: 12),
                Text(section.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            subtitle: Text(section.description ?? ''),
            children: [
              // Show fields (items) of the section
              Obx(() {
                final fields = fieldController.fields;
                if (fields.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No fields in this section.'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fields:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...fields
                          .map((field) => Row(
                                children: [
                                  Icon(Icons.view_column,
                                      size: 16, color: Colors.deepPurple),
                                  const SizedBox(width: 6),
                                  Text(field.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 8),
                                  Text('(${field.type})',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ))
                          .toList(),
                      const Divider(),
                    ],
                  ),
                );
              }),
              // Show records as before
              Obx(() {
                final records = recordController.records;
                if (records.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No records in this section.'),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, recIdx) {
                    final record = records[recIdx];
                    return ListTile(
                      title: Text(record.data.keys.isNotEmpty
                          ? record.data.values.first.toString()
                          : 'Record'),
                      subtitle: Text(record.data.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join(', ')),
                      onTap: () => Get.to(() => SectionDetailView(
                          section: section, userId: widget.userId)),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
