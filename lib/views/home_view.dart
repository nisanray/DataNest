import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/section_controller.dart';
import '../models/section_model.dart';
import 'section_detail_view.dart';
import 'section_create_view.dart';
import 'sections_list_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/record_controller.dart';
import '../models/record_model.dart';
import '../controllers/field_controller.dart';
import '../models/field_model.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import '../app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'hive_data_viewer.dart';
import '../services/sync_service.dart';
import '../main.dart'; // For SyncStatusController
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'records_tab.dart' show RecordFormDialog;

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

  @override
  void initState() {
    super.initState();
    // Ensure SectionController is registered with GetX for this userId
    final tag = widget.userId;
    if (!Get.isRegistered<SectionController>(tag: tag)) {
      Get.put(SectionController(userId: tag), tag: tag);
    }
    sectionController = Get.find<SectionController>(tag: tag);
    // Initialize _tabController with a default length (adjust as needed)
    _tabController = TabController(length: 1, vsync: this);
  }

  String _recordSearchQuery = '';
  int _selectedNavIndex = 0;
  Timer? _periodicSyncTimer;

  @override
  void dispose() {
    _periodicSyncTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(child: Icon(Icons.person)),
      onSelected: (value) async {
        if (value == 'logout') {
          debugPrint('[AUTH] User logging out from profile menu');
          await FirebaseAuth.instance.signOut();
        } else if (value == 'settings') {
          // Navigate to settings (future)
        } else if (value == 'about') {
          _showAboutDialog(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuItem(value: 'about', child: Text('About')),
        const PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final syncController = Get.find<SyncStatusController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataNest',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
        actions: [
          Obx(() => syncController.isSyncing.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Sync',
                  onPressed: () {
                    debugPrint('[UI] Manual sync triggered from HomeView');
                    syncController.syncNow();
                  },
                )),
          // _buildProfileMenu(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Builder(
              builder: (context) {
                final user = FirebaseAuth.instance.currentUser;
                return UserAccountsDrawerHeader(
                  accountName: Row(
                    children: [
                      Expanded(child: Text(user?.displayName ?? 'User')),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: Colors.white),
                        tooltip: 'Edit Profile',
                        onPressed: () async {
                          final nameController = TextEditingController(
                              text: user?.displayName ?? '');
                          final emailController =
                              TextEditingController(text: user?.email ?? '');
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit Profile'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                        labelText: 'Name'),
                                  ),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                        labelText: 'Email'),
                                    enabled:
                                        false, // Email change requires re-auth
                                  ),
                                  // Add more fields here if needed
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                          if (result == true &&
                              nameController.text.trim().isNotEmpty) {
                            // Update FirebaseAuth displayName if changed or missing
                            if (user?.displayName !=
                                nameController.text.trim()) {
                              await user?.updateDisplayName(
                                  nameController.text.trim());
                            }
                            // Update Firestore user doc with new info
                            try {
                              final users = FirebaseFirestore.instance
                                  .collection('users');
                              final userDoc = users.doc(user?.uid);
                              final userData = <String, dynamic>{
                                'displayName': nameController.text.trim(),
                                'email': user?.email,
                                // Add more fields here if needed
                              };
                              await userDoc.set(
                                  userData, SetOptions(merge: true));
                            } catch (e) {
                              debugPrint(
                                  '[AUTH] Failed to sync user profile to Firestore: $e');
                            }
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  accountEmail: Text(user?.email ?? ''),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Colors.deepPurple),
                  ),
                  otherAccountsPictures: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      tooltip: 'Settings',
                      onPressed: () {
                        debugPrint('[UI] Settings icon tapped in drawer');
                        Navigator.pop(context);
                        setState(() => _selectedNavIndex = 3);
                      },
                    ),
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: _selectedNavIndex == 0,
              onTap: () {
                debugPrint('[UI] Dashboard tapped in drawer');
                Navigator.pop(context);
                setState(() => _selectedNavIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('All Sections'),
              onTap: () {
                debugPrint('[UI] All Sections tapped in drawer');
                Navigator.pop(context);
                Get.to(() => SectionsListView(widget.userId));
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Data Viewer'),
              onTap: () {
                debugPrint('[UI] Data Viewer tapped in drawer');
                Navigator.pop(context);
                Get.toNamed('/hive-data-viewer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Records'),
              selected: _selectedNavIndex == 1,
              onTap: () {
                debugPrint('[UI] Records tapped in drawer');
                Navigator.pop(context);
                setState(() => _selectedNavIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              onTap: () {
                debugPrint('[UI] Tasks tapped in drawer');
                Navigator.pop(context);
                Get.toNamed('/tasks');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              selected: _selectedNavIndex == 3,
              onTap: () {
                debugPrint('[UI] Settings tapped in drawer');
                Navigator.pop(context);
                setState(() => _selectedNavIndex = 3);
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
      body: _buildMainContent(context, true),
      floatingActionButton: _selectedNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateSectionModal(context),
              icon: const Icon(Icons.add),
              label: const Text('New Section'),
              tooltip: 'Add Section',
            )
          : null,
      // Remove NavigationRail and BottomNavigationBar, Drawer is now main nav
    );
  }

  Widget _buildMainContent(BuildContext context, bool isWide) {
    switch (_selectedNavIndex) {
      case 0:
        return _buildSectionsTab(context);
      case 1:
        return _buildRecordsTab(context);
      case 2:
        return _buildDataViewerTab(context);
      case 3:
        return _buildSettingsTab(context);
      case 4:
        _showAboutDialog(context);
        return const SizedBox.shrink();
      default:
        return _buildSectionsTab(context);
    }
  }

  Widget _buildSectionsTab(BuildContext context) {
    // Advanced mobile UX: show a list of sections as ExpansionTiles, each showing its records
    final sections = sectionController.filteredSections;
    return sections.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No sections yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Create your first section to get started',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              final recordController = Get.put(
                RecordController(sectionId: section.id, userId: widget.userId),
                tag: '${section.id}_${widget.userId}',
              );
              final fieldController = Get.put(
                FieldController(sectionId: section.id, userId: widget.userId),
                tag: '${section.id}_${widget.userId}',
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: section.color != null
                        ? _parseColor(section.color!)
                        : Colors.deepPurple,
                    child: Icon(_getSectionIcon(section.icon),
                        color: Colors.white),
                  ),
                  title: Text(section.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: section.description != null &&
                          section.description!.isNotEmpty
                      ? Text(section.description!,
                          maxLines: 2, overflow: TextOverflow.ellipsis)
                      : null,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: recordController.listenable,
                      builder: (context, Box<Record> box, _) {
                        final records = recordController.filteredRecords;
                        if (records.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No records in this section.'),
                          );
                        }
                        final fields = fieldController.filteredFields;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: records.length,
                          itemBuilder: (context, recIdx) {
                            final record = records[recIdx];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              child: ListTile(
                                title: Text(
                                  fields.isNotEmpty
                                      ? (record.data[fields.first.name]
                                              ?.toString() ??
                                          'Record')
                                      : 'Record',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: fields.length > 1
                                    ? Text(fields
                                        .skip(1)
                                        .map((f) =>
                                            record.data[f.name]?.toString() ??
                                            '')
                                        .where((s) => s.isNotEmpty)
                                        .join(', '))
                                    : null,
                                onTap: () => Get.dialog(RecordFormDialog(
                                  sectionId: section.id,
                                  userId: widget.userId,
                                  editRecord: record,
                                )),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      recordController.deleteRecord(record.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 12),
                        child: FloatingActionButton.small(
                          heroTag: 'add_record_${section.id}',
                          onPressed: () {
                            Get.dialog(RecordFormDialog(
                              sectionId: section.id,
                              userId: widget.userId,
                            ));
                          },
                          child: const Icon(Icons.add),
                          tooltip: 'Add Record',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildRecordsTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search records...',
              prefixIcon: Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) => setState(() => _recordSearchQuery = val.trim()),
          ),
        ),
        Expanded(
          child: _buildSectionwiseRecords(context,
              searchQuery: _recordSearchQuery),
        ),
      ],
    );
  }

  Widget _buildDataViewerTab(BuildContext context) {
    // Navigate to HiveDataViewerPage or embed if desired
    return HiveDataViewer();
  }

  Widget _buildSettingsTab(BuildContext context) {
    // Placeholder for settings
    return const Center(child: Text('Settings (coming soon)'));
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
        final settings = section.settings ?? {};
        final List<String> fieldOrder = List<String>.from(
            settings['fieldOrder'] ??
                fieldController.filteredFields.map((f) => f.name));
        final List<String> visibleFields = List<String>.from(
            settings['visibleFields'] ??
                fieldController.filteredFields.map((f) => f.name));
        final Map<String, dynamic> fieldDisplay =
            Map<String, dynamic>.from(settings['fieldDisplay'] ?? {});
        final String? sortBy = settings['sortBy'];
        final String sortOrder = settings['sortOrder'] ?? 'asc';
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
              ValueListenableBuilder(
                valueListenable: recordController.listenable,
                builder: (context, Box<Record> box, _) {
                  var records =
                      List<Record>.from(recordController.filteredRecords);
                  // Filter by search query
                  final query = searchQuery.trim().toLowerCase();
                  if (query.isNotEmpty) {
                    records = records.where((record) {
                      return record.data.values.any((value) =>
                          value.toString().toLowerCase().contains(query));
                    }).toList();
                  }
                  // Sort records
                  if (sortBy != null) {
                    records.sort((a, b) {
                      final aVal = a.data[sortBy];
                      final bVal = b.data[sortBy];
                      if (aVal == null && bVal == null) return 0;
                      if (aVal == null) return sortOrder == 'asc' ? -1 : 1;
                      if (bVal == null) return sortOrder == 'asc' ? 1 : -1;
                      final comparison =
                          aVal.toString().compareTo(bVal.toString());
                      return sortOrder == 'asc' ? comparison : -comparison;
                    });
                  }
                  if (records.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No records in this section.'),
                    );
                  }
                  final fields = fieldController.filteredFields;
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: records.length,
                        itemBuilder: (context, recIdx) {
                          final record = records[recIdx];
                          String? titleValue;
                          if (visibleFields.isNotEmpty) {
                            final firstVisible = visibleFields.firstWhere(
                              (f) =>
                                  visibleFields.contains(f) &&
                                  (fieldDisplay[f] ?? 'Normal') != 'Hidden',
                              orElse: () => '',
                            );
                            if (firstVisible.isNotEmpty) {
                              titleValue =
                                  record.data[firstVisible]?.toString();
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
                                      Container(
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '#${recIdx + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              Get.dialog(RecordFormDialog(
                                            sectionId: section.id,
                                            userId: widget.userId,
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
                                        onPressed: () => recordController
                                            .deleteRecord(record.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...fieldOrder
                                      .where((fieldName) =>
                                          visibleFields.contains(fieldName) &&
                                          (fieldDisplay[fieldName] ??
                                                  'Normal') !=
                                              'Hidden')
                                      .map((fieldName) {
                                    final field = fields.firstWhereOrNull(
                                        (f) => f.name == fieldName);
                                    if (field == null)
                                      return const SizedBox.shrink();
                                    final value = record.data[field.name];
                                    final display =
                                        fieldDisplay[field.name] ?? 'Normal';
                                    if (display == 'Hidden')
                                      return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          _fieldIcon(field.type),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  field.name,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  _formatFieldValue(
                                                      field, value),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
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
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8, right: 8, bottom: 8),
                          child: FloatingActionButton.small(
                            heroTag: 'add_record_${section.id}',
                            onPressed: () {
                              Get.dialog(RecordFormDialog(
                                sectionId: section.id,
                                userId: widget.userId,
                              ));
                            },
                            child: const Icon(Icons.add),
                            tooltip: 'Add Record',
                          ),
                        ),
                      ),
                    ],
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
