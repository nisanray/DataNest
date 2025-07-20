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
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeView extends StatefulWidget {
  final String userId;
  const HomeView({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late SectionController sectionController;
  late TabController _tabController;
  String _recordSearchQuery = '';

  @override
  void initState() {
    super.initState();
    sectionController =
        Get.put(SectionController(userId: widget.userId), tag: widget.userId);
    debugPrint('[UI] HomeView initialized for user: ${widget.userId}');
    SyncService(userId: widget.userId).onUserLogin();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataNest',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync',
            onPressed: () {
              debugPrint('[UI] Manual sync triggered from HomeView');
              final syncController = Get.find<SyncStatusController>();
              syncController.syncNow();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Sections'),
            Tab(icon: Icon(Icons.view_list), text: 'Records'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('User'),
              accountEmail: Text('user@example.com'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
              otherAccountsPictures: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  tooltip: 'Settings',
                  onPressed: () {
                    debugPrint('[UI] Settings icon tapped in drawer');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                debugPrint('[UI] Dashboard tapped in drawer');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Section'),
              onTap: () {
                debugPrint('[UI] New Section tapped in drawer');
                Navigator.pop(context);
                _showCreateSectionModal(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                debugPrint('[UI] Settings tapped in drawer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                debugPrint('[UI] About tapped in drawer');
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Quick Actions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade400)),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                debugPrint('[AUTH] User logging out from drawer');
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sections Grid View (existing)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        debugPrint('[UI] Navigating to SectionsListView');
                        Get.to(() => SectionsListView(widget.userId));
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('All Sections'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        debugPrint('[UI] Navigating to HiveDataViewerPage');
                        Get.toNamed('/hive-data-viewer');
                      },
                      icon: const Icon(Icons.storage),
                      label: const Text('Data Viewer'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: sectionController.listenable,
                  builder: (context, Box<Section> box, _) {
                    final sections = sectionController.filteredSections;
                    debugPrint(
                        '[UI] ValueListenableBuilder loaded ${sections.length} sections');
                    if (sections.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No sections yet',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
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
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: sections.length,
                      itemBuilder: (context, index) {
                        final section = sections[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              debugPrint(
                                  '[UI] Navigating to SectionDetailView for section: ${section.id}');
                              Get.to(() => SectionDetailView(
                                  section: section, userId: widget.userId));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: section.color != null
                                        ? _parseColor(section.color!)
                                        : Colors.deepPurple,
                                    child: Icon(_getSectionIcon(section.icon),
                                        color: Colors.white, size: 25),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    section.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (section.description != null &&
                                      section.description!.isNotEmpty)
                                    Text(
                                      section.description!,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Records Tab (advanced UX)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search records...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) =>
                      setState(() => _recordSearchQuery = val.trim()),
                ),
              ),
              Expanded(
                child: _buildSectionwiseRecords(context,
                    searchQuery: _recordSearchQuery),
              ),
            ],
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

  Widget _buildSectionwiseRecords(BuildContext context,
      {String searchQuery = ''}) {
    final sections = sectionController.filteredSections;
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
              ValueListenableBuilder(
                valueListenable: fieldController.listenable,
                builder: (context, Box<Field> box, _) {
                  final fields = fieldController.filteredFields;
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
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ))
                            .toList(),
                        const Divider(),
                      ],
                    ),
                  );
                },
              ),
              // Show records as before
              ValueListenableBuilder(
                valueListenable: recordController.listenable,
                builder: (context, Box<Record> box, _) {
                  final records = recordController.filteredRecords;
                  final filteredRecords = searchQuery.isEmpty
                      ? records
                      : records
                          .where((record) => record.data.entries.any((e) =>
                              e.key
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()) ||
                              (e.value?.toString().toLowerCase() ?? '')
                                  .contains(searchQuery.toLowerCase())))
                          .toList();
                  if (filteredRecords.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No records in this section.'),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredRecords.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, recIdx) {
                      final record = filteredRecords[recIdx];
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
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
