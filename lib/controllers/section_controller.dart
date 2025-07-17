import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/section_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sync_service.dart';

class SectionController extends GetxController {
  var sections = <Section>[].obs;
  late Box<Section> sectionBox;
  final String userId;
  SectionController({required this.userId});

  /// Show all sections from Hive (for admin/debug)
  List<Section> getAllSectionsFromHive() {
    return sectionBox.values.toList();
  }

  /// Sync all unsynced sections for this user to Firestore
  Future<void> syncUnsyncedSections() async {
    final unsynced = sectionBox.values
        .where((s) => s.userId == userId && s.synced == false)
        .toList();
    for (final section in unsynced) {
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(section.id)
          .set(section.toJson());
      // Mark as synced in Hive
      final updated = Section(
        id: section.id,
        name: section.name,
        icon: section.icon,
        color: section.color,
        description: section.description,
        order: section.order,
        synced: true,
        settings: section.settings,
        userId: section.userId,
      );
      await sectionBox.put(section.id, updated);
    }
    loadSections();
  }

  /// Call this in onInit or periodically for auto-sync
  @override
  void onInit() {
    super.onInit();
    sectionBox = Hive.box<Section>('sections');
    loadSections();
    syncUnsyncedSections(); // automatic sync for this user
  }

  void loadSections() {
    sections.value =
        sectionBox.values.where((s) => s.userId == userId).toList();
  }

  Future<void> uploadSection(Section section) async {
    await FirebaseFirestore.instance
        .collection('sections')
        .doc(section.id)
        .set(section.toJson());
  }

  Future<void> deleteSectionFromCloud(String id) async {
    await FirebaseFirestore.instance.collection('sections').doc(id).delete();
  }

  Future<void> fetchSectionsFromCloud() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sections')
        .where('userId', isEqualTo: userId)
        .get();
    final remoteSections =
        snapshot.docs.map((doc) => Section.fromJson(doc.data())).toList();
    for (final section in remoteSections) {
      await sectionBox.put(section.id, section);
    }
    loadSections();
  }

  void addSection(Section section) async {
    final userSection = Section(
      id: section.id,
      name: section.name,
      icon: section.icon,
      color: section.color,
      description: section.description,
      order: section.order,
      synced: section.synced,
      settings: section.settings,
      userId: userId,
    );
    await sectionBox.put(userSection.id, userSection);
    sections.add(userSection);
    await uploadSection(userSection);
    update();
    await SyncService(userId: userId).onDataChanged();
  }

  void editSection(String id, Section updated) async {
    final userSection = Section(
      id: updated.id,
      name: updated.name,
      icon: updated.icon,
      color: updated.color,
      description: updated.description,
      order: updated.order,
      synced: updated.synced,
      settings: updated.settings,
      userId: userId,
    );
    await sectionBox.put(id, userSection);
    int idx = sections.indexWhere((s) => s.id == id);
    if (idx != -1) sections[idx] = userSection;
    await uploadSection(userSection);
    await SyncService(userId: userId).onDataChanged();
  }

  void deleteSection(String id) async {
    await sectionBox.delete(id);
    sections.removeWhere((s) => s.id == id);
    await deleteSectionFromCloud(id);
    await SyncService(userId: userId).onDataChanged();
  }

  void refreshSections() async {
    final box = await Hive.openBox<Section>('sections');
    sections.value = box.values.where((s) => s.userId == userId).toList();
    update();
  }

  // Placeholder for sync logic
  Future<void> syncSection(Section section) async {
    // TODO: Implement Firestore sync and set section.synced = true on success
  }

  Future<void> syncSections() async {
    await fetchSectionsFromCloud();
  }

  String exportSectionsAsJson() {
    final sectionList = sections.map((s) => s.toJson()).toList();
    return sectionList.toString();
  }

  String exportSectionsAsCsv() {
    if (sections.isEmpty) return '';
    final headers = sections.first.toJson().keys.toList();
    final rows =
        sections.map((s) => headers.map((h) => s.toJson()[h]).toList());
    final csv = StringBuffer();
    csv.writeln(headers.join(','));
    for (final row in rows) {
      csv.writeln(row.map((v) => '"${v ?? ''}"').join(','));
    }
    return csv.toString();
  }
}
